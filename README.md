## dotfiles

The installer supports macOS and Fedora. It detects the operating system and
uses Homebrew on macOS or Fedora's default `dnf` package manager on Fedora.
The Fedora package list is maintained separately in [`Fedorafile`](Fedorafile),
and macOS packages remain in [`Brewfile`](Brewfile).

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

On Fedora, desktop applications that are not in the default repositories
(such as Obsidian, Discord, Slack and Zed) are intentionally left for manual
RPM/Flatpak installation. `starship` and `yazi` are installed with Cargo,
and `lazygit` with Go because they are not in the enabled Fedora repositories.
