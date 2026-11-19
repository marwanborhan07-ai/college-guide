-- دليل الكلية الذكي: مرجع المخطط والسياسات
create table if not exists public.places (
 id uuid primary key default gen_random_uuid(),
 name text not null check (length(trim(name)) > 0),
 type text not null check (type in ('مدرج','معمل','قاعة دراسية','إداري')),
 building text not null default '', floor text not null default '', landmark text not null default '',
 directions text not null default '', image_url text not null default '', verified boolean not null default false,
 notes text not null default '', created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index if not exists places_type_idx on public.places(type);
create index if not exists places_building_idx on public.places(building);
alter table public.places enable row level security;
grant select on public.places to anon, authenticated;
grant insert,update,delete on public.places to authenticated;
create or replace function public.is_college_admin() returns boolean language sql stable set search_path = '' as $$ select (auth.jwt()->'app_metadata'->>'role')='admin'; $$;
revoke all on function public.is_college_admin() from public,anon;
grant execute on function public.is_college_admin() to authenticated;
drop policy if exists "Public can read places" on public.places;
create policy "Public can read places" on public.places for select to anon,authenticated using(true);
drop policy if exists "Admins can insert places" on public.places;
create policy "Admins can insert places" on public.places for insert to authenticated with check((select public.is_college_admin()));
drop policy if exists "Admins can update places" on public.places;
create policy "Admins can update places" on public.places for update to authenticated using((select public.is_college_admin())) with check((select public.is_college_admin()));
drop policy if exists "Admins can delete places" on public.places;
create policy "Admins can delete places" on public.places for delete to authenticated using((select public.is_college_admin()));
