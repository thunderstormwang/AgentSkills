---
name: file-translator
description: Precisely translates specified file content into Traditional Chinese. Trigger this skill when the user asks to "translate a file," "translate a file to Chinese," or "convert this file to Traditional Chinese." This skill ensures accurate and complete translation and automatically handles file storage.
---

# file-translator

A specialized skill for file content translation, focusing on precision, completeness, and automation.

## Workflow

When a translation command is received, strictly execute the following steps:

1. **Read Source File:** Use `read_file` to read the content of the file specified by the user.
2. **Precise Translation:**
    - Translate the content into **Traditional Chinese**.
    - Maintain "word-for-word" accuracy with precise and natural grammar.
    - **Strictly Prohibited:** Do not modify the original file content.
    - Comments within code blocks should be translated if requested by the user, while the code itself remains unchanged.
3. **Save New File:**
    - Output path: `{OriginalPath}/{OriginalFileName}_Cht.{OriginalExtension}`.
    - If the target file already exists, **overwrite** it directly.
    - Use `write_file` to save the translated content.

## Guidelines
- Ensure the translated Markdown formatting is identical to the original (headers, lists, tables, links, etc.).
- If technical terms lack suitable Traditional Chinese equivalents, keep the original English or provide it in parentheses.
