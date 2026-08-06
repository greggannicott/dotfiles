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

- **Collection item name** — the note type to create a tool for, always singular and lowercase, e.g. `identity`, `goal`, `song`, `journal`, `daily note`.

From the item name, derive:

- **Endpoint path** — `/pkm/{name}/`, always using the plural form (e.g. `identity` → `/pkm/identities/`, `daily note` → `/pkm/daily-notes/`).
- **Export name** — plural, camelCase for multi-word names (e.g. `identity` → `identities`, `daily note` → `dailyNotes`). The tool will be named `pkm_{exportName}`.
- **Name** — singular, heading case, each word capitalised (e.g. `identity` → `Identity`, `daily note` → `Daily Note`).
- **Description** — default to `"Return {Plural Name}"` (e.g. `"Return Identities"`), but let the user override.

Verify the endpoint exists by fetching the schema from `http://localhost:8082/pkm/schema` (use the `pkm_schemaDiscovery` tool). Confirm the derived endpoint is listed before proceeding.

Present the derived endpoint and export name as a confirmation. For the description, offer the default pre-filled with a "Custom description" option.

Also ask about **query parameters** (if any) — name, type (`string` or `number`), and description for each.

**Completion criterion:** The user has confirmed the endpoint, name, and description, and any query params are known.

### 2. Read the go-bff readme

Read `~/code/go-bff/readme.md`. Find the section documenting the endpoint. Extract any **query parameters** the endpoint accepts — for each, note the name, type (`string` or `number`), and description.

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
