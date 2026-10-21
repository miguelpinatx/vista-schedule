-- Vista Schedule Builder: one simple document table
create table if not exists public.docs (
  collection text not null,
  id text not null,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (collection, id)
);
alter table public.docs enable row level security;
drop policy if exists "open read" on public.docs;
drop policy if exists "open write" on public.docs;
create policy "open read" on public.docs for select to anon, authenticated using (true);
create policy "open write" on public.docs for all to anon, authenticated using (true) with check (true);
alter table public.docs replica identity full;
do $$ begin
  alter publication supabase_realtime add table public.docs;
exception when duplicate_object then null; end $$;

-- update one schedule cell without overwriting other people's edits
create or replace function public.set_cell(p_id text, p_meta jsonb, p_sid text, p_day text, p_val jsonb)
returns jsonb language plpgsql security invoker as $$
declare d jsonb;
begin
  insert into public.docs(collection,id,data) values ('schedules',p_id, p_meta || '{"shifts":{}}'::jsonb)
  on conflict (collection,id) do nothing;
  select data into d from public.docs where collection='schedules' and id=p_id for update;
  if d->'shifts' is null then d := jsonb_set(d,'{shifts}','{}'::jsonb); end if;
  if d->'shifts'->p_sid is null then d := jsonb_set(d, array['shifts',p_sid], '{}'::jsonb); end if;
  d := jsonb_set(d, array['shifts',p_sid,p_day], coalesce(p_val,'null'::jsonb));
  update public.docs set data=d, updated_at=now() where collection='schedules' and id=p_id;
  return d;
end $$;
grant execute on function public.set_cell(text,jsonb,text,text,jsonb) to anon, authenticated;
