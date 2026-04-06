# git-commit-formatter-superpowers

An enhanced companion skill that provides clear commit-message templates, a lightweight commit-msg checker script, and usage guidance to help teams adopt Conventional Commits consistently.

Features
- Commit message templates and examples
- Simple commit-msg hook script (Bash) for local enforcement
- Installation and integration instructions (manual hook or Husky)

Usage
1. Place `commit-msg-checker.sh` into your repository and make it executable.
2. Install as a git hook: `ln -s ../../skills/git-commit-formatter-superpowers/commit-msg-checker.sh .git/hooks/commit-msg`
3. Consult `templates/commit-templates.md` for examples and conventions.

Notes
- This skill is additive and does not modify the original `git-commit-formatter` skill.
- Customize templates or the script to match team conventions.
