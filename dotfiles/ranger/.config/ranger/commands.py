import os
import shutil
import tempfile

# ranger is the apt package, importable only from inside ranger itself.
from ranger.api.commands import Command  # type: ignore[import-not-found]
from ranger.core.loader import CommandLoader  # type: ignore[import-not-found]

# rifle opens text files with ${VISUAL:-$EDITOR}, and a ranger started outside
# a login shell has neither.
os.environ.setdefault("EDITOR", "nvim")

TAR_SUFFIXES = (".tar", ".tar.gz", ".tgz", ".tar.bz2", ".tbz2", ".tar.xz",
                ".txz", ".tar.zst", ".tzst")
SINGLE_FILE_TOOLS = {".gz": "gzip", ".bz2": "bzip2", ".xz": "xz", ".zst": "zstd"}


def _suffix(name, candidates):
    return next((s for s in candidates if name.lower().endswith(s)), None)


def _stem(name):
    suffix = _suffix(name, TAR_SUFFIXES + (".zip", ".7z", ".rar")
                     + tuple(SINGLE_FILE_TOOLS))
    return name[:-len(suffix)] if suffix else name


def _extract_argv(archive, dest):
    name = os.path.basename(archive)
    if _suffix(name, TAR_SUFFIXES):
        return ["tar", "-xf", archive, "-C", dest]
    if name.lower().endswith(".zip"):
        return ["unzip", "-q", archive, "-d", dest]
    if name.lower().endswith((".7z", ".rar")):
        sevenzip = shutil.which("7zz") or shutil.which("7z")
        return [sevenzip, "x", "-y", "-o" + dest, archive] if sevenzip else None
    suffix = _suffix(name, SINGLE_FILE_TOOLS)
    if suffix:
        out = os.path.join(dest, name[:-len(suffix)])
        tool = SINGLE_FILE_TOOLS[suffix]
        return ["sh", "-c", f'{tool} -dc -- "$0" > "$1"', archive, out]
    return None


class _ArchiveCommand(Command):
    def _extract(self, archive, dest=None):
        """Extract into dest, or into a fresh temp dir that is then entered."""
        if _extract_argv(archive, "") is None:
            self.fm.notify("Unsupported archive (or 7z missing): "
                           + os.path.basename(archive), bad=True)
            return
        enter = dest is None
        if enter:
            dest = tempfile.mkdtemp(prefix="ranger-archive-")
        os.makedirs(dest, exist_ok=True)
        loader = CommandLoader(_extract_argv(archive, dest),
                               "extracting " + os.path.basename(archive),
                               read=True)
        if enter:
            loader.signal_bind("after", lambda _s: self.fm.cd(dest))
        else:
            loader.signal_bind("after", lambda _s: self.fm.thisdir.load_content())
        self.fm.loader.add(loader)


class extract(_ArchiveCommand):
    """:extract

    Extract the marked archives, or the one under the cursor, each into a
    directory named after it next to the archive.
    """

    def execute(self):
        files = self.fm.thistab.get_selection()
        for f in files:
            self._extract(f.path, os.path.join(self.fm.thisdir.path,
                                               _stem(f.basename)))


class browse(_ArchiveCommand):
    """:browse

    Extract the archive under the cursor into a temporary directory and enter
    it. Read-only: changes made there are not written back to the archive.
    """

    def execute(self):
        self._extract(self.fm.thisfile.path)


class compress(Command):
    """:compress <name.ext>

    Pack the marked files, or the one under the cursor, into <name.ext>. The
    format follows the extension: tar, tar.gz, tgz, tar.bz2, tar.xz, tar.zst,
    zip or 7z.
    """

    def execute(self):
        out = self.rest(1)
        if not out:
            self.fm.notify("compress needs a target name, e.g. :compress a.tar.gz",
                           bad=True)
            return
        names = [f.basename for f in self.fm.thistab.get_selection()]
        lower = out.lower()
        if _suffix(lower, TAR_SUFFIXES):
            argv = ["tar", "-caf", out, "--"] + names
        elif lower.endswith(".zip"):
            argv = ["zip", "-qr", out, "--"] + names
        elif lower.endswith(".7z"):
            sevenzip = shutil.which("7zz") or shutil.which("7z")
            if not sevenzip:
                self.fm.notify("7z is not installed", bad=True)
                return
            argv = [sevenzip, "a", out, "--"] + names
        else:
            self.fm.notify("Unknown archive format: " + out, bad=True)
            return
        loader = CommandLoader(argv, "compressing into " + out, read=True)
        loader.signal_bind("after", lambda _s: self.fm.thisdir.load_content())
        self.fm.loader.add(loader)
