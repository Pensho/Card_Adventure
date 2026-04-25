# CLAUDE.md — Card Adventure

This file instructs Claude on conventions, constraints, and workflow for this project.

## Project Overview

A 2D card-based game built in Godot 4. See `docs/GDD.md` for design and `docs/TDD.md` for architecture.

## GDScript Conventions

- Use `snake_case` for variables, functions, and file names
- Use `PascalCase` for class names and node names
- Prefer signals over direct calls for cross-node communication
- Always type-hint variables and function signatures
- Keep scripts focused — one responsibility per script

## Folder Structure

```
res://
├── assets/         # Art, audio (organized by type)
│   ├── cards/
│   ├── ui/
│   └── audio/
├── scenes/         # .tscn files, mirroring scripts/ structure
│   ├── cards/
│   ├── ui/
│   └── game/
├── scripts/        # .gd files
│   ├── cards/
│   ├── ui/
│   ├── game/
│   └── data/
├── tests/          # GUT test files (test_*.gd)
├── docs/           # Design and planning documents
└── addons/         # GUT and other plugins
```

## Testing

- Use the GUT framework for all automated tests
- Test files go in `tests/`, named `test_<feature>.gd`
- Test pure logic (card effects, game state); do not test rendering or node trees directly
- Write tests before or alongside implementation, not after

## AI / Claude Workflow

- Check `docs/GDD.md` before implementing any feature — if it's not there, ask first
- Check `docs/TDD.md` for architecture decisions before proposing a new pattern
- Do not add features beyond what the GDD specifies
- Do not refactor unless asked
- When creating art prompts for leonardo.ai, follow `docs/ART_STYLE.md`

## Git

- Commit messages: short imperative sentence, e.g. `Add card draw mechanic`
- Commit messages: do not include any Co-Authored-By section
- One logical change per commit
- Do not commit `.godot/` or generated files

## Keeping project docs current

- After completing work, update `docs/MILESTONES.md`: mark finished items `[x]`, set the current milestone, and update the date
- If a TDD or GDD decision changes during implementation, update the relevant doc before committing
