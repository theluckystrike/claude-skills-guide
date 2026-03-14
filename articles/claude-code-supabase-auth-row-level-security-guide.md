---
layout: default
title: "Claude Code Supabase Auth Row Level Security Guide"
description: "A comprehensive guide to implementing Supabase authentication with Row Level Security (RLS) policies using Claude Code. Learn how to secure your data."
date: 2026-03-14
author: "Claude Skills Guide"
permalink: /claude-code-supabase-auth-row-level-security-guide/
categories: [guides]
reviewed: true
score: 7
tags: [claude-code, claude-skills, supabase, security]
---
{% raw %}

# Claude Code Supabase Auth Row Level Security Guide

Supabase's Row Level Security (RLS) combined with their authentication system provides a powerful, declarative way to secure your database at the row level. When paired with Claude Code, you can rapidly implement robust security policies that protect user data while maintaining flexibility. This guide walks you through setting up Supabase Auth and implementing RLS policies that work seamlessly with authenticated users.

## Understanding Supabase Auth and RLS

Supabase Auth provides multiple authentication methods including email/password, OAuth providers, magic links, and phone authentication. RLS then uses the `auth.uid()` function to identify the authenticated user and apply granular access policies. This separation of concerns means your authentication logic stays separate from your data access rules, making security easier to reason about and maintain.

When a user authenticates, Supabase sets a JWT token that includes their user ID. RLS policies can then reference this ID to grant or deny access to specific rows. The key insight is that RLS runs after authentication but before any query executes, providing security at the database level rather than application level.

### How Auth and RLS Work Together

The authentication flow integrates with RLS through the `auth` schema:

```sql
-- The auth.users table stores user information
SELECT id, email, created_at FROM auth.users;

-- RLS policies use auth.uid() to get current user
CREATE POLICY "Users can see their own data"
  ON my_table
  FOR SELECT
  USING (auth.uid() = user_id);
```

Claude Code can help you write these policies, test them with different user contexts, and iterate quickly until your security model works correctly.

## Setting Up Supabase Auth

Before implementing RLS, set up your Supabase project with authentication. Install the Supabase client and configure it with your project credentials:

```bash
npm install @supabase/supabase-js
```

Configure your Supabase client with environment variables:

```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.SUPABASE_URL!
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

For operations requiring elevated privileges, use the service role key—but never expose this in client-side code. Claude Code can help you set up proper environment configurations and keep secrets secure.

### Implementing Sign Up and Sign In

Create authentication functions that integrate with your frontend:

```typescript
// auth/supabase-auth.ts
import { supabase } from '../lib/supabase'

export async function signUp(email: string, password: string) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      emailRedirectTo: `${window.location.origin}/auth/callback`
    }
  })
  
  if (error) throw new Error(error.message)
  return data
}

export async function signIn(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })
  
  if (error) throw new Error(error.message)
  return data
}

export async function signOut() {
  const { error } = await supabase.auth.signOut()
  if (error) throw new Error(error.message)
}
```

## Enabling and Configuring Row Level Security

Once authentication is working, enable RLS on your tables and create policies. Always enable RLS one table at a time, testing each policy before moving to the next.

### Enabling RLS on Tables

Enable RLS on each table that needs protection:

```sql
-- Enable RLS on profiles table
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Enable RLS on posts table
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- Enable RLS on comments table
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
```

Claude Code can help you audit your schema and identify which tables contain sensitive data that requires RLS protection.

### Creating User-Specific Policies

The most common pattern is restricting access to the authenticated user's own data:

```sql
-- Users can read their own profile
CREATE POLICY "Users can read own profile"
  ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile"
  ON public.profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Users can delete their own profile
CREATE POLICY "Users can delete own profile"
  ON public.profiles
  FOR DELETE
  USING (auth.uid() = id);
```

The USING clause controls SELECT, UPDATE, and DELETE operations, while WITH CHECK controls INSERT operations. Both should validate that the authenticated user owns the data.

### Creating Owner-Based Policies

For hierarchical data where users own resources through a foreign key:

```sql
-- Users can read posts they own
CREATE POLICY "Users can read own posts"
  ON public.posts
  FOR SELECT
  USING (auth.uid() = owner_id);

-- Users can insert posts they own
CREATE POLICY "Users can insert own posts"
  ON public.posts
  FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

-- Users can update posts they own
CREATE POLICY "Users can update own posts"
  ON public.posts
  FOR UPDATE
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

-- Users can delete posts they own
CREATE POLICY "Users can delete own posts"
  ON public.posts
  FOR DELETE
  USING (auth.uid() = owner_id);
