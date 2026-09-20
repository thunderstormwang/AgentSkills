# Junction vs. SymbolicLink vs. HardLink

`SKILL.md`'s Link Manifest uses two kinds of links — a directory Junction on Windows, a
SymbolicLink everywhere else and for every file. This explains why.

None of the three is a sync mechanism. There is only one copy of the data; you're accessing the
same thing through two names, so "editing one side changes the other" is true, but the reason
isn't syncing — there simply is no "other side."

## What a directory entry actually stores

There are two separate things on disk:

- The **file content** lives in one record (an MFT record on NTFS, an inode on Linux/macOS).
- The **filename** inside a folder is just a directory entry recording what it points to.

| | What the entry stores | Applies to | Needs admin | When the target is deleted |
|---|---|---|---|---|
| **Junction** | The target **path** (absolute, local machine only) | Directories only | No | Link breaks |
| **SymbolicLink** | The target **path** (can be relative, can be UNC) | Files + directories | Yes, for files | Link breaks (dangling) |
| **HardLink** | The **file body** on disk (the MFT record) | Files only, same volume | No | Data stays alive |

A **HardLink**'s extra filename is of the exact same kind as the original one — the OS can't
tell which was created first; there's no "original vs. alias" distinction. The record keeps a
**reference count**: 2 with two names, drops to 1 (data still alive) when one name is removed,
and only reaches 0 — actually freeing the space — once both are gone.

**Symlink / Junction** store a string of path text and **hold no data of their own**. Every
access, the OS resolves that path string **at that moment**, then opens the real file.

Think of it as keys:

- **HardLink** = two keys cut for the same room, fully equivalent; as long as one key exists,
  the room stays.
- **Symlink** = a note with an address written on it. The note isn't the room. If the house is
  torn down, the note still exists, but following it leads nowhere.

## When a link breaks

Many installers and editors don't edit a file in place — they **"write a new temp file, then
rename it over the target"** — which produces a brand-new file body. Which side gets replaced
this way decides the outcome:

| Side replaced by "write new file + rename over it" | HardLink | Symlink / Junction |
|---|---|---|
| The **target** side (e.g. `repo\CLAUDE.md`) | Breaks | **Stays intact** |
| The **link** side (e.g. `~\.claude\CLAUDE.md`) | Breaks | Breaks |

A symlink is bound to a path — it works as long as something exists at that path, regardless of
whether it's the same file body. A HardLink is bound to a fixed record number — a new file means
a new record, so it breaks no matter which side gets replaced.
