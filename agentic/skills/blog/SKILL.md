---
name: blog
description: Manage personal blog built with GoHugo
---

## Overview

Personal blog management for `~/code/pliutau.com`.

- Engine: [GoHugo](https://gohugo.io)
- Repo: `~/code/pliutau.com`
- Content lives in `~/code/pliutau.com/content/` as Markdown files

## Writing posts

New posts are Markdown files in `content/`. Hugo front matter uses TOML (`+++` delimiters).

Minimal front matter example:

```toml
+++
title = "Article title"
date = "2025-09-03T11:00:00+02:00"
type = "post"
tags = ["golang"]
og_image = "/gopher.png"
+++
```

Ask the user the following:
- Provide the og_image if needed

## Reading list / RSS feeds

Blogs I follow are registered in `rss_generator/main.go` as entries in the `feeds` slice:

```go
var feeds = []RSSFeed{
    {URL: "https://example.com/feed.xml", Name: "Example Blog"},
    ...
}
```

To add a new blog to follow, append an entry to that slice with its RSS/Atom feed URL and a short display name.

The RSS generator is run via GitHub Actions daily and writes `content/reading-list.md`.

## Design

It uses the theme `themes/anatole` the files can be updated directly there.

## Common tasks

- **New post**: create `content/<slug>.md` with TOML front matter
- **Preview locally**: `cd ~/code/pliutau.com && hugo server`
- **Add blog to follow**: edit `rss_generator/main.go`, add to `feeds`
