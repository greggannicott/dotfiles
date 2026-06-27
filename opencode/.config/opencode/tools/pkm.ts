import { tool } from "@opencode-ai/plugin"

function formatJournalEntries(entries) {
  if (!Array.isArray(entries) || entries.length === 0) {
    return "No journal entries found."
  }
  return entries
    .map(
      (entry, i) =>
        `### ${i + 1}. ${entry.title}\n**Date:** ${entry.date}\n**Topics:** ${entry.topics?.length ? entry.topics.join(", ") : "None"}\n**Body:** ${entry.body}\n**Reflected:** ${entry.reflected}\n**Inbox:** ${entry.inbox}\n`,
    )
    .join("\n")
}

function todayString() {
  const d = new Date()
  const yyyy = d.getFullYear()
  const mm = String(d.getMonth() + 1).padStart(2, "0")
  const dd = String(d.getDate()).padStart(2, "0")
  return `${yyyy}-${mm}-${dd}`
}

export default tool({
  description: "Return Journal entries",
  args: {},
  async execute() {
    const response = await fetch("http://localhost:8082/pkm/journals/")

    if (!response.ok) {
      return `Failed to fetch journal entries: ${response.status} ${response.statusText}`
    }

    const entries = await response.json()

    return formatJournalEntries(entries)
  },
})

function formatIdentities(identities) {
  if (!Array.isArray(identities) || identities.length === 0) {
    return "No identities found."
  }
  return identities
    .map(
      (identity, i) =>
        `### ${i + 1}. ${identity.name}\n**Aspirational:** ${identity.aspirational}\n**Topics:** ${identity.topics?.length ? identity.topics.join(", ") : "None"}\n\n${identity.perfectVersion}\n`,
    )
    .join("\n---\n")
}

export const identities = tool({
  description: "Return Identities",
  args: {},
  async execute() {
    const response = await fetch("http://localhost:8082/pkm/identities/")

    if (!response.ok) {
      return `Failed to fetch identities: ${response.status} ${response.statusText}`
    }

    const data = await response.json()

    return formatIdentities(data)
  },
})

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

    const response = await fetch(`http://localhost:8082/pkm/journals/?from=${from}&to=${to}`)

    if (!response.ok) {
      return `Failed to fetch journal entries: ${response.status} ${response.statusText}`
    }

    const entries = await response.json()
    return formatJournalEntries(entries)
  },
})
