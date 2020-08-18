sudo dnf install fedora-workstation-repositories
sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf copr enable daftaupe/gopass 
sudo dnf copr enable mguessan/davmail

sudo dnf install -y i3 xclip neovim dunst feh numlockx jetbrains-mono-nl-fonts \
gopass fzf thunderbird htop cowsay figlet davmail pavucontrol mplayer mencoder \
bat NetworkManager-tui gnome-tweaks gimp

sudo yum localinstall https://github.com/twpayne/chezmoi/releases/download/v1.8.4/chezmoi-1.8.4-x86_64.rpm

sudo hostnamectl set-hostname gali9

## Chrome

Download from https://www.google.com/chrome/browser/desktop/index.html 

sudo yum localinstall google-chrome-stable_current_x86_64.rpm

## Slack

Download from https://slack.com/intl/en-es/downloads/instructions/fedora
sudo yum localinstall slack-4.8.0-0.1.fc21.x86_64.rpm

## MineTime

Download from https://minetime.ai/
sudo yum localinstall MineTime-1.8.4.x86_64.rpm

## TODO

- [ ] sudoers
- [ ] SELinux
- [ ] PulseUi
- [x] name machine
