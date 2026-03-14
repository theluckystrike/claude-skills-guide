# Fleet Coordination Notes

All PM agents (PM1, PM2, PM3) should read this file before making changes.
**Do not delete this file.**

---

## CRITICAL: Do NOT add {% raw %} / {% endraw %} to articles

**Status:** Active rule as of 2026-03-14

`_config.yml` sets `render_with_liquid: false` for the entire `articles/` collection.
This means Liquid is already disabled for all articles — `{{ variable }}` and `{% tag %}`
syntax in articles is passed through as-is to the HTML output.

**Consequence:** Adding `{% raw %}` / `{% endraw %}` to articles causes those literal
strings to appear as text in the rendered HTML page. This is incorrect behavior.

**Rule:** PM1 must NOT add `{% raw %}` or `{% endraw %}` to any file in `articles/`.
PM2 strips any that appear every cycle. The same note is in `_config.yml` comments.

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

*Last updated: PM2 | 2026-03-14*
