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

function formatDailyNotes(notes) {
  if (!Array.isArray(notes) || notes.length === 0) {
    return "No daily notes found."
  }
  return notes
    .map(
      (note, i) =>
        `### ${i + 1}. ${note.name} (${note.day})\n**Week:** ${note.yearWeek} | **Workday:** ${note.isWorkday}\n` +
        (note.notes ? `**Notes:** ${note.notes}\n` : "") +
        `**Daily Win:** ${note.dailyWin}\n` +
        (note.workEffortRating != null ? `**Work Effort Rating:** ${note.workEffortRating}/5\n` : "") +
        `**Habits:**\n` +
        `- Work Startup Routine: ${note.htWorkStartupRoutine}\n` +
        `- Work Shutdown Routine: ${note.htWorkShutdownRoutine}\n` +
        `- Page A Day: ${note.htPageADay}\n` +
        `- Standing Desk: ${note.htStandingDesk}\n` +
        `- Daily Curls: ${note.htDailyCurls}\n` +
        `- Daily Push Ups: ${note.htDailyPushUps}\n` +
        (note.htConsecutiveFullPushUps != null ? `- Consecutive Full Push Ups: ${note.htConsecutiveFullPushUps}\n` : ""),
    )
    .join("\n---\n")
}

export const dailyNotes = tool({
  description: "Return Daily Notes",
  args: {
    yearWeek: tool.schema
      .string()
      .optional()
      .describe("ISO year-week to filter by (e.g. 2026-W27)"),
    from: tool.schema
      .string()
      .optional()
      .describe("Start date for range filter (YYYY-MM-DD, inclusive)"),
    to: tool.schema
      .string()
      .optional()
      .describe("End date for range filter (YYYY-MM-DD, inclusive)"),
  },
  async execute(args) {
    const params = new URLSearchParams()
    if (args.yearWeek) params.set("yearWeek", args.yearWeek)
    if (args.from) params.set("from", args.from)
    if (args.to) params.set("to", args.to)
    const qs = params.toString()
    const url = `http://localhost:8082/pkm/daily-notes/${qs ? `?${qs}` : ""}`

    const response = await fetch(url)

    if (!response.ok) {
      return `Failed to fetch daily notes: ${response.status} ${response.statusText}`
    }

    const notes = await response.json()
    return formatDailyNotes(notes)
  },
})

function formatWeeklyNotes(notes) {
  if (!Array.isArray(notes) || notes.length === 0) {
    return "No weekly notes found."
  }
  return notes
    .map(
      (note, i) =>
        `### ${i + 1}. Week ${note.week}\n` +
        (note.notes ? `**Notes:** ${note.notes}\n` : "") +
        (note.weeklySurprise ? `**Weekly Surprise:** ${note.weeklySurprise}\n` : "") +
        (note.weeklyReviewDuration != null ? `**Weekly Review Duration:** ${note.weeklyReviewDuration} min\n` : "") +
        (note.weeklyRefinementDuration != null ? `**Weekly Refinement Duration:** ${note.weeklyRefinementDuration} min\n` : "") +
        (note.htMusicNewAlbum ? `**New Album:** ${note.htMusicNewAlbum}\n` : "") +
        (note.htMusicOther ? `**Other Music:** ${note.htMusicOther}\n` : "") +
        (note.htMusicVariousComp ? `**Various Artists Compilation:** ${note.htMusicVariousComp}\n` : "") +
        (note.htMovieAtHome ? `**Movie at Home:** ${note.htMovieAtHome}\n` : "") +
        `**Habits:**\n` +
        `- Workout 1: ${note.htWorkout1}\n` +
        `- Workout 2: ${note.htWorkout2}\n` +
        `- Workout 3: ${note.htWorkout3}\n` +
        `- Educational Book: ${note.htEducationalBook}` +
        (note.htEducationalBookDuration != null ? ` (${note.htEducationalBookDuration} min)` : "") + "\n" +
        `- Blog Post: ${note.htBlog}` +
        (note.htBlogDuration != null ? ` (${note.htBlogDuration} min)` : "") + "\n",
    )
    .join("\n---\n")
}

export const weeklyNotes = tool({
  description: "Return Weekly Notes",
  args: {
    from: tool.schema
      .string()
      .optional()
      .describe("Start week for range filter (YYYY-Www, inclusive, e.g. 2026-W01)"),
    to: tool.schema
      .string()
      .optional()
      .describe("End week for range filter (YYYY-Www, inclusive, e.g. 2026-W26)"),
  },
  async execute(args) {
    const params = new URLSearchParams()
    if (args.from) params.set("from", args.from)
    if (args.to) params.set("to", args.to)
    const qs = params.toString()
    const url = `http://localhost:8082/pkm/weekly-notes/${qs ? `?${qs}` : ""}`

    const response = await fetch(url)

    if (!response.ok) {
      return `Failed to fetch weekly notes: ${response.status} ${response.statusText}`
    }

    const notes = await response.json()
    return formatWeeklyNotes(notes)
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
