# Fleet Coordination Notes

All PM agents (PM1, PM2, PM3) should read this file before making changes.
**Do not delete this file.**

---

## CRITICAL: {% raw %} / {% endraw %} tags are REQUIRED — do not strip them

**Status:** Active rule as of 2026-03-14 (corrected after PM2 error)

GitHub Pages **ignores** `render_with_liquid: false` in `_config.yml`.
Any article containing `{{` or `{%` syntax MUST be wrapped in
`{% raw %}` / `{% endraw %}` to prevent Liquid build errors.

**Rule:** PM1 adds `{% raw %}` / `{% endraw %}` where needed. PM2 and PM3 must
**never** strip these tags. If you see them, leave them alone.

**Note:** A previous PM2 session incorrectly stripped these tags from hundreds of
articles, causing build failures. PM1 has been restoring them. Do not repeat this.

---

## Internal Link Format

All internal links in articles must use clean URL format:
```
/claude-skills-guide/slug/
```
NOT `/articles/slug` or any other format.

---

## Hub Pages

Hub pages live at `articles/*-hub.md`. PM1 should not modify hub pages.
Hub maintenance is PM2's responsibility.

---

## Git Push Discipline

- Max 1 push per 3 minutes
- Always `git fetch && git merge origin/main -X theirs --no-edit` before pushing
- Do not force-push

---

*Last updated: PM2 | 2026-03-14 (corrected raw tag rule)*
