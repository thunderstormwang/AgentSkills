# Commit Message Templates (Conventional Commits)

Rules
- Format: type(scope?): subject
- type: feat|fix|docs|style|refactor|perf|test|chore
- scope: optional, alphanumeric, dash/underscore allowed
- subject: brief, present-tense, no trailing period

Examples
- feat(parser): add support for multi-line headers
- fix(api): handle null response for 204 status
- docs(readme): update installation instructions
- chore(deps): bump lodash to 4.17.21

Guidance
- Use imperative mood: "add", "fix", "remove"
- Keep subject <= 72 chars when possible
- Use body (blank line then paragraph) for motivation and details
