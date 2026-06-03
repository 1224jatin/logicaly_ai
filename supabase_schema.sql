-- Run this in the Supabase SQL editor for project cgqlphczyvecbagvtmwe.
-- Auth note: this app keeps its custom EmailJS OTP before sign up, so disable
-- Supabase "Confirm email" in Authentication settings unless you want a second
-- Supabase confirmation email after the app OTP.

create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  user_name text not null default '',
  email text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  email text not null default '',
  streak_days int not null default 0,
  daily_goal_minutes int not null default 30,
  completed_minutes int not null default 0,
  tests_taken int not null default 0,
  study_hours int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  sender_id text not null,
  receiver_id text not null,
  message text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.flashcards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  question text not null,
  answer text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.quizzes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  quiz text not null,
  quiz_answer text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  input text not null default '',
  generated_note text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.activity (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  subtitle text not null default '',
  created_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, user_name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', ''),
    coalesce(new.email, '')
  )
  on conflict (id) do update set
    user_name = excluded.user_name,
    email = excluded.email;

  insert into public.profiles (id, name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', ''),
    coalesce(new.email, '')
  )
  on conflict (id) do update set
    name = excluded.name,
    email = excluded.email;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

alter table public.users enable row level security;
alter table public.profiles enable row level security;
alter table public.messages enable row level security;
alter table public.flashcards enable row level security;
alter table public.quizzes enable row level security;
alter table public.notes enable row level security;
alter table public.activity enable row level security;

drop policy if exists "Users can manage own user row" on public.users;
create policy "Users can manage own user row"
on public.users for all
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "Users can manage own profile" on public.profiles;
create policy "Users can manage own profile"
on public.profiles for all
using (auth.uid() = id)
with check (auth.uid() = id);

drop policy if exists "Users can manage own messages" on public.messages;
create policy "Users can manage own messages"
on public.messages for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can manage own flashcards" on public.flashcards;
create policy "Users can manage own flashcards"
on public.flashcards for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can manage own quizzes" on public.quizzes;
create policy "Users can manage own quizzes"
on public.quizzes for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can manage own notes" on public.notes;
create policy "Users can manage own notes"
on public.notes for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "Users can manage own activity" on public.activity;
create policy "Users can manage own activity"
on public.activity for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

insert into storage.buckets (id, name, public)
values ('user-files', 'user-files', true)
on conflict (id) do nothing;

drop policy if exists "Users can manage own files" on storage.objects;
create policy "Users can manage own files"
on storage.objects for all
using (
  bucket_id = 'user-files'
  and auth.uid()::text = (storage.foldername(name))[2]
)
with check (
  bucket_id = 'user-files'
  and auth.uid()::text = (storage.foldername(name))[2]
);
