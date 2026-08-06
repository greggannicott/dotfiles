import { tool } from "@opencode-ai/plugin"

const BFF_BASE = "http://localhost:8082"

interface QueryParamDef {
  name: string
  type: "string" | "number"
  description: string
}

interface CollectionConfig {
  name: string
  endpoint: string
  description: string
  queryParams?: QueryParamDef[]
}

const METADATA_KEYS = ["name", "path", "createdAt", "modifiedAt"]

function formatValue(value: unknown): string | null {
  if (value === null || value === undefined) return null
  if (typeof value === "string" && value === "") return null
  if (typeof value === "boolean") return value ? "Yes" : "No"
  if (typeof value === "string" || typeof value === "number") return String(value)
  if (Array.isArray(value)) {
    const formatted = value.map(formatValue).filter(Boolean)
    return formatted.length > 0 ? formatted.join(", ") : null
  }
  return null
}

function formatItem(item: Record<string, unknown>, index: number): string {
  const lines: string[] = []

  lines.push(`### ${index}. ${item.name || "Unknown"}`)

  for (const key of METADATA_KEYS) {
    if (key === "name") continue
    const value = formatValue(item[key])
    if (value) {
      const label =
        key === "createdAt"
          ? "Created"
          : key === "modifiedAt"
            ? "Modified"
            : key.charAt(0).toUpperCase() + key.slice(1)
      lines.push(`**${label}:** ${value}`)
    }
  }

  if (item.body) {
    lines.push("")
    lines.push(String(item.body))
  }

  const otherKeys = Object.keys(item).filter(
    (k) => !METADATA_KEYS.includes(k) && k !== "body",
  )
  if (otherKeys.length > 0) {
    lines.push("")
    for (const key of otherKeys) {
      const value = formatValue(item[key])
      if (value) {
        const label = key.charAt(0).toUpperCase() + key.slice(1)
        lines.push(`**${label}:** ${value}`)
      }
    }
  }

  return lines.join("\n")
}

function formatCollection(items: Record<string, unknown>[]): string {
  if (!Array.isArray(items) || items.length === 0) {
    return "No items found."
  }
  return items.map((item, i) => formatItem(item, i + 1)).join("\n---\n")
}

function makeCollectionTool(config: CollectionConfig) {
  const args: Record<string, any> = {}
  if (config.queryParams) {
    for (const param of config.queryParams) {
      if (param.type === "number") {
        args[param.name] = tool.schema
          .number()
          .optional()
          .describe(param.description)
      } else {
        args[param.name] = tool.schema
          .string()
          .optional()
          .describe(param.description)
      }
    }
  }

  return tool({
    description: config.description,
    args,
    async execute(rawArgs) {
      const params = new URLSearchParams()
      if (config.queryParams) {
        for (const param of config.queryParams) {
          const value = rawArgs[param.name]
          if (value != null) {
            params.set(param.name, String(value))
          }
        }
      }
      const qs = params.toString()
      const url = `${BFF_BASE}${config.endpoint}${qs ? `?${qs}` : ""}`

      const response = await fetch(url)
      if (!response.ok) {
        return `Failed to fetch ${config.name.toLowerCase()}s: ${response.status} ${response.statusText}`
      }

      const data = await response.json()
      return formatCollection(data)
    },
  })
}

export const journals = makeCollectionTool({
  name: "Journal",
  endpoint: "/pkm/journals/",
  description: "Return Journal entries",
  queryParams: [
    {
      name: "from",
      type: "string",
      description: "Start date for range filter (YYYY-MM-DD, inclusive)",
    },
    {
      name: "to",
      type: "string",
      description: "End date for range filter (YYYY-MM-DD, inclusive)",
    },
  ],
})

export const identities = makeCollectionTool({
  name: "Identity",
  endpoint: "/pkm/identities/",
  description: "Return Identities",
})

export const dailyNotes = makeCollectionTool({
  name: "Daily Note",
  endpoint: "/pkm/daily-notes/",
  description: "Return Daily Notes",
  queryParams: [
    {
      name: "yearWeek",
      type: "string",
      description: "ISO year-week to filter by (e.g. 2026-W27)",
    },
    {
      name: "from",
      type: "string",
      description: "Start date for range filter (YYYY-MM-DD, inclusive)",
    },
    {
      name: "to",
      type: "string",
      description: "End date for range filter (YYYY-MM-DD, inclusive)",
    },
  ],
})

export const weeklyNotes = makeCollectionTool({
  name: "Weekly Note",
  endpoint: "/pkm/weekly-notes/",
  description: "Return Weekly Notes",
  queryParams: [
    {
      name: "from",
      type: "string",
      description:
        "Start week for range filter (YYYY-Www, inclusive, e.g. 2026-W01)",
    },
    {
      name: "to",
      type: "string",
      description:
        "End week for range filter (YYYY-Www, inclusive, e.g. 2026-W26)",
    },
  ],
})

export const goals = makeCollectionTool({
  name: "Goal",
  endpoint: "/pkm/goals/",
  description: "Return Goals",
})

export const apps = makeCollectionTool({
  name: "App",
  endpoint: "/pkm/apps/",
  description: "Return Apps",
})

function todayString() {
  const d = new Date()
  const yyyy = d.getFullYear()
  const mm = String(d.getMonth() + 1).padStart(2, "0")
  const dd = String(d.getDate()).padStart(2, "0")
  return `${yyyy}-${mm}-${dd}`
}

export const journalLastDays = tool({
  description: "Return Journal entries for last number of days",
  args: {
    days: tool.schema
      .number()
      .int()
      .positive()
      .describe("Number of days to include, counting back from today inclusively"),
  },
  async execute(args) {
    const to = todayString()
    const fromDate = new Date()
    fromDate.setDate(fromDate.getDate() - (args.days - 1))
    const yyyy = fromDate.getFullYear()
    const mm = String(fromDate.getMonth() + 1).padStart(2, "0")
    const dd = String(fromDate.getDate()).padStart(2, "0")
    const from = `${yyyy}-${mm}-${dd}`

    const url = `${BFF_BASE}/pkm/journals/?from=${from}&to=${to}`
    const response = await fetch(url)

    if (!response.ok) {
      return `Failed to fetch journal entries: ${response.status} ${response.statusText}`
    }

    const entries = await response.json()
    return formatCollection(entries)
  },
})

export const schemaDiscovery = tool({
  description: "List all available PKM collection endpoints and their schemas",
  args: {},
  async execute() {
    const response = await fetch(`${BFF_BASE}/pkm/schema`)

    if (!response.ok) {
      return `Failed to fetch schema: ${response.status} ${response.statusText}`
    }

    const schemas = await response.json()

    if (!Array.isArray(schemas) || schemas.length === 0) {
      return "No collection endpoints found."
    }

    const lines = schemas.map(
      (s: Record<string, string>, i: number) =>
        `### ${i + 1}. ${s.name}\n**Collection:** ${s.collection}\n**Schema:** ${s.schema}`,
    )

    return lines.join("\n---\n")
  },
})

export const traits = makeCollectionTool({
  name: "Trait",
  endpoint: "/pkm/traits/",
  description: "Return Traits",
})
