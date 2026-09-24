-- Synagogue Message Board — September 24, 2026 number/profile patch
-- Keeps the real synagogue primary key as UUID.
-- Adds a simple public-facing sequential synagogue_number.
-- Existing two synagogues become #1 and #2; the next registration becomes #3.

begin;

alter table public.synagogues
  add column if not exists synagogue_number bigint;

create sequence if not exists public.synagogue_number_seq;

-- Backfill existing synagogues in registration order without changing UUID IDs.
with numbered as (
  select id, row_number() over (order by created_at asc nulls last, id asc) as n
  from public.synagogues
)
update public.synagogues s
set synagogue_number = numbered.n
from numbered
where s.id = numbered.id
  and s.synagogue_number is null;

-- Advance the sequence to the current highest number.
do $$
declare
  v_max bigint;
begin
  select coalesce(max(synagogue_number),0) into v_max from public.synagogues;
  if v_max > 0 then
    perform setval('public.synagogue_number_seq', v_max, true);
  else
    perform setval('public.synagogue_number_seq', 1, false);
  end if;
end $$;

alter table public.synagogues
  alter column synagogue_number set default nextval('public.synagogue_number_seq');

create unique index if not exists synagogues_synagogue_number_uidx
  on public.synagogues(synagogue_number)
  where synagogue_number is not null;

-- Fields used by the upgraded Master Admin details view.
alter table public.profiles add column if not exists street_address text;
alter table public.profiles add column if not exists city text;
alter table public.profiles add column if not exists state_region text;
alter table public.profiles add column if not exists postal_code text;
alter table public.profiles add column if not exists country text;
alter table public.profiles add column if not exists member_id text;

commit;

-- Verification: with two existing synagogues this should show 1 and 2,
-- and the next new synagogue row will automatically receive 3.
select synagogue_number, synagogue_name, rabbi_name, id
from public.synagogues
order by synagogue_number;
