# TOOLS.md - Local Notes

## Skill formatting defaults

For every new or edited skill under `workspace/skills/`, keep `SKILL.md` in this normalized format to avoid load/parse issues:

- Save as `UTF-8` without BOM
- Use Unix newlines (`LF`) only
- No trailing whitespace at line ends
- End file with exactly one final newline
- Keep YAML frontmatter at the very top with exactly these fields only:
  - `name`
  - `description`
- Use this frontmatter shape exactly:

```md
---
name: skill-name
description: Clear trigger-oriented description of what the skill does and when to use it.
---
```

- Do not add extra frontmatter keys
- Keep heading/body markdown clean and consistent
- When "standardizing format", change formatting only; do not change meaning/content
- Before finishing any new skill or SKILL.md edit, do a final normalization pass for the rules above
