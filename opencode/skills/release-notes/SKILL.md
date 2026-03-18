---
name: release-notes
description: Generate release notes for the current repo using gh CLI
---

**Read-only**: never push, create, or modify releases, tags, or any remote resource.

## Workflow

**1. Get the repo:**
```bash
gh repo view --json nameWithOwner -q .nameWithOwner
```

**2. List releases (newest first):**
```bash
gh release list --limit 20 --json tagName,publishedAt,isLatest --order desc
```

**3. List commits between a release and its previous release:**
```bash
git log <previous-tag>..<tag> --oneline
```

If there is no previous release, use the first commit as the base.

**4. Format:**

```
<release-tag>

- [commit message](https://github.com/{owner}/{repo}/commit/{full_sha})
```

- First line of commit message only, skip merge commits.
- Newest commits first.
- If the user asks for multiple releases, output each as a separate section, newest release first.
- Ask the user for the release label if not provided.
