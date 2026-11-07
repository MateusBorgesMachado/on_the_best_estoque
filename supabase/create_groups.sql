create table if not exists public."product-group" (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  "created-at" timestamptz not null default now()
);

create table if not exists public."product-subgroup" (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  "group-id" uuid not null references public."product-group"(id) on delete cascade,
  "created-at" timestamptz not null default now(),
  unique ("group-id", name)
);

alter table public."product-group" enable row level security;
alter table public."product-subgroup" enable row level security;

drop policy if exists "public_access_product_group" on public."product-group";
create policy "public_access_product_group"
on public."product-group"
for all
to anon, authenticated
using (true)
with check (true);

drop policy if exists "public_access_product_subgroup" on public."product-subgroup";
create policy "public_access_product_subgroup"
on public."product-subgroup"
for all
to anon, authenticated
using (true)
with check (true);
