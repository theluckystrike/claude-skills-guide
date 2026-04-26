---

layout: default
title: "Setup Next-Auth with Claude Code (2026)"
description: "Implement getServerSession with authOptions in Next-Auth using Claude Code for provider integration, route protection, and session management."
date: 2026-03-14
last_modified_at: 2026-04-17
categories: [guides]
tags: [claude-code, nextjs, authentication, next-auth, web-development, claude-skills]
author: "Claude Skills Guide"
permalink: /claude-code-nextjs-authentication-next-auth-guide/
reviewed: true
score: 7
last_tested: "2026-04-21"
geo_optimized: true
---

Building secure authentication into Next.js applications becomes significantly easier when you combine the power of NextAuth.js with Claude Code's CLI capabilities. This guide walks you through setting up authentication, configuring providers, and protecting routes in your Next.js projects using Claude Code as your development assistant. Whether you're adding auth to an existing app or starting from scratch, the patterns here give you a production-ready foundation.

## Setting Up NextAuth in Your Next.js Project

Before integrating NextAuth, ensure you have a Next.js project ready. If you're starting fresh, Claude Code can scaffold a project with the necessary dependencies:

```bash
npx create-next-app@latest my-auth-app --typescript --app
cd my-auth-app
npm install next-auth
```

The next-auth package provides the authentication framework, while Claude Code helps you implement the specific configuration needed for your use case. The CLI can read your project structure, understand your requirements, and generate the appropriate configuration files.

One of the first things to decide is whether you'll use the App Router or Pages Router. NextAuth v4 supports both, but the configuration differs slightly. This guide focuses on the App Router pattern since it's the current Next.js default.

## Configuring NextAuth Providers

NextAuth supports multiple authentication providers including Google, GitHub, credentials, and more. Here's how to configure a basic setup with GitHub OAuth:

```typescript
// app/api/auth/[...nextauth]/route.ts
import NextAuth from "next-auth"
import GithubProvider from "next-auth/providers/github"

const handler = NextAuth({
 providers: [
 GithubProvider({
 clientId: process.env.GITHUB_ID,
 clientSecret: process.env.GITHUB_SECRET,
 }),
 ],
 pages: {
 signIn: '/auth/signin',
 error: '/auth/error',
 },
 callbacks: {
 async session({ session, token }) {
 if (session.user) {
 session.user.id = token.sub
 }
 return session
 },
 },
})

export { handler as GET, handler as POST }
```

Claude Code can help you customize this configuration based on your specific provider requirements. For instance, if you need to add role-based access control or custom user attributes, the CLI can modify the callbacks to include your business logic.

## Adding Multiple Providers

Most production applications need more than one provider. Here's how to combine GitHub, Google, and email/password credentials in a single configuration:

```typescript
// app/api/auth/[...nextauth]/route.ts
import NextAuth from "next-auth"
import GithubProvider from "next-auth/providers/github"
import GoogleProvider from "next-auth/providers/google"
import CredentialsProvider from "next-auth/providers/credentials"
import { compare } from "bcryptjs"
import { db } from "@/lib/db"

const handler = NextAuth({
 providers: [
 GithubProvider({
 clientId: process.env.GITHUB_ID!,
 clientSecret: process.env.GITHUB_SECRET!,
 }),
 GoogleProvider({
 clientId: process.env.GOOGLE_CLIENT_ID!,
 clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
 }),
 CredentialsProvider({
 name: "credentials",
 credentials: {
 email: { label: "Email", type: "email" },
 password: { label: "Password", type: "password" },
 },
 async authorize(credentials) {
 if (!credentials?.email || !credentials?.password) return null

 const user = await db.user.findUnique({
 where: { email: credentials.email },
 })

 if (!user || !user.hashedPassword) return null

 const isValid = await compare(credentials.password, user.hashedPassword)
 if (!isValid) return null

 return { id: user.id, email: user.email, name: user.name }
 },
 }),
 ],
 callbacks: {
 async jwt({ token, user }) {
 if (user) {
 token.id = user.id
 }
 return token
 },
 async session({ session, token }) {
 if (session.user) {
 session.user.id = token.id as string
 }
 return session
 },
 },
 session: {
 strategy: "jwt",
 },
})

export { handler as GET, handler as POST }
```

