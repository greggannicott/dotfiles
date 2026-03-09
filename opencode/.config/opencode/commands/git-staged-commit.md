---
description: Commit staged git changes
---

- Generate commit for staged changes
- Use the convention "{JIRA ID}: {summary of change}" for the summary.
- Determine Jira ID by looking at branch name. eg. "IS-12345-my-feature" is "IS-12345".
- If there is no Jira ID, use the Conventional Commits pattern (eg. feat, bug etc)
- Use recent commits to guide how to write commit.
- Ask clarifying questions if no files are staged

ALWAYS PROMPT TO CONFIRM MESSAGE IS OK
