---
name: export-memories
description: Bundle this project's Claude memory files into a tarball that can be carried out of a container or into another project. Use when the user asks to export, back up, or reuse memories, feedback files, or learned preferences, or when a devcontainer is about to be rebuilt and anything written to ~/.claude would be lost.
---

# Export memories

Memory files live at `~/.claude/projects/<sanitized-project-path>/memory/`. In a
devcontainer that path is usually **not** a mount, so it is destroyed on rebuild while the
workspace folder survives. This skill collects those files into a tarball written into the
workspace, where the user can actually reach it.

## Steps

**1. Run the bundler.**

```bash
bash ~/.claude/skills/export-memories/scripts/bundle.sh
```

It takes optional arguments: `bundle.sh [project-dir] [output-dir]`, both defaulting to the
current project. It prints the tarball path and a manifest classifying each file by its
frontmatter `type`, treating `feedback`, `user` and `reference` as portable and `project` as
not.

If it reports no memory directory, the project has no memories yet. Say so and stop. Do not
invent a directory.

**2. Do the judgment pass the script cannot.**

The script classifies by type only. Read each file the manifest marked portable and check
whether its body actually generalizes. A feedback file that names a specific repo, task
file, test or tool version is portable in principle but not as written.

Append a short `## Notes` section to the manifest inside the bundle naming those files and
what needs rewording, then rebuild the tarball. Be specific: "names this repo's task file
and boundary test, generalize to whatever the other project's checks are" is useful,
"may need editing" is not.

**3. Tell the user how to get it out.**

The tarball lands in the workspace root, so it appears in the editor's file explorer and can
be downloaded from there. Mention that it shows as untracked in git and can be deleted after
download.

`SendUserFile` also works and renders a download card in the conversation, but that card does
not appear in every client, so treat it as a second route rather than the only one. Note that
it routes the file through the conversation, which means it leaves the machine; say so rather
than sending silently.

## Do not

- Do not commit the tarball. It is a transport artifact, not project content.
- Do not strip or rewrite the source memory files. The export is a copy; the originals stay
  where the running session expects them.
- Do not claim a file was delivered because a tool reported success. Confirm the user can see
  it.