## Provider Comparison

Understanding when to use each provider type helps you make better architectural decisions:

| Provider Type | Use Case | Setup Complexity | User Experience |
|---|---|---|---|
| GitHub OAuth | Developer tools, B2B SaaS | Low | Smooth for devs |
| Google OAuth | Consumer apps, broad audience | Low | Familiar, trusted |
| Email/Password | Full control over auth | Medium | Traditional login |
| Magic Link | Passwordless, low friction | Medium | Modern, convenient |
| SAML/OIDC | Enterprise SSO | High | Enterprise standard |

## Protecting Routes with Middleware

Next.js middleware provides an efficient way to protect routes at the edge. Create a middleware file to enforce authentication:

```typescript
// middleware.ts
import { withAuth } from "next-auth/middleware"

export default withAuth({
 pages: {
 signIn: "/auth/signin",
 },
})

export const config = {
 matcher: [
 "/dashboard/:path*",
 "/profile/:path*",
 "/api/protected/:path*",
 ],
}
```

This configuration ensures that unauthenticated users are redirected to the sign-in page when attempting to access protected areas. Claude Code can extend this pattern to handle role-based routing, where different user roles access different parts of your application.

## Role-Based Route Protection

For applications with multiple user roles, extend the middleware to check role claims stored in the JWT:

```typescript
// middleware.ts
import { withAuth, NextRequestWithAuth } from "next-auth/middleware"
import { NextResponse } from "next/server"

export default withAuth(
 function middleware(req: NextRequestWithAuth) {
 const token = req.nextauth.token
 const isAdminRoute = req.nextUrl.pathname.startsWith("/admin")

 if (isAdminRoute && token?.role !== "admin") {
 return NextResponse.rewrite(new URL("/unauthorized", req.url))
 }

 return NextResponse.next()
 },
 {
 callbacks: {
 authorized: ({ token }) => !!token,
 },
 }
)

export const config = {
 matcher: [
 "/dashboard/:path*",
 "/admin/:path*",
 "/profile/:path*",
 "/api/protected/:path*",
 ],
}
```

To populate the `role` field in the token, update your NextAuth callbacks:

```typescript
callbacks: {
 async jwt({ token, user }) {
 if (user) {
 token.role = user.role // pulled from your database
 }
 return token
 },
 async session({ session, token }) {
 if (session.user) {
 session.user.id = token.sub!
 session.user.role = token.role as string
 }
 return session
 },
},
```

## Managing Sessions and User State

Client-side session management requires wrapping your application with a SessionProvider. This enables components throughout your app to access authentication state:

```typescript
// app/providers.tsx
"use client"

import { SessionProvider } from "next-auth/react"

export function Providers({ children }: { children: React.ReactNode }) {
 return <SessionProvider>{children}</SessionProvider>
}
```

Then wrap your layout:

```typescript
// app/layout.tsx
import { Providers } from "./providers"

export default function RootLayout({
 children,
}: {
 children: React.ReactNode
}) {
 return (
 <html lang="en">
 <body>
 <Providers>{children}</Providers>
 </body>
 </html>
 )
}
```

To access the session in components, use the `useSession` hook:

```typescript
"use client"
import { useSession, signOut } from "next-auth/react"

export function UserMenu() {
 const { data: session } = useSession()

 if (!session) return null

 return (
 <div>
 <p>Welcome, {session.user?.name}</p>
 <button onClick={() => signOut()}>Sign out</button>
 </div>
 )
}
```

## Server-Side Session Access

In Server Components, you access the session differently. no hook needed:

