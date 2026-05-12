# Contributing

Thank you for contributing! Please follow these guidelines:

## Engine Version
All contributions must be compatible with **Godot 4.4**. When testing or running scripts from the CLI, ensure you are using the `godot4.4` command.

## Naming Conventions
- Use `snake_case` for all file names, directory names, variables, functions, and GDScript code.
- Node names in the Godot scene tree should use `PascalCase`.
- Class names in GDScript should use `PascalCase`.

## Pull Requests
- All changes must be submitted via Pull Requests.
- Use the following branch structure for your pull requests:
  - `feature/<feature-name>` for new features.
  - `bugfix/<bug-name>` for bug fixes.
  - `hotfix/<fix-name>` for urgent fixes.
- Ensure all CI checks (such as `gdlint` and exports) pass before requesting a review.
