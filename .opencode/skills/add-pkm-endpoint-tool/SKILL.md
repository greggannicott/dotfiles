---
name: add-pkm-endpoint-tool
description: Add a new tool to the pkm tool family. User-invoked — type this name.
disable-model-invocation: true
---

## What I do

Given an existing go-bff collection endpoint, add a config to `pkm.ts` that registers a new tool using the `makeCollectionTool` factory.

The tools file lives at `~/.config/opencode/tools/pkm.ts` (symlinked from `dotfiles/opencode`).

## Steps

### 1. Ask clarifying questions

Ask the user for:

- **Endpoint path** — e.g. `/pkm/goals/`. The full path used when calling `curl http://localhost:8082{path}`.
- **Export name** — e.g. `goals` (the tool will be named `pkm_goals`). If the user isn't sure, suggest deriving it from the endpoint path.
- **Description** — the tool's help text, e.g. `"Return Goals"`. Suggest a default.
- **Query parameters** (if any) — name, type (`string` or `number`), and description for each.

**Completion criterion:** You have the endpoint path, export name, description, and any query params.

### 2. Read the go-bff readme

Read `~/code/go-bff/readme.md`. Find the section documenting the endpoint. Extract:

- Any **query parameters** the endpoint accepts (e.g. `yearWeek`, `from`, `to`)
- The **parameter types** — string or number

**Completion criterion:** You have the query params with types and descriptions.

### 3. Append the config to pkm.ts

Read `~/.config/opencode/tools/pkm.ts`. Append a `makeCollectionTool` call at the end:

```typescript
export const {exportName} = makeCollectionTool({
  name: "{Name}",
  endpoint: "{endpoint-path}",
  description: "{description}",
  queryParams: [
    { name: "{param}", type: "string", description: "{description}" },
  ],
})
```

Omit `queryParams` if the endpoint takes none.

**Completion criterion:** The file is saved with the new config appended.

### 4. Verify

Ask the user if they want to type-check the file. If they do, run:

```zsh
npx tsc --noEmit ~/.config/opencode/tools/pkm.ts
```

If type-checking fails, fix the issues and re-save.

**Completion criterion:** Type-check passes, or the user declines verification.
