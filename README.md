# Vista Markets Schedule Builder

Weekly schedule builder for Vista Markets stores (El Paso).
Open the site, pick your store, and follow the steps: week & department → team → shifts → availability & days off → place shifts → review & print.

- Data is shared live through Supabase (table `docs`, see `schema.sql`).
- Fast fill builds a schedule from availability, hour caps and preferred shifts. No AI needed.
- Optional PIN can be set in Settings.
- Payroll budget: admin sets blended $/hr and payroll % per store in Settings; managers enter daily sales goals on Full schedule.
