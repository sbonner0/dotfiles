# dotfiles for my Arch Linux setup

## WM

- i3-gaps

## Apps

Current system relies on the following apps:

- polybar
- alacritty
- rxvt-unicode
- picom
- rofi
- rofi-calc
- ranger

## Additonal Apps

I currently still make use of gnome primarily for the google drive integration. The following packages aid in the use of gnome and i3:

- gnome
- i3-gnome
- gnome-flashback

## Fonts

I replace freetype2 with one with the cleartype patch, install `freetype2-cleartype` from the AUR.

The setup relies on the following fonts being install on Arch:
- `ttf-font-awesome-5` 
- `nerd-fonts-complete` (AUR) - this is massive, don't need them all
- `apple-fonts`

## Boot Conf
These are added to the systemd bootline for X99 based system: mitigations=off pci=nommconf
