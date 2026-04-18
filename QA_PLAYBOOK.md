# CCG QA Playbook

Every sprint that modifies homepage, layouts, CTAs, or conversion
infrastructure must pass this checklist before declaring completion.

## Pre-Deploy Checks (Any Sprint Touching Layout/Content)

### 1. Dead Content Check
- [ ] No "Coming Soon" text anywhere on site (homepage, articles, generator)
- [ ] No placeholder text ("TODO", "[placeholder]", "lorem ipsum")
- [ ] No "Beehiiv" or other old newsletter provider references
- [ ] Stale footer categories removed (Chrome Tips, Security Tools, etc.)

### 2. Structural Integrity Check
- [ ] Exactly 1 `<footer>` tag per page (not stacked)
- [ ] Exactly 1 `<header>` / nav per page
- [ ] Nav consistency: generator, homepage, articles all show same nav links
- [ ] No duplicate sections (e.g., two Offer blocks)

### 3. Revenue Path Check (Critical)
- [ ] All CTA links return HTTP 200
- [ ] Primary revenue CTAs tested in browser (not just curl)
- [ ] Generator form submits successfully with real email
- [ ] Community CTA loads Stripe checkout
- [ ] Lifetime CTA loads Stripe checkout or valid landing page

### 4. Accessibility Check (WCAG AA)
- [ ] Text/background contrast >= 4.5:1 (normal text)
- [ ] Text/background contrast >= 3:1 (large text, UI components)
- [ ] Keyboard navigation works for all interactive elements
- [ ] Skip link present and functional
- [ ] All images have alt text

### 5. SEO Hygiene Check
- [ ] Exactly 1 WebSite JSON-LD schema block
- [ ] Exactly 1 Organization schema block
- [ ] Canonical URLs set correctly
- [ ] og:* and twitter:* meta tags present
- [ ] Title tags under 60 chars, descriptions under 155 chars

### 6. Git Hygiene Check
- [ ] `git status` is clean (no staged uncommitted files)
- [ ] Current branch is main (or appropriate release branch)
- [ ] No unintended files in staging
- [ ] Commits have descriptive messages (not "wip" or "fix")

### 7. Cross-Environment Check
- [ ] Raw origin response matches CDN response (once cache propagates)
- [ ] Mobile (375px) renders correctly
- [ ] Tablet (768px) renders correctly
- [ ] Desktop (1440px) renders correctly

## Post-Deploy Verification

After push, wait for CDN propagation (~15 min), then:

1. Run all curl checks against live domain
2. Visit homepage in incognito browser
3. Click every CTA, verify destination loads
4. Submit generator form with real email, verify delivery
5. Test on real mobile device (not just devtools)

## Automatic Failures

Sprint is NOT complete if any of these fail:
- Any CTA returns 404
- Any revenue form silently fails (submits but doesn't persist)
- Accessibility contrast below 4.5:1
- Build status red
- Git state has uncommitted work from "finished" sprint

## Standing Issues (Logged, Not Blocking)

See KNOWN_WARNINGS.md for deferred items.
