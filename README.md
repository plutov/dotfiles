## dotfiles

The installer supports macOS and Fedora. It detects the operating system and
uses Homebrew on macOS or Fedora's default `dnf` package manager on Fedora.
The Fedora package list is maintained separately in [`Fedorafile`](Fedorafile),
Flatpak applications in [`Flatpakfile`](Flatpakfile), and macOS packages
remain in [`Brewfile`](Brewfile).

Install tools:

```bash
./dotfiles.sh -i
```

Apply dotfiles:

```bash
./dotfiles.sh -a
```

Save local dotfiles back to this repository:

```bash
./dotfiles.sh -s
```
