# ranger

Stock ranger plus archive handling and nvim as the editor. Ranger loads its own
default `rc.conf` first, so `rc.conf` here holds only the additions.

## Keybindings

| Key | Action |
|---|---|
| `ex` | `:extract` — unpack the marked archives, or the one under the cursor |
| `eb` | `:browse` — unpack to a temp dir and enter it |
| `ec` | Open the prompt as `:compress `, ready for a target name |

## Archives

**`:extract`** unpacks each archive into a directory named after it, next to
the archive — `a.tar.gz` becomes `a/` — so a tarball without a top-level
directory cannot spill into the current one. Several marked archives run in
turn.

**`:browse`** unpacks the archive under the cursor into
`/tmp/ranger-archive-XXXX` and `cd`s into it. It is read-only in effect:
edits there are not written back. The temp dirs are never cleaned up by
ranger; `/tmp` does that on reboot.

**`:compress <name.ext>`** packs the marked files, or the one under the
cursor, into `name.ext` in the current directory. The extension picks the
format.

| Format | Extract | Compress | Needs |
|---|---|---|---|
| `.tar` `.tar.gz` `.tgz` `.tar.bz2` `.tbz2` `.tar.xz` `.txz` `.tar.zst` `.tzst` | ✓ | ✓ | `tar` (and `zstd`, `xz`) |
| `.zip` | ✓ | ✓ | `unzip` / `zip` |
| `.gz` `.bz2` `.xz` `.zst` (single file) | ✓ | — | `gzip` `bzip2` `xz` `zstd` |
| `.7z` | ✓ | ✓ | `7z` or `7zz` |
| `.rar` | ✓ | — | `7z` or `7zz` |

`7z` is not in `packages.txt`. Without it, `.7z` and `.rar` report
"Unsupported archive (or 7z missing)" instead of failing quietly.

## Editor

rifle opens text files with `${VISUAL:-$EDITOR}`. `bash/.profile` exports
`EDITOR=nvim`, and `commands.py` sets the same default when ranger is started
from somewhere that never read `.profile`, so `nvim` is used either way.

## Files

```
~/.config/ranger/
├── rc.conf        the three archive keybindings
├── commands.py    :extract, :browse, :compress, and the EDITOR default
└── README.md
```
