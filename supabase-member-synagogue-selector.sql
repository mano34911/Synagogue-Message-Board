-- Synagogue member selector for registration/login
-- Run once in Supabase SQL Editor.
-- It exposes ONLY active/trial synagogue names and public board IDs.

create or replace function public.list_member_synagogues()
returns table(
  synagogue_id uuid,
  slug text,
  synagogue_name text,
  rabbi_name text
)
language sql
stable
security definer
set search_path = public
as $$
  select
    s.id as synagogue_id,
    s.slug,
    s.synagogue_name,
    coalesce(s.rabbi_name,'') as rabbi_name
  from public.synagogues s
  where
    s.status = 'active'
    or (
      s.status = 'trial'
      and s.trial_ends_at is not null
      and now() < s.trial_ends_at
    )
  order by lower(s.synagogue_name), lower(s.slug);
$$;

revoke all on function public.list_member_synagogues() from public;
grant execute on function public.list_member_synagogues() to anon, authenticated;

-- The existing organization_members table already stores both synagogue_id
-- and organization_slug, so member registration stays attached to exactly
-- one synagogue. The existing handle_new_user() trigger from
-- 20260901_member_donations.sql performs that attachment.