```

This pattern works for any table with an `owner_id` column that references `auth.users.id`.

## Implementing Team-Based Access Control

Beyond individual user data, many applications need team or organization-based access. Supabase RLS supports this through custom claims and separate access tables.

### Using Organization Membership Tables

Create a membership table to track team relationships:

```sql
-- Create organizations table
CREATE TABLE public.organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create organization memberships
CREATE TABLE public.organization_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(organization_id, user_id)
);

-- Enable RLS
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_members ENABLE ROW LEVEL SECURITY;

-- Policies for organizations
CREATE POLICY "Org members can view organizations"
  ON public.organizations
  FOR SELECT
  USING (
    id IN (
      SELECT organization_id 
      FROM public.organization_members 
      WHERE user_id = auth.uid()
    )
  );

-- Policies for memberships
CREATE POLICY "Members can view membership"
  ON public.organization_members
  FOR SELECT
  USING (auth.uid() = user_id);
```

### Creating Team-Scoped Policies

Apply team-based access to any resource:

```sql
-- Users can read documents in their organizations
CREATE POLICY "Team members can read documents"
  ON public.documents
  FOR SELECT
  USING (
    organization_id IN (
      SELECT organization_id 
      FROM public.organization_members 
      WHERE user_id = auth.uid()
    )
  );

-- Users can insert documents in their organizations
CREATE POLICY "Team members can insert documents"
  ON public.documents
  FOR INSERT
  WITH CHECK (
    organization_id IN (
      SELECT organization_id 
      FROM public.organization_members 
      WHERE user_id = auth.uid()
    )
  );
```

Claude Code can help you design the right data model for your team's access control needs and generate the necessary SQL policies.

## Implementing Role-Based Access Control

For more complex applications, implement role-based access control (RBAC) with Supabase:

```sql
-- Add role column to organization_members
ALTER TABLE public.organization_members
ADD COLUMN role TEXT NOT NULL DEFAULT 'member';

-- Create role-based policies
CREATE POLICY "Owners can do everything"
  ON public.documents
  FOR ALL
  USING (
    organization_id IN (
      SELECT organization_id 
      FROM public.organization_members 
      WHERE user_id = auth.uid() AND role = 'owner'
    )
  );

CREATE POLICY "Admins can update"
  ON public.documents
  FOR UPDATE
  USING (
    organization_id IN (
      SELECT organization_id 
      FROM public.organization_members 
      WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
    )
  );

CREATE POLICY "Members can read"
  ON public.documents
  FOR SELECT
  USING (
    organization_id IN (
      SELECT organization_id 
      FROM public.organization_members 
      WHERE user_id = auth.uid() AND role IN ('owner', 'admin', 'member')
    )
  );
```

## Using Auth Context in Edge Functions

Edge Functions run with elevated privileges but can still access the authenticated user's context:

```typescript
// supabase/functions/get-user-data.ts
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

serve(async (req) => {
  // Create client with service role to bypass RLS
  const supabase = createClient(supabaseUrl, supabaseServiceKey)
  
  // Get the authorization header
  const authHeader = req.headers.get('Authorization')!
  
  // Create client with user's JWT to respect RLS
  const userClient = createClient(
    supabaseUrl,
    supabaseServiceKey,
    {
      global: {
        headers: { Authorization: authHeader }
      }
    }
  )
  
  // This query will respect RLS policies
  const { data, error } = await userClient
    .from('profiles')
    .select('*')
  
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 400
    })
  }
  
  return new Response(JSON.stringify({ data }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

## Testing RLS Policies

Always test your RLS policies thoroughly. Use the Supabase dashboard or SQL editor to verify each policy works correctly:

```sql
-- Test as authenticated user
SELECT * FROM public.profiles;  -- Should only return user's own profile

-- Test insert with RLS
INSERT INTO public.profiles (id, username) 
VALUES (auth.uid(), 'test_user');  -- Should succeed

-- Test cross-user access (should fail)
INSERT INTO public.profiles (id, username) 
VALUES ('different-user-uuid', 'other_user');  -- Should fail
```

Claude Code can help you write test scripts that verify your RLS policies work correctly across different scenarios.

## Security Best Practices

Follow these practices when implementing Supabase Auth with RLS:

- **Always enable RLS** on tables containing user data or sensitive information
- **Use the principle of least privilege** — grant minimum necessary access
- **Test policies with different user contexts** before deploying to production
- **Keep service role keys secure** — never expose them in client-side code
- **Use separate policies** for different operations rather than broad ALL policies
- **Monitor query performance** — complex RLS policies can impact query speed

## Conclusion

Supabase Auth combined with Row Level Security provides a robust, scalable approach to data security. By defining policies at the database level, you ensure consistent enforcement regardless of how your data is accessed. Claude Code can accelerate your implementation, helping you write policies, test them thoroughly, and iterate quickly as your application evolves.

{% endraw %}
