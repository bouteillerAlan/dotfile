# Permission
Ask again only before a new destructive, external, or privileged action.

# Response
For a direct binary question, start with `yes` or `no`, then give a concise plan or explanation unless the user asks for only the answer.
For completed tasks, state changed files and checks in one short sentence.
Keep explanation simple and clear, respect the "# Comment in code, JSDOC, TSDOC and similar" section even for response.

Explain both the error and its fix. For example:

> `nvim` is an undefined global, so LuaLS cannot find the API signature through `N`.
> Use `vim.api`, which is Neovim's typed global: `local N = vim.api`.

# Comment in code, JSDOC, TSDOC and similar

Never overwrite existing comments without preserving their intent. Use short phrases and clear prose.
Never over complicate any sentence. Don't take the user for an idiot.
You aim for short and comprehensive text.

Example:

Bad:
```lua
-- Attached LSP client name instead of the full filetype word,
-- truncated to 6 chars -- "typescript" is long, "tsc" isn't.
-- Several clients can attach to one buffer (formatter, linter,
-- spell-checker, ...); only the actual language server tends to
-- support go-to-definition, so that's preferred over "just take the
-- first one", which could as easily be a spell-checker. Falls back
-- to the filetype when nothing matches.
```

Good:
```lua
-- lsp client name instead of the filetype
-- if multiple lsp is found we take the one that support "go-to-definition"
-- if none we use the filetype
```

# Scope and verification

Read project instructions before editing.
Make the smallest change that solves the request.
Run relevant checks after changes when they do not create resources.
State which checks ran and any that could not run.

# Ambiguity and destructive actions

Ask when requirements are ambiguous or a change may delete, overwrite, or expose user data.
Do not modify generated files unless the user explicitly asks.

# Git, GitHub, Gitlab or similar

Never use a git related tool without asking for the user permission first.

# Docker, Podman, Docker Compose, K8S, Terraform, Pulumi or other related CLI

Never use a CLI that can launch an actual resource without asking for the user permission first.
But you can use the CLI to check spell or lsp on your own.

# Code in general
Separate code by purpose.
Always prefer native solution in place of complex one (eg: for a simple for in react if the form html event is enough we use it in place of the useState form, but that must be a thoughtful choice not an obligation because of this rule).
In React or relative framework each part of the UI should be a component.
Keep code lines at 128 characters or fewer.
Use one-line control flow only when it stays clear and within the line limit.
Constants and variables should have comprehensive names.
Add a short comment only when the code needs context a junior developer would not infer.

# Language and tools call
Prefer Bash for shell tasks and Go for repository tools.
Do not use Python when Bash is sufficient.

# End of task
Keep the end of task explanation clear and short.
Do not over generate it.
Respect "# Response".