```typescript
// app/dashboard/page.tsx
import { getServerSession } from "next-auth"
import { authOptions } from "@/app/api/auth/[...nextauth]/route"
import { redirect } from "next/navigation"

export default async function DashboardPage() {
 const session = await getServerSession(authOptions)

 if (!session) {
 redirect("/auth/signin")
 }

 return (
 <div>
 <h1>Dashboard</h1>
 <p>Logged in as {session.user?.email}</p>
 </div>
 )
}
```

Exporting `authOptions` from your route handler and importing it in Server Components keeps your configuration DRY and avoids duplicating the NextAuth setup.

## Protecting API Routes

For API routes that require authentication, use `getServerSession` directly:

```typescript
// app/api/user/profile/route.ts
import { getServerSession } from "next-auth"
import { authOptions } from "@/app/api/auth/[...nextauth]/route"
import { NextResponse } from "next/server"

export async function GET() {
 const session = await getServerSession(authOptions)

 if (!session) {
 return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
 }

 // Proceed with authenticated request
 const userData = await fetchUserData(session.user.id)
 return NextResponse.json(userData)
}
```

## Integrating Claude Skills for Enhanced Development

Several Claude skills can accelerate your Next.js authentication development workflow. The frontend-design skill helps you create polished login pages and authenticated layouts that match your brand. When you need to generate PDF documentation for your authentication flow or API endpoints, the pdf skill generates professional documentation directly from your code comments.

For test-driven development, the tdd skill assists in writing comprehensive tests for your authentication logic, ensuring protected routes and session handling work correctly across different scenarios. If you're building enterprise applications with complex permission systems, consider using the supermemory skill to maintain context about user roles and access patterns across sessions.

The webapp-testing skill proves particularly valuable when verifying that authentication flows work across different browsers and devices. You can validate that sign-in redirects, session expirations, and protected route access all function as expected.

When working with Claude Code directly in the CLI, prompts like the following help generate well-structured auth code:

```
"Add a credentials provider to my NextAuth config that validates against
a Prisma User model, hashes passwords with bcryptjs, and returns the user
id and role in the JWT token"
```

Claude Code will read your existing configuration, understand the database schema if present, and produce code that integrates cleanly with what you already have.

## Handling Authentication Errors and Edge Cases

Solid authentication requires proper error handling. NextAuth provides several ways to manage errors:

```typescript
// app/auth/error/page.tsx
"use client"

import { useSearchParams } from "next/navigation"

export default function AuthError() {
 const searchParams = useSearchParams()
 const error = searchParams.get("error")

 const errorMessages: Record<string, string> = {
 OAuthSignin: "Error starting OAuth sign-in flow.",
 OAuthCallback: "Error during OAuth callback.",
 OAuthCreateAccount: "Could not create OAuth account.",
 EmailCreateAccount: "Could not create email account.",
 Callback: "Error during callback processing.",
 OAuthAccountNotLinked:
 "This email is already associated with another provider. Sign in using that provider.",
 EmailSignin: "Error sending the sign-in email.",
 CredentialsSignin: "Invalid email or password.",
 SessionRequired: "Please sign in to access this page.",
 Default: "An authentication error occurred.",
 }

 return (
 <div>
 <h1>Authentication Error</h1>
 <p>{errorMessages[error || "Default"]}</p>
 <a href="/auth/signin">Try again</a>
 </div>
 )
}
```

Implementing proper error pages improves user experience significantly. Claude Code can generate these error handling components automatically based on your existing NextAuth configuration.

## Handling Account Linking Conflicts

A common edge case is when a user tries to sign in with Google using an email already registered with GitHub. NextAuth's `OAuthAccountNotLinked` error covers this, but you can also allow account linking with a custom `signIn` callback:

