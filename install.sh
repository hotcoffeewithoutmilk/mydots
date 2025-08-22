#!/bin/bash

if ! command -v pacman &>/dev/null; then
  echo "This installer is only for Arch-like systems"
  exit 1
fi

choice() {
  local question="$1"
  while true; do
    read -p "$question [y/n] " yn
    case $yn in
    [Yy]*) return 0 ;;
    [Nn]*) return 1 ;;
    *) echo "please answer yes or no" ;;
    esac
  done
}

if choice "Do you want to upgrade the mirrors? [HIGHLY RECOMMENDED]"; then
  sudo pacman -S --noconfirm --needed reflector || { echo "failed to install reflector, skipping mirror update" | tee -a ~/installerrors.txt; }
  sudo reflector --latest 15 --sort rate --save /etc/pacman.d/mirrorlist || { echo "failed to update mirrors, skip" | tee -a ~/installerrors.txt; }
fi

sudo pacman -Syyu --noconfirm || { echo "failed to synchronize package databases and upgrade system" | exit 1; }

if ! command -v yay &>/dev/null; then
  echo "Installing yay"

  sudo pacman -S --needed --noconfirm git base-devel || { echo "git and base-devel isnt installed" | exit 1; }
  sudo rm -rf ~/yay/ && git clone https://aur.archlinux.org/yay.git ~/yay/
  cd ~/yay/ && makepkg -si || {
    echo "Yay was not installed"
    exit 1
  }
  echo "Yay installed successfully"
else
  echo "Yay is already installed"
fi

MAINPKGS="hyprland hyprlock wlogout hyprsunset hypridle hyprshot swww waypaper \
waybar pavucontrol bluetooth bluez bluez-utils blueman nmcli network-manager-applet \
networkmanager pipewire pipewire-pulse pipewire-jack pipewire-alsa wireplumber alsa-utils brightnessctl playerctl polkit-gnome \
mako libnotify wofi vicinae-git \
ttf-font-awesome ttf-jetbrains-mono noto-fonts-emoji noto-fonts noto-fonts-cjk inter-font ttf-ms-win11-auto ttf-jetbrains-mono-nerd \
git cmake meson cpio pkg-config pkgconf gcc dbus curl wget eza \
xdg-desktop-portal xdg-desktop-portal-hyprland xdg-user-dirs archlinux-xdg-menu \
kate qt5 qt6 qt5-wayland qt6-wayland qt5ct qt6ct kvantum kservice5 kde-cli-tools kdeconnect dolphin kio-admin kio-gdrive ark zip unzip 7zip unrar unarchiver ffmpegthumbs kdegraphics-thumbnailers kde-thumbnailer-apk raw-thumbnailer resvg qt6-imageformats icoutils \
qemu-base libvirt virt-manager virt-install qemu-img edk2-ovmf dnsmasq libosinfo tuned vde2 bridge-utils openbsd-netcat iptables \
wl-clipboard wl-clip-persist cliphist \
fish vim nvim starship gimp btop qview mpv zen-browser-bin qbittorrent nyancat cli-visualizer fastfetch"

yay -S --needed --noconfirm $MAINPKGS

systemctl_system_services=(
  "bluetooth"
  "NetworkManager"
  "libvirtd"
)
systemctl_user_services=(
  "pipewire"
  "pipewire-pulse"
  "wireplumber"
)

for service in "${systemctl_system_services[@]}"; do
  echo "Processing servies: $service"
  sudo systemctl enable "$service" || { echo "failed to enable $service" | tee -a ~/installerrors.txt; }
  sudo systemctl start "$service" || { echo "failed to start $service" | tee -a ~/installerrors.txt; }
done
for service in "${systemctl_user_services[@]}"; do
  echo "Processing service: $service"
  systemctl --user enable "$service" || { echo "failed to enable $service" | tee -a ~/installerrors.txt; }
  systemctl --user start "$service" || { echo "failed to start $service" | tee -a ~/installerrors.txt; }
done

if choice "Do you want to install the optional programs?"; then
  RECOMENDPKGS="steam opentabletdriver gamemode portproton legacy-launcher lib32-gamemode mission-center flatpak spotify termius visual-studio-code-bin libreoffice-fresh ayugram-desktop-git obsidian vesktop-bin obs-studio throne torbrowser-launcher amneziawg-dkms amneziawg-tools openresolv perl-image-exiftool nmap fbreader ungoogled-chromium-bin adspower-global scrcpy android-tools"

  sudo sed -i 's/^#\(\[multilib\]\)/\1/' /etc/pacman.conf && echo "commented out [multilib]" || {
    echo "couldn't uncomment [multilib]"
    exit 1
  }
  sudo sed -i '/^\[multilib\]/{n;s/^#\(Include = \/etc\/pacman\.d\/mirrorlist\)/\1/}' /etc/pacman.conf && echo "commented out include for [multilib]" || {
    echo "failed to uncomment Include for [multilib]"
    exit 1
  }
  sudo pacman -Syy || { echo "couldn't execute pacman Syy" | tee -a ~/installerrors.txt; }

  yay -S --needed --noconfirm $RECOMENDPKGS

  if git clone https://github.com/MatMoul/g810-led.git ~/g810-led/; then
    sed -i '/#include <iostream>/a#include <inttypes.h>' ~/g810-led/src/helpers/help.h
    cd ~/g810-led/ && make bin && sudo make install
    mkdir -p /etc/g810led/
    sudo sh -c 'echo "# Sample profile by groups keys

