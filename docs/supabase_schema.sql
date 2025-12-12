-- Supabase schema for JobTrack
-- Run these statements in your Supabase SQL editor to create tables for job_cards and providers.

-- Enable pgcrypto extension for gen_random_uuid()
create extension if not exists pgcrypto;

-- Table: providers
create table if not exists providers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text,
  phone text,
  notes text,
  created_at timestamptz default timezone('utc', now()),
  updated_at timestamptz default timezone('utc', now())
);

-- Table: job_cards
create table if not exists job_cards (
  id uuid primary key default gen_random_uuid(),
  company_name text not null,
  job_title text not null,
  status text not null,
  notes text,
  applied_date timestamptz,
  created_at timestamptz default timezone('utc', now()),
  updated_at timestamptz default timezone('utc', now())
);

-- Simple upsert policy (for demo). Configure RLS and policies according to your auth model.
