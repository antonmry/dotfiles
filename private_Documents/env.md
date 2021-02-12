# Fedora

## Install packages

```bash
sudo dnf install fedora-workstation-repositories
sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf copr enable daftaupe/gopass
sudo dnf copr enable mguessan/davmail
sudo dnf copr enable atim/gping

sudo dnf install -y i3 xclip neovim dunst feh numlockx jetbrains-mono-nl-fonts \
gopass fzf thunderbird htop cowsay figlet davmail pavucontrol mplayer mencoder \
bat NetworkManager-tui gnome-tweaks gimp rclone nodejs yarnpkg pulseeffects \
audacity powertop autokey-gtk calibre ncdu pandoc lynx qutebrowser \
inotify-tools fswatch picom gpaste neofetch v4l-utils wkhtmltopdf httpie ranger \
zathura-bash-completion zathura-plugins-all highlight cava mopidy mopidy-mpd \
mopidy-spotify ncmpcpp jq python-ansi2html zeal inkscape \
golang-github-sqshq-sampler gping bwm-ng flameshot

sudo yum localinstall https://github.com/twpayne/chezmoi/releases/download/v1.8.4/chezmoi-1.8.4-x86_64.rpm
```

## Hostname

```bash
sudo hostnamectl set-hostname gali9
```

## Chrome

Download from https://www.google.com/chrome/browser/desktop/index.html 

```bash
sudo yum localinstall google-chrome-stable_current_x86_64.rpm
```

## Slack

Download from https://slack.com/intl/en-es/downloads/instructions/fedora

```bash
sudo yum localinstall slack-4.8.0-0.1.fc21.x86_64.rpm
```

## MineTime

Download from https://minetime.ai/

```bash
sudo yum localinstall MineTime-1.8.4.x86_64.rpm
```

## Microsoft Teams

Download from https://www.microsoft.com/en-us/microsoft-365/microsoft-teams/download-app#allDevicesSection

```bash
sudo dnf localinstall teams-1.3.00.25560-1.x86_64.rpm
```

## Python software

```bash
sudo pip3 install rsstail
sudo pip3 install gcalcli
sudo pip3 install s-tui
```

## PulseUi

Note: most of this shouldn't be needed in the last version.

```sh
sudo yum localinstall ps-pulse-linux-9.1r5.0-b151-centos-rhel-64-bit-installer.rpm
sudo /usr/local/pulse/PulseClient_x86_64.sh install_dependency_packages
```

> /usr/local/pulse/pulseUi
> /usr/local/pulse/pulseUi: error while loading shared libraries: libwebkitgtk-1.0.so.0: cannot open shared objec> t file: No such file or directory

See https://community.pulsesecure.net/t5/Pulse-Desktop-Clients/Fedora-27-webkitgtk-no-longer-supported/td-p/37559

```sh
mkdir temp
cd temp

wget ftp://ftp.pbone.net/mirror/archive.fedoraproject.org/fedora/linux/releases/27/Everything/x86_64/os/Packages/g/gnucash-2.6.18-1.fc27.x86_64.rpm

rpm2cpio gnucash-2.6.18-1.fc27.x86_64.rpm | cpio -idmv
sudo cp usr/lib64/gnucash/libwebkitgtk-1.0.so.0.22.17 /usr/local/pulse/
sudo cp usr/lib64/gnucash/libjavascriptcoregtk-1.0.so.0.16.19 /usr/local/pulse/

cd /usr/local/pulse
sudo ln -s libjavascriptcoregtk-1.0.so.0.16.19 libjavascriptcoregtk-1.0.so
sudo ln -s libjavascriptcoregtk-1.0.so.0.16.19 libjavascriptcoregtk-1.0.so.0
sudo ln -s libwebkitgtk-1.0.so.0.22.17 libwebkitgtk-1.0.so
sudo ln -s libwebkitgtk-1.0.so.0.22.17 libwebkitgtk-1.0.so.0
```

See https://community.pulsesecure.net/t5/Pulse-Desktop-Clients/Fedora-30-compatibilty/td-p/41485


```sh
cd ~/Downloads && rm -fr temp && mkdir temp && cd temp

wget http://repo.okay.com.mx/centos/7/x86_64/release/libicu57-57.1-8.el7.x86_64.rpm
rpm2cpio libicu57-57.1-8.el7.x86_64.rpm | cpio -idmv
sudo cp ./usr/lib64/libicui18n.so.57 /usr/lib64/
sudo cp ./usr/lib64/libicuuc.so.57 /usr/lib64/
sudo cp ./usr/lib64/libicudata.so.57 /usr/lib64/

sudo ln -s /bin/cat /usr/local/bin/freshclam

sudo unshare -f -m -p --mount-proc sudo -u dcazaspe sh -c '/usr/bin/env LD_LIBRARY_PATH=/usr/local/pulse:$LD_LIBRARY_PATH /usr/local/pulse/pulseUi | /usr/local/bin/freshclam'
```

## Restore crontab

```sh
crontab -e
```

## Docker

```sh
sudo dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo

sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose

sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"
sudo firewall-cmd --permanent --zone=trusted --add-interface=docker0
sudo firewall-cmd --permanent --zone=FedoraWorkstation --add-masquerade
sudo systemctl enable docker
sudo systemctl start docker
reboot
sudo docker run hello-world
```

Make user able to launch docker:

```sh
sudo usermod -aG docker antonmry
```

Install Docker Azure Credentials: https://github.com/Azure/acr-docker-credential-helper

```sh
curl -L https://aka.ms/acr/installaad/bash | /bin/bash
```

## sudoers

```sh
visudo /etc/sudoers
```

add the following line:

> `%antonmry       ALL=(ALL)       NOPASSWD: ALL`

## Gcloud

```sh
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

sudo dnf install google-cloud-sdk
```

## Remarkable

```sh
cd /home/antonmry/Workspace/Galiglobal/remarkable/rmview
sudo dnf install python3-devel
sudo pip install .
wget https://github.com/peter-sa/rM-vnc-server/releases/download/v0.0.1/rM-vnc-server
wget https://github.com/peter-sa/mxc_epdc_fb_damage/releases/download/v0.0.1/mxc_epdc_fb_damage.ko
chmod +x rM-vnc-server
scp rM-vnc-server REMARKABLE_ADDRESS:rM-vnc-server
scp mxc_epdc_fb_damage.ko  root@10.11.99.1:
cp example.json rmview.json

sudo dnf install make automake gcc gcc-c++ kernel-devel
python3.8 -m venv rcu-venv
. ./rcu-venv/bin/activate
cd sources/rcu/src
pip install –upgrade pip
pip install -r requirements.txt
python -B main.py
make
```

## OBS Studio

```sh
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install obs-studio
```

## Watch files

```sh
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```

## xbacklight

```sh
usermod -aG video antonmry

% cat /etc/udev/rules.d/backlight.rules
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"

reboot
```

## Zoom

Download from https://zoom.us/download

```sh
sudo rpm --import package-signing-key.pub
sudo yum localinstall zoom_x86_64.rpm
```

## Fonts

Download from https://dtinth.github.io/comic-mono-font/

```sh
sudo mkdir /usr/share/fonts/comic-mono
sudo cp ~/Downloads/ComicMono* /usr/share/fonts/comic-mono/
sudo fc-cache -v
```
