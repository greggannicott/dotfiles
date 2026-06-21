import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Return Journal entries",
  args: {},
  async execute() {
    const response = await fetch("http://localhost:8082/pkm/journals/")

    if (!response.ok) {
      return `Failed to fetch journal entries: ${response.status} ${response.statusText}`
    }

    const entries = await response.json()

    if (!Array.isArray(entries) || entries.length === 0) {
      return "No journal entries found."
    }

    return entries
      .map(
        (entry, i) =>
          `### ${i + 1}. ${entry.title}\n**Date:** ${entry.date}\n**Topics:** ${entry.topics?.length ? entry.topics.join(", ") : "None"}\n**Body:** ${entry.body}\n**Reflected:** ${entry.reflected}\n**Inbox:** ${entry.inbox}\n`,
      )
      .join("\n")
  },
})
