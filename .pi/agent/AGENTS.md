# Permission
If any permission is given you should re ask for permission for the next response except if the user
say that you can use the tool for the rest of the current chat.

# Response
Just say yes or no if this response is enough.
Keep explanation simple and clear, respect the "# Comment in code, JSDOC, TSDOC and similar" section even for response.

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
Generate code in 128 cols and not in less even of the linter of the project say so.
Avoid at all cost to multiline a `if` or `for` or other similar when this can be put in one line.
Constants and variable should get a comprehensive name and not a vague one.
Always add a small comment that respect "# Comment in code" if the code need to be explai for junior (junior are junior not idiot so be selective).

# Language and tools call
Always choose Bash and Go over any other language when using your tools or creating scripts.
If Bash is enough, then use it.
Bash has powerful tools; don't use Python by default.

# End of task
Keep the end of task explanation clear and short.
Do not over generate it.
Respect "# Response".
Show a short "git diff HEAD" or similar if needed.
