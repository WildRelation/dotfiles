#!/bin/bash

# ============================================
#   Dotfiles Install Script
#   Arch Linux + AwesomeWM + Catppuccin Mocha
# ============================================

set +e  # no parar en errores individuales
DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing packages..."
sudo pacman -S --needed --noconfirm \
    zsh zsh-autosuggestions \
    kitty \
    awesome \
    picom \
    rofi \
    conky \
    starship \
    fastfetch \
    eza zoxide fzf \
    fortune-mod lolcat \
    playerctl \
    ttf-jetbrains-mono-nerd \
    papirus-icon-theme \
    archlinux-wallpaper \
    blueman udiskie \
    timeshift \
    brightnessctl \
    pacman-contrib \
    redshift \
    flameshot \
    network-manager-applet \
    cmatrix \
    figlet \
    btop \
    xorg-xsetroot \
    xorg-xinit \
    python \
    curl

echo "==> Installing AUR packages (requires yay)..."
if command -v yay &>/dev/null; then
    yay -S --needed --noconfirm \
        fast-syntax-highlighting \
        lain-git \
        catppuccin-gtk-theme-mocha \
        catppuccin-cursors-mocha \
        greenclip \
        auto-cpufreq \
        betterlockscreen \
        checkupdates+aur \
        ly \
        xidlehook \
        tty-clock-git \
        pipes.sh \
        cbonsai \
        asciiquarium
else
    echo "  [!] yay not found. Install yay first then run:"
    echo "      yay -S fast-syntax-highlighting lain-git catppuccin-gtk-theme-mocha catppuccin-cursors-mocha greenclip auto-cpufreq betterlockscreen checkupdates+aur ly xidlehook tty-clock-git pipes.sh cbonsai asciiquarium"
fi

echo "==> Linking config files..."

# Función para crear symlinks
link() {
    local src="$DOTFILES/$1"
    local dst="$HOME/$1"
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo "  Linked $1"
}

link .zshrc
link .xprofile
link .gtkrc-2.0
link .config/kitty/kitty.conf
link .config/kitty/current-theme.conf
link .config/awesome/rc.lua
link .config/awesome/volume-osd.lua
link .config/awesome/brightness-osd.lua
link .config/awesome/themes/default/theme.lua
link .config/starship.toml
link .config/rofi/catppuccin-mocha.rasi
link .config/conky/conky.conf
link .config/picom/picom.conf
link .config/fastfetch/config.jsonc
link .config/gtk-3.0/settings.ini
link .config/gtk-4.0/settings.ini
link .icons/default/index.theme
link .config/fsh/catppuccin.ini

# Scripts ejecutables
mkdir -p ~/.local/bin
cp "$DOTFILES/.local/bin/conky-weather.sh" ~/.local/bin/
cp "$DOTFILES/.local/bin/wallpaper-time.sh" ~/.local/bin/
cp "$DOTFILES/.local/bin/reset-audio.sh" ~/.local/bin/
chmod +x ~/.local/bin/conky-weather.sh \
         ~/.local/bin/wallpaper-time.sh \
         ~/.local/bin/reset-audio.sh

# Firefox userChrome
FIREFOX_PROFILE=$(find ~/.mozilla/firefox -name "*.default-release" -type d 2>/dev/null | head -1)
if [ -n "$FIREFOX_PROFILE" ]; then
    mkdir -p "$FIREFOX_PROFILE/chrome"
    cp "$DOTFILES/.mozilla/firefox/chrome/userChrome.css" "$FIREFOX_PROFILE/chrome/"
    cp "$DOTFILES/.mozilla/firefox/chrome/userContent.css" "$FIREFOX_PROFILE/chrome/"
    echo "  Linked Firefox userChrome"
fi

echo "==> Downloading Catppuccin wallpapers..."
mkdir -p ~/Pictures/wallpapers/{morning,day,evening,night}
BASE="https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main"

