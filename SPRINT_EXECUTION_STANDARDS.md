# Sprint Execution Standards

## The Sprint 10.2 Benchmark (2026-04-18)

Sprint 10.2 is the reference execution for what "done" looks like
in this project.

### What Made It 9.5/10

1. **Audit-driven scope** — responded to 5 criticals + 12 warnings with
   specific fixes, not ad-libbed improvements

2. **Ship order had dependency logic** — C2 (clean git) before
   anything else, C1 (revenue leak) second, C3 (risk of deleting
   funnel) required explicit preservation

3. **Every fix was commit-linked** — 38b3d40, 6838c5f, f8be910,
   fd6e382, ec443d7, git hygiene actions

4. **Verification against raw origin**, not just CDN — caught cache
   propagation delays

5. **Preserved revenue mechanisms** — C3 rewrote copy instead of
   deleting the email capture form (funnel preserved)

6. **Deferred warnings got documented**, not dropped — KNOWN_WARNINGS.md
   ensures W9-W12 don't get forgotten

7. **Git hygiene as first-class work** — 178 branches to 7 is months
   of technical debt paid down

### The Standards Going Forward

Every sprint touching layout/content/revenue paths must:

- Produce a commit log with 1:1 mapping between fixes and SHAs
- Include verification results (raw origin + CDN)
- Document deferred items in KNOWN_WARNINGS.md
- Pass QA_PLAYBOOK.md checklist before declaring complete
- Include "before/after" table for the changes made

### Anti-Patterns to Avoid

- "All done!" without commit hashes (Sprint 10.1 had this)
- Deploying without verifying HTTP 200 on affected pages
- Deleting revenue mechanisms while trying to fix copy issues
- Skipping git hygiene because "it's not blocking"
- Completing "90%" without documenting the 10% that's deferred
