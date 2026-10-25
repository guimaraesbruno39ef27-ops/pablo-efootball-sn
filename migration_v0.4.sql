-- PABLO eFOOTBALL SN v0.4: captures privées + contestations
alter table public.matches add column if not exists proof_path text;

create table if not exists public.disputes (
 id uuid primary key default gen_random_uuid(),
 match_id uuid not null references public.matches(id) on delete cascade,
 opened_by uuid not null references public.profiles(id),
 reason text not null check (char_length(reason) between 10 and 1000),
 evidence_path text,
 status text not null default 'open' check (status in ('open','resolved','dismissed')),
 resolution text,
 reviewed_by uuid references public.profiles(id),
 reviewed_at timestamptz,
 created_at timestamptz not null default now()
);
create index if not exists disputes_status_created_idx on public.disputes(status,created_at desc);
alter table public.disputes enable row level security;

drop policy if exists "disputes readable by opener or admins" on public.disputes;
create policy "disputes readable by opener or admins" on public.disputes for select to authenticated
using (opened_by=auth.uid() or exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin'));
drop policy if exists "players open disputes on matches they played" on public.disputes;
create policy "players open disputes on matches they played" on public.disputes for insert to authenticated
with check (opened_by=auth.uid() and exists(select 1 from public.matches m where m.id=match_id and (m.player1_id=auth.uid() or m.player2_id=auth.uid())));
drop policy if exists "admins decide disputes" on public.disputes;
create policy "admins decide disputes" on public.disputes for update to authenticated
using (exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin'))
with check (exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin'));

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values ('match-proofs','match-proofs',false,5242880,array['image/jpeg','image/png','image/webp'])
on conflict(id) do update set public=false,file_size_limit=5242880,allowed_mime_types=array['image/jpeg','image/png','image/webp'];

drop policy if exists "players upload own proof files" on storage.objects;
create policy "players upload own proof files" on storage.objects for insert to authenticated
with check (bucket_id='match-proofs' and (storage.foldername(name))[1]=auth.uid()::text);
drop policy if exists "owners and admins read proof files" on storage.objects;
create policy "owners and admins read proof files" on storage.objects for select to authenticated
using (bucket_id='match-proofs' and (
 (storage.foldername(name))[1]=auth.uid()::text
 or exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin')
 or exists(select 1 from public.matches m where m.proof_path=name and (m.player1_id=auth.uid() or m.player2_id=auth.uid()))
 or exists(select 1 from public.disputes d where d.evidence_path=name and (d.opened_by=auth.uid() or exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='admin')))
));