curl -sL "$BASE/landscapes/Clearday.jpg"              -o ~/Pictures/wallpapers/morning/Clearday.jpg
curl -sL "$BASE/landscapes/tropic_island_morning.jpg" -o ~/Pictures/wallpapers/morning/tropic_island_morning.jpg
curl -sL "$BASE/landscapes/yosemite.png"              -o ~/Pictures/wallpapers/morning/yosemite.png
curl -sL "$BASE/landscapes/forrest.png"               -o ~/Pictures/wallpapers/morning/forrest.png
curl -sL "$BASE/landscapes/Cloudsday.jpg"             -o ~/Pictures/wallpapers/day/Cloudsday.jpg
curl -sL "$BASE/landscapes/tropic_island_day.jpg"     -o ~/Pictures/wallpapers/day/tropic_island_day.jpg
curl -sL "$BASE/landscapes/salty_mountains.png"       -o ~/Pictures/wallpapers/day/salty_mountains.png
curl -sL "$BASE/landscapes/evening-sky.png"           -o ~/Pictures/wallpapers/evening/evening-sky.png
curl -sL "$BASE/landscapes/tropic_island_evening.jpg" -o ~/Pictures/wallpapers/evening/tropic_island_evening.jpg
curl -sL "$BASE/gradients/flamingo_peach.png"         -o ~/Pictures/wallpapers/evening/flamingo_peach.png
curl -sL "$BASE/gradients/peach_bkg5.png"             -o ~/Pictures/wallpapers/evening/peach_bkg5.png
curl -sL "$BASE/landscapes/Clearnight.jpg"            -o ~/Pictures/wallpapers/night/Clearnight.jpg
curl -sL "$BASE/landscapes/tropic_island_night.jpg"   -o ~/Pictures/wallpapers/night/tropic_island_night.jpg
curl -sL "$BASE/os/arch-black-4k.png"                 -o ~/Pictures/wallpapers/night/arch-black-4k.png
curl -sL "$BASE/os/various-arch-1-4k.png"             -o ~/Pictures/wallpapers/night/various-arch-1-4k.png
curl -sL "$BASE/os/various-arch-2-4k.png"             -o ~/Pictures/wallpapers/night/various-arch-2-4k.png
curl -sL "$BASE/waves/cat-waves.png"                  -o ~/Pictures/wallpapers/night/cat-waves.png
curl -sL "$BASE/minimalistic/dark-cat.png"            -o ~/Pictures/wallpapers/night/dark-cat.png

echo "==> Applying system configs (requires sudo)..."
sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp "$DOTFILES/etc/X11/xorg.conf.d/30-touchpad.conf" /etc/X11/xorg.conf.d/
sudo cp "$DOTFILES/etc/ly/config.ini" /etc/ly/config.ini
echo "  Touchpad + ly config applied"

echo "==> Enabling system services..."
sudo systemctl enable ly@tty2.service 2>/dev/null && echo "  ly enabled" || echo "  [!] ly service not found"
sudo systemctl disable gdm sddm lightdm 2>/dev/null || true
sudo systemctl enable --now auto-cpufreq 2>/dev/null && echo "  auto-cpufreq enabled" || echo "  [!] auto-cpufreq not found"
sudo systemctl enable bluetooth 2>/dev/null && echo "  Bluetooth enabled" || echo "  [!] Bluetooth not found"

echo "==> Applying gsettings..."
gsettings set org.gnome.desktop.interface gtk-theme "catppuccin-mocha-blue-standard+default"
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
gsettings set org.gnome.desktop.interface font-name "JetBrainsMono Nerd Font 10"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font 10"
gsettings set org.gnome.desktop.interface cursor-theme "catppuccin-mocha-blue-cursors"
gsettings set org.gnome.desktop.interface cursor-size 24
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

echo "==> Setting zsh as default shell..."
chsh -s /usr/bin/zsh

echo ""
echo "========================================"
echo "  Installation complete!"
echo ""
echo "  Manual steps after reboot:"
echo "  1. Firefox -> about:config:"
echo "     toolkit.legacyUserProfileCustomizations.stylesheets = true"
echo "     layout.css.devPixelsPerPx = 1.2"
echo "  2. Install Catppuccin Mocha Blue extension in Firefox"
echo "========================================"
