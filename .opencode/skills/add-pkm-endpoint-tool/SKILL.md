---
name: add-pkm-endpoint-tool
description: Add a new tool to the pkm tool family. User-invoked — type this name.
disable-model-invocation: true
---

## What I do

Given an existing go-bff API endpoint, append a new named-export tool to `pkm.ts` that fetches JSON from the endpoint and returns formatted Markdown.

The tools file lives at `~/.config/opencode/tools/pkm.ts` (symlinked from `dotfiles/opencode`).

## Steps

### 1. Ask clarifying questions

Ask the user for:

- **Endpoint path** — e.g. `/pkm/goals/`. The full path used when calling `curl http://localhost:8082{path}`.
- **Export name** — e.g. `goals` (the tool will be named `pkm_goals`). If the user isn't sure, suggest deriving it from the endpoint path.
- **Description** — the tool's help text, e.g. `"Return Goals"`. Suggest a default.

**Completion criterion:** You have the endpoint path, export name, and description.

### 2. Read the go-bff readme

Read `~/code/go-bff/readme.md`. Find the section documenting the endpoint. Extract:

- Any **query parameters** the endpoint accepts (e.g. `yearWeek`, `from`, `to`)
- The **response field table** — each row gives a field name, type, and description
- The **identifier field** — the primary label for each item (e.g. `name`, `week`, `title`)

**Completion criterion:** You have the query params, full field list with types, and the identifier field.

### 3. Read the existing tool file

Read `~/.config/opencode/tools/pkm.ts`. Study the pattern exactly:

- Import (`import { tool } from "@opencode-ai/plugin"`)
- A `format{Name}()` function per tool — maps JSON fields to Markdown
- Nullable fields use `!= null` guards
- Array fields use `?.length` checks and `.join(", ")`
- Boolean fields shown unconditionally
- The `tool({ description, args, async execute() })` call
- Query params built with `new URLSearchParams()`
- Error handling: `if (!response.ok)` returns an error string
- Response parsed with `await response.json()` and passed to the format function
- Indentation, semicolons, template literals

**Completion criterion:** You can reproduce the style exactly.

### 4. Design and confirm the formatting

Each item should render as Markdown in this shape:

```
### {N}. {identifier}
**{FieldLabel}:** {value}
...
```

Follow the existing conventions:
- Group related fields under a subheading like `**Habits:**` with bullet points when the readme organises them as a group
- Show nullable fields only when non-null, using `!= null`
- Show arrays only when non-empty, using `?.length`
- Show boolean and string fields unconditionally
- Use `\n` inside template literals for line breaks within the item block
- Join items with `"\n---\n"` (as the existing tools do)

Present your proposed formatting to the user and ask for confirmation. If the user suggests changes, iterate until confirmed.

**Completion criterion:** The user confirms the formatting.

### 5. Append the tool to pkm.ts

Edit `~/.config/opencode/tools/pkm.ts`. Append at the end of the file:

1. A `format{Name}()` function that maps a single item to a Markdown string (following the confirmed design)
2. A named export using `tool()` with the specified name, description, args, and execute function

The execute function should:
```
async execute(args) {
  const params = new URLSearchParams()
  // set query params if applicable
  const qs = params.toString()
  const url = `http://localhost:8082{endpoint-path}${qs ? `?${qs}` : ""}`
  const response = await fetch(url)
  if (!response.ok) {
    return `Failed to fetch: ${response.status} ${response.statusText}`
  }
  const data = await response.json()
  return format{Name}(data)
}
```

**Completion criterion:** The file is saved with the new tool appended.

### 6. Verify

Ask the user if they want to type-check the file. If they do, run:

```zsh
npx tsc --noEmit ~/.config/opencode/tools/pkm.ts
```

If type-checking fails, fix the issues and re-save.

**Completion criterion:** Type-check passes, or the user declines verification.
