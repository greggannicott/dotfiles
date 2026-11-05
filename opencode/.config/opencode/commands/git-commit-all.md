---
description: Commit all git changes, whether staged or not
---

- Generate commit for all changes, regardless of whether they are staged, unstaged or untracked
- Stage all changes (including untracked files) before committing
- Use the convention "{JIRA ID}: {summary of change}" for the summary.
- Determine Jira ID by looking at branch name. eg. "IS-12345-my-feature" is "IS-12345".
- If there is no Jira ID, use the Conventional Commits pattern (eg. feat, bug etc)
- Use recent commits to guide how to write commit.
- Ask clarifying questions if there are no changes

ALWAYS PROMPT TO CONFIRM MESSAGE IS OK
