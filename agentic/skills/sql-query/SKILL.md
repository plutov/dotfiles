---
name: sql-query
description: Write a SQL query aware of the current project's database schema
---

## Overview

Write a SQL query for the current project. Before writing any query, discover the schema from the project.

## 1. Discover the schema

Look for migrations in these locations (in order, stop when found):

```
migrations/
packages/db/migrations/
```

Read the migration files to understand table names, column names, and relationships.

**Knex projects**: relation/column names in code are camelCase, but actual database column names use underscores. Use the underscore form in SQL (e.g. `user_id`, not `userId`).

## 2. Write the query

Rules:
- Select only the columns necessary to answer the question — no `SELECT *`
- Always add `LIMIT` at the end (default: 100)
- Keep the query simple and readable

## 3. Output

Ask the user if they want output to a file or printed directly.

- **File**: write to `query.sql` in the current directory
- **Printed**: output the formatted SQL in a code block
