# dotfiles for my Arch Linux setup

## Installation

Clone the repo and symlink the configs into place:

```bash
git clone https://github.com/stephenbonner/dotfiles.git ~/Git/dotfiles
cd ~/Git/dotfiles
```

Then symlink each config directory into `~/.config/`:

```bash
ln -sf ~/Git/dotfiles/config/hypr       ~/.config/hypr
ln -sf ~/Git/dotfiles/config/wayle      ~/.config/wayle
ln -sf ~/Git/dotfiles/config/alacritty  ~/.config/alacritty
ln -sf ~/Git/dotfiles/config/wofi       ~/.config/wofi
ln -sf ~/Git/dotfiles/config/rofi       ~/.config/rofi
ln -sf ~/Git/dotfiles/config/picom      ~/.config/picom
ln -sf ~/Git/dotfiles/config/nvim/      ~/.config/nvim
```

VSCode launch flags are a single file (the `/usr/bin/code` wrapper reads it from `~/.config/code-flags.conf` directly, not from a subdirectory):

```bash
ln -sf ~/Git/dotfiles/config/vscode/code-flags.conf ~/.config/code-flags.conf
```

## WM

- Hyprland

## Apps

Current system relies on the following apps:

- alacritty
- wofi
- wayle
- hypridle
- hyprlock
- neovim

## Fonts

I replace freetype2 with one with the cleartype patch, install `freetype2-cleartype` from the AUR.

The setup relies on the following fonts being install on Arch:

- `ttf-font-awesome-5`
- `nerd-fonts-complete` (AUR) - this is massive, don't need them all
- `apple-fonts`