fx color logo FFFFF0
fx color keys FFFFF0

c # Commit changes" > /etc/g810-led/profile'
    g815-led -p /etc/g810-led/profile
  else
    echo "couldn't install G810-led" | tee -a ~/installerrors.txt
  fi

  flatpak install flathub sh.ppy.osu
fi

if choice "Do you want to install the SDDM theme?"; then
  if git clone -b main --depth=1 https://github.com/uiriansan/SilentSDDM /tmp/SilentSDDM && cd /tmp/SilentSDDM && ./install.sh; then
    sudo cp /tmp/mydots/presets/mydm.conf /usr/share/sddm/themes/silent/configs/ || { echo "failed to copy mydm.conf" | tee -a ~/installerrors.txt; }
    sudo cp /tmp/mydots/presets/miku.png /usr/share/sddm/themes/silent/backgrounds/miku.png || { echo "failed to copy miku.png" | tee -a ~/installerrors.txt; }
    sudo sed -i 's|ConfigFile=configs/default.conf|ConfigFile=configs/mydm.conf|' /usr/share/sddm/themes/silent/metadata.desktop || { echo "failed to change sddm conf" | tee -a ~/installerrors.txt; }

    if ! sudo mv /tmp/mydots/presets/username.face.icon /usr/share/sddm/faces/"$USER".face.icon; then
      echo "couldn't move the avatar for sddm" | tee -a ~/installerrors.txt
    fi
  else
    echo "failed to install SilentSDDM theme" | tee -a ~/installerrors.txt
  fi
fi

git clone https://github.com/vinceliuice/Graphite-gtk-theme.git /tmp/Graphite-gtk-theme && cd /tmp/Graphite-gtk-theme && ./install.sh -t default teal -l --tweaks darker rimless normal || { echo "couldn't install gtk theme" | tee -a ~/installerrors.txt; }
git clone https://github.com/vinceliuice/Tela-icon-theme.git /tmp/Tela-icon-theme && cd /tmp/Tela-icon-theme && ./install.sh -a -c || { echo "couldn't install icon pack" | tee -a ~/installerrors.txt; }

hyprpm update

hyprpm add https://github.com/hyprwm/hyprland-plugins || { echo "couldn't add plugin repository (hyprland-plugins), try again later" | tee -a ~/installerrors.txt; }
hyprpm add https://github.com/virtcode/hypr-dynamic-cursors || { echo "couldn't add plugin repository (hypr-dynamic-cursors), try again later" | tee -a ~/installerrors.txt; }

hyprpm enable dynamic-cursors || { echo "couldn't turn on the plugin (hypr-dynamic-cursors), try again later" | tee -a ~/installerrors.txt; }
hyprpm enable csgo-vulkan-fix || { echo "couldn't turn on the plugin (cs-fix), try again later" | tee -a ~/installerrors.txt; }

XDG_MENU_PREFIX=arch- kbuildsycoca6 || { echo "failed to execute 'XDG_MENU_PREFIX=arch- kbuildsycoca6'" | tee -a ~/installerrors.txt; }

LC_ALL=C xdg-user-dirs-update --force || { echo "failed to set LC_ALL=C xdg-user-dirs-update --force" | tee -a ~/installerrors.txt; }

if ! kbuildsycoca6 --noincremental 2>/dev/null | grep -q 'applications.menu" not found'; then
  sudo pacman -Sy --noconfirm archlinux-xdg-menu && sudo update-desktop-database && cd /etc/xdg/menus && sudo mv arch-applications.menu applications.menu || { echo "couldn't solve the 'open with' problem" | tee -a ~/installerrors.txt; }
else
  echo "the 'open with' problem was not detected"
fi

chsh -s /usr/bin/fish

sudo usermod -aG libvirt,kvm,gamemode $USER || { echo "failed to add $USER to libvirt and kvm group" | tee -a ~/installerrors.txt; }

cp -r "/tmp/mydots/.config" "$HOME" || { echo "couldn't move files to the home directory" | exit 1; }
cp -r "/tmp/mydots/.local" "$HOME" || { echo "couldn't move files to the home directory" | exit 1; }
cp -r "/tmp/mydots/.nmap" "$HOME" || { echo "couldn't move files to the home directory" | exit 1; }
cp -r "/tmp/mydots/Pictures" "$HOME" || { echo "couldn't move files to the home directory" | exit 1; }
sudo cp -r "/tmp/mydots/presets/fonts/"* "/usr/share/fonts/" && sudo fc-cache -f -v || { echo "failed to copy fonts" | tee -a ~/installerrors.txt; }

find "$HOME/.config/hypr/scripts/" -type f -name "*.sh" -print0 | xargs -0 chmod +x
sh .config/hypr/scripts/themechange.sh

if choice "Do you want to reboot"; then
  reboot
else
  echo "OKI"
fi
