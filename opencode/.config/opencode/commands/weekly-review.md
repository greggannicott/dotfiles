---
description: Review the week's journals and experiments.
---

You're inside my PKM.

I want you to review my week for me.

Consider the following when performing the review:

- Journal Notes (the past 10 days)
- Experiment Reviews
- Identities
- Traits

Details on how to obtain these can be found below.

The outcome of this should be a new note in the PKM named `{yyyy-%V}-ai-weekly-review.md`. `%V` should represent the week number, padded with a zero.

This should be in the root directory.

Use the template `_templates/AI Weekly Review.md` as the basis for the review.

Populate the frontmatter `week-number` with `{yyyy-ww}` (a computed value).

Populate the following sections:

- Review: Your thoughts on my week. Don't re-iterate what happened but look for insights. By reading this I should have an idea of your thinking behind what you suggest in actions. Break it down into readable paragraphs. Feel free to use subheadings. Try to keep sections brief.
- Actions. Use checkboxes for each item in the sub sections. The title of the action should be at the checkbox level. Notes related to the checkbox (eg. your reasoning, what I can gain etc) should be sub-bullets.
  - Potential Tasks: Tasks I could create to act on your review. Don't extract things I say should be done. Instead look for insights and suggest things to me. _Among other things_, consider how AI can be used to achieve or augment things, what processes and frameworks can I put in place. Inspire me with some ideas!
  - Experiments: Some new experiments I could start. Again, inspire me. Don't just extract ideas I have.
  - Application, Script and Project Ideas: Off the back of your review, any new application, script or just general project ideas? You can see my existing ideas by looking at the 'App and Script Ideas.md' note.
  - Blog Posts: Potential blog posts that could be written based on my week.

# How To Obtain Required Information

Use the `obsidian-markdown` skill to query the PKM vault files.

## Journal Notes

Journal Notes are notes I am randomly create throughout the week whenever I might have a thought that may be worth noting down. It helps me to get things out of my brain and as something to reflect on later on.

Use the pkm tool to obtain journal notes for the last 10 days.

## Experiment Reviews

Experiments represent personal experiments I am either considering trying, currently tried or have tried.

Experiments follow the pattern "title.md"" in the root directory with frontmatter categories: [\"[[Experiment]]\"].

Experiments are ongoing when they have a `started` property but `ended` is empty. grep for started: in frontmatter and confirm ended: is absent or empty.

To read my own personal review of this experiment for the week, find the "Weekly Reviews" sectionfor each experiment. Within this is a "Reviews" section.

Each high level bullet represents a week. The week number is formatted `{yyyy-ww} - {Brief summary}`

Sub bullets are my thoughts.

## Identities

Identities represent either the person I am or the kind of person I want to be. Use this information to guide your suggestions. Don't review the identities though. I don't want feedback on them or their notes.

Use the pkm tool to obtain all identities.

## Traits

Traits are things about people I either consider a good or bad thing.

Traits follow the pattern "title.md"" in the root directory with frontmatter categories: [\"[[Trait]]\"].

Each note represents a trait.

The frontmatter `trait-type` indicates whether I consider it a good or bad trait.