```typescript
callbacks: {
 async signIn({ user, account, profile }) {
 // Allow sign-in if account exists with same email
 const existingUser = await db.user.findUnique({
 where: { email: user.email! },
 include: { accounts: true },
 })

 if (existingUser) {
 // Link the new provider to the existing account
 const providerLinked = existingUser.accounts.some(
 (acc) => acc.provider === account?.provider
 )
 if (!providerLinked && account) {
 await db.account.create({
 data: {
 userId: existingUser.id,
 provider: account.provider,
 providerAccountId: account.providerAccountId,
 type: account.type,
 },
 })
 }
 }

 return true
 },
},
```

## Environment Variable Best Practices

Never expose sensitive credentials in your codebase. Use environment variables for all authentication secrets:

```bash
.env.local
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-random-secret-here
GITHUB_ID=your-github-oauth-id
GITHUB_SECRET=your-github-oauth-secret
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
```

The `NEXTAUTH_SECRET` should be a long, random string used to encrypt tokens. Generate one using:

```bash
openssl rand -base64 32
```

Claude Code can help you audit your environment configuration and ensure no sensitive values are accidentally committed to version control. It can also generate a `.env.example` file that documents required variables without exposing actual values:

```bash
.env.example. safe to commit
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=generate-with-openssl-rand-base64-32
GITHUB_ID=
GITHUB_SECRET=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
DATABASE_URL=
```

## Validating Environment Variables at Startup

For production apps, validate that all required environment variables are present when the server starts. Create a small validation module:

```typescript
// lib/env.ts
function requireEnv(name: string): string {
 const value = process.env[name]
 if (!value) {
 throw new Error(`Missing required environment variable: ${name}`)
 }
 return value
}

export const env = {
 nextAuthUrl: requireEnv("NEXTAUTH_URL"),
 nextAuthSecret: requireEnv("NEXTAUTH_SECRET"),
 githubId: requireEnv("GITHUB_ID"),
 githubSecret: requireEnv("GITHUB_SECRET"),
}
```

Import `env` in your NextAuth config instead of accessing `process.env` directly. This way, any missing variable causes a clear startup failure rather than a cryptic runtime error.

## Conclusion

Implementing authentication with NextAuth in Next.js provides a solid foundation for securing your applications. The combination of NextAuth's flexible provider system and Claude Code's development assistance makes building secure, production-ready authentication remarkably straightforward. Remember to always use environment variables for sensitive credentials, implement proper error handling, and use middleware for efficient route protection.

As your application grows, lean on Claude Code to extend these patterns. adding new providers, implementing account linking, building admin-only sections, or integrating with a database adapter like Prisma or Drizzle. The CLI's ability to read your existing code and extend it coherently saves hours of boilerplate work on each iteration.

---


**Try it:** Paste your error into our [Error Diagnostic](/diagnose/) for an instant fix.
---

<div class="mastery-cta">

This took me 3 hours to figure out. I put it in a CLAUDE.md so I'd never figure it out again. Now Claude gets it right on the first try, every project.

16 framework templates. Next.js, FastAPI, Laravel, Rails, Go, Rust, Terraform, and 9 more. Each one 300+ lines of "here's exactly how this stack works." Copy into your project. Done.

**[See the templates →](https://zovo.one/lifetime?utm_source=ccg&utm_medium=cta-config&utm_campaign=claude-code-nextjs-authentication-next-auth-guide)**

$99 once. Yours forever. I keep adding templates monthly.

</div>

Related Reading

- [Claude Code for T3 Stack tRPC Next.js Workflow](/claude-code-for-t3-stack-trpc-nextjs-workflow/)
- [Claude Code Next.js Image Optimization Guide](/claude-code-nextjs-image-optimization-guide/)
- [Claude Code for Vercel Supabase Clerk Full Stack Development](/claude-code-for-vercel-supabase-clerk-full-stack/)

Built by theluckystrike. More at [zovo.one](https://zovo.one)


**Find the right skill →** Browse 155+ skills in our [Skill Finder](/skill-finder/).

**Quick setup →** Launch your project with our [Project Starter](/starter/).
