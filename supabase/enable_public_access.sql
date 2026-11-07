-- O app usa a chave publishable (anon). Sem estas policies, SELECT
-- pode até funcionar, mas INSERT/UPDATE/DELETE são bloqueados pelo RLS.

alter table public.product enable row level security;
alter table public.customer enable row level security;
alter table public.representative enable row level security;
alter table public."app-transaction" enable row level security;

drop policy if exists "public_access_product" on public.product;
create policy "public_access_product"
on public.product
for all
to anon, authenticated
using (true)
with check (true);

drop policy if exists "public_access_customer" on public.customer;
create policy "public_access_customer"
on public.customer
for all
to anon, authenticated
using (true)
with check (true);

drop policy if exists "public_access_representative" on public.representative;
create policy "public_access_representative"
on public.representative
for all
to anon, authenticated
using (true)
with check (true);

drop policy if exists "public_access_app_transaction" on public."app-transaction";
create policy "public_access_app_transaction"
on public."app-transaction"
for all
to anon, authenticated
using (true)
with check (true);
