-- Unified registration fields for Synagogue + Christian Church members
-- Run ONCE in Supabase SQL Editor before using the new register pages.

create sequence if not exists public.member_id_seq start with 1001;

alter table public.profiles add column if not exists member_id text unique;
alter table public.profiles add column if not exists street_address text;
alter table public.profiles add column if not exists city text;
alter table public.profiles add column if not exists state_region text;
alter table public.profiles add column if not exists postal_code text;
alter table public.profiles add column if not exists country text;
alter table public.profiles add column if not exists heard_about text;
alter table public.profiles add column if not exists referred_by text;
alter table public.profiles add column if not exists referral_code text;

-- Give older member records an ID too, without changing their access/status.
update public.profiles p
set member_id = 'MB-' || lpad(nextval('public.member_id_seq')::text, 6, '0')
where p.role='member' and (p.member_id is null or p.member_id='');

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path=public
as $$
declare
  v_slug text;
  v_name text;
  v_leader text;
  v_type text;
  v_settings jsonb;
  v_member_id text;
begin
  v_type := case when lower(coalesce(new.raw_user_meta_data->>'organization_type',''))='church' then 'church' else 'synagogue' end;
  v_name := coalesce(nullif(new.raw_user_meta_data->>'organization_name',''),nullif(new.raw_user_meta_data->>'synagogue_name',''),case when v_type='church' then 'New Church' else 'New Synagogue' end);
  v_leader := coalesce(new.raw_user_meta_data->>'leader_name',new.raw_user_meta_data->>'rabbi_name','');
  v_member_id := (case when v_type='church' then 'CHR-' else 'SYN-' end) || lpad(nextval('public.member_id_seq')::text,6,'0');
  v_slug := lower((case when v_type='church' then 'church-' else 'syn-' end) || substr(new.id::text,1,8));

  insert into public.profiles(
    user_id,email,full_name,phone,role,member_id,
    street_address,city,state_region,postal_code,country,
    heard_about,referred_by,referral_code
  ) values(
    new.id,new.email,new.raw_user_meta_data->>'full_name',new.raw_user_meta_data->>'phone','member',v_member_id,
    new.raw_user_meta_data->>'street_address',new.raw_user_meta_data->>'city',new.raw_user_meta_data->>'state_region',new.raw_user_meta_data->>'postal_code',new.raw_user_meta_data->>'country',
    new.raw_user_meta_data->>'heard_about',new.raw_user_meta_data->>'referred_by',new.raw_user_meta_data->>'referral_code'
  ) on conflict (user_id) do update set
    email=excluded.email, full_name=excluded.full_name, phone=excluded.phone,
    street_address=excluded.street_address, city=excluded.city, state_region=excluded.state_region,
    postal_code=excluded.postal_code, country=excluded.country,
    heard_about=excluded.heard_about, referred_by=excluded.referred_by, referral_code=excluded.referral_code;

  insert into public.synagogues(owner_user_id,slug,synagogue_name,rabbi_name,status)
  values(new.id,v_slug,v_name,v_leader,'pending');

  if v_type='church' then
    v_settings := jsonb_build_object('organization_type','church','church',v_name,'pastor',v_leader,'synagogue',v_name,'rabbi',v_leader);
  else
    v_settings := jsonb_build_object('organization_type','synagogue','synagogue',v_name,'rabbi',v_leader);
  end if;

  insert into public.synagogue_settings(synagogue_id,settings)
  select s.id,v_settings from public.synagogues s where s.owner_user_id=new.id
  on conflict (synagogue_id) do update set settings=excluded.settings,updated_at=now();

  return new;
exception when unique_violation then
  raise exception 'A unique account value is already in use. Please try again.';
end;
$$;

-- Existing 7-day trial/payment/access functions and policies remain unchanged.
