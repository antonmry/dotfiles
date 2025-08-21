#!/bin/bash
# To explore options, use dconf-editor and:
# gsettings list-recursively > gsettings.bk
# Make changes here via gsettings set

gsettings set org.gnome.desktop.interface enable-animations false

gsettings set org.gnome.shell.keybindings open-new-window-application-1 []
gsettings set org.gnome.shell.keybindings open-new-window-application-2 []
gsettings set org.gnome.shell.keybindings open-new-window-application-3 []
gsettings set org.gnome.shell.keybindings open-new-window-application-4 []
gsettings set org.gnome.shell.keybindings open-new-window-application-5 []
gsettings set org.gnome.shell.keybindings open-new-window-application-6 []
gsettings set org.gnome.shell.keybindings open-new-window-application-7 []
gsettings set org.gnome.shell.keybindings open-new-window-application-8 []
gsettings set org.gnome.shell.keybindings open-new-window-application-9 []

gsettings set org.gnome.shell.keybindings switch-to-application-1 []
gsettings set org.gnome.shell.keybindings switch-to-application-2 []
gsettings set org.gnome.shell.keybindings switch-to-application-3 []
gsettings set org.gnome.shell.keybindings switch-to-application-4 []
gsettings set org.gnome.shell.keybindings switch-to-application-5 []
gsettings set org.gnome.shell.keybindings switch-to-application-6 []
gsettings set org.gnome.shell.keybindings switch-to-application-7 []
gsettings set org.gnome.shell.keybindings switch-to-application-8 []
gsettings set org.gnome.shell.keybindings switch-to-application-9 []

gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>5']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<Super>6']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-7 "['<Super>7']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-8 "['<Super>8']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-9 "['<Super>9']"

gsettings list-recursively > gsettings.bk

