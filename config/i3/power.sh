#!/bin/bash

poweroff_command="systemctl poweroff"
reboot_command="systemctl reboot"
logout_command="i3-msg exit"
hibernate_command="systemctl hibernate"
suspend_command="systemctl suspend"

# you can customise the rofi command all you want ...
rofi_command="rofi -width 10 -hide-scrollbar -bg #586e75 -opacity 100 -padding 5"

options=$'poweroff\nreboot\nlogout\nhibernate\nsuspend' 

# ... because the essential options (-dmenu and -p) are added here
eval \$"$(echo "$options" | $rofi_command -dmenu -p "")_command"