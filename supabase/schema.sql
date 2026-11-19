-- College Guide database. Run only on a NEW dedicated Supabase project.
-- Never run this on restaurant-growth-os or any project used by another app.

create table if not exists public.places (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 1 and 180),
  type text not null check (type in ('مدرج','معمل','قاعة دراسية','إداري')),
  building text not null default '',
  floor text not null default '',
  landmark text not null default '',
  directions text not null default '',
  notes text not null default '',
  image_url text not null default '',
  verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists places_type_idx on public.places(type);
create index if not exists places_building_idx on public.places(building);
create index if not exists places_verified_created_idx on public.places(verified, created_at desc);

alter table public.places enable row level security;
grant usage on schema public to anon, authenticated;
grant select on public.places to anon, authenticated;
grant insert, update, delete on public.places to authenticated;

create or replace function public.is_college_admin()
returns boolean language sql stable set search_path = ''
as $$ select (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'; $$;
revoke all on function public.is_college_admin() from public, anon;
grant execute on function public.is_college_admin() to authenticated;

drop policy if exists "Public can read verified places" on public.places;
create policy "Public can read verified places" on public.places
  for select to anon using (verified is true);
drop policy if exists "Signed-in users can read approved places and admins all places" on public.places;
create policy "Signed-in users can read approved places and admins all places" on public.places
  for select to authenticated using (verified is true or (select public.is_college_admin()));
drop policy if exists "Admins can insert places" on public.places;
create policy "Admins can insert places" on public.places
  for insert to authenticated with check ((select public.is_college_admin()));
drop policy if exists "Admins can update places" on public.places;
create policy "Admins can update places" on public.places
  for update to authenticated using ((select public.is_college_admin())) with check ((select public.is_college_admin()));
drop policy if exists "Admins can delete places" on public.places;
create policy "Admins can delete places" on public.places
  for delete to authenticated using ((select public.is_college_admin()));

create or replace function public.set_places_updated_at()
returns trigger language plpgsql set search_path = ''
as $$ begin new.updated_at = pg_catalog.now(); return new; end; $$;
drop trigger if exists places_set_updated_at on public.places;
create trigger places_set_updated_at before update on public.places
  for each row execute function public.set_places_updated_at();

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('college-guide','college-guide',true,8388608,array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public=true, file_size_limit=8388608, allowed_mime_types=array['image/jpeg','image/png','image/webp','image/gif'];

-- The public bucket serves image URLs; no public SELECT policy is added, so visitors cannot enumerate object listings.
drop policy if exists "Anyone can view college guide images" on storage.objects;
drop policy if exists "Admins can upload college guide images" on storage.objects;
create policy "Admins can upload college guide images" on storage.objects
  for insert to authenticated with check (bucket_id = 'college-guide' and (select public.is_college_admin()));
drop policy if exists "Admins can update college guide images" on storage.objects;
create policy "Admins can update college guide images" on storage.objects
  for update to authenticated using (bucket_id = 'college-guide' and (select public.is_college_admin()))
  with check (bucket_id = 'college-guide' and (select public.is_college_admin()));
drop policy if exists "Admins can delete college guide images" on storage.objects;
create policy "Admins can delete college guide images" on storage.objects
  for delete to authenticated using (bucket_id = 'college-guide' and (select public.is_college_admin()));

do $$ begin
  alter publication supabase_realtime add table public.places;
exception when duplicate_object then null; when undefined_object then null; end $$;

-- Create the admin in Supabase Auth and set app_metadata.role = admin in the dashboard.
-- Confirm Data API is enabled and public is listed in Exposed schemas.
