# Git Commit Formatter Skill

Purpose
- Provide guidelines and examples for formatting git commit messages according to Conventional Commits and project conventions.

Scope
- Explain required commit structure, allowed types, scopes, header/body/footer rules, line length, and examples.

Commit Message Rules
- Header format: <type>(<scope>): <short summary>
- Types: feat, fix, docs, style, refactor, perf, test, chore, ci, build
- Scope: optional, lowercase, no spaces, e.g., cli, config, tests
- Summary: imperative mood, max 72 characters, no trailing period
- Body: optional, wrap at 100 chars, explain what and why (not how)
- Footer: optional, for issues or breaking changes; Breaking change: use "BREAKING CHANGE: <description>" in footer

Templates
- Basic: feat(cli): add interactive prompt for commit type
- With body:
  feat(config): support custom templates

  - Adds support for user-defined templates to standardize commit messages.

Examples
- feat(api): add user authentication endpoint
- fix(auth): correct token refresh logic
- docs(readme): update contributing guide
- chore(release): bump version to 1.2.0

Usage Guidelines
- Use Conventional Commits for changelog automation and semantic versioning.
- Keep headers concise; use body for rationale and non-obvious details.
- Include issue references in footer: "Closes #123".

Formatting Checklist
- [ ] Header follows <type>(<scope>): <summary>
- [ ] Summary <= 72 chars, imperative
- [ ] Body wrapped at 100 chars
- [ ] Footer contains issues or breaking changes if applicable

Authoring
- This SKILL.md is written in English. Provide examples and templates that are copy-paste ready.

Maintainers can update this v2 file without modifying the original skill.
