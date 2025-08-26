#!/bin/bash

# Arch Linux TUI Rice Setup Script for Hyprland
# Run this script to install and configure a complete TUI-based rice

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Arch Linux
check_arch() {
    if [[ ! -f /etc/arch-release ]]; then
        print_error "This script is designed for Arch Linux only!"
        exit 1
    fi
}

# Check if paru is installed, install if not
install_paru() {
    if ! command -v paru &> /dev/null; then
        print_status "Installing paru AUR helper..."
        sudo pacman -S --needed base-devel git
        cd /tmp
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
        cd ~
        print_success "Paru installed successfully!"
    else
        print_success "Paru already installed!"
    fi
}

# Install core packages
install_core_packages() {
    print_status "Installing core packages..."
    
    # Core Hyprland and Wayland packages
    CORE_PACKAGES=(
        "hyprland"
        "xdg-desktop-portal-hyprland"
        "waybar"
        "rofi-wayland"
        "fuzzel"
        "mako"
        "swww"
        "hyprpaper"
        "swaylock-effects"
        "grim"
        "slurp"
        "wl-clipboard"
    )
    
    sudo pacman -S --needed "${CORE_PACKAGES[@]}"
    print_success "Core packages installed!"
}

# Install terminal and TUI applications
install_tui_apps() {
    print_status "Installing TUI applications..."
    
    TUI_PACKAGES=(
        "kitty"
        "btop"
        "neovim"
        "neofetch"
        "figlet"
        "toilet"
        "cava"
        "pulsemixer"
        "lazygit"
        "fzf"
        "ripgrep"
        "eza"
        "bat"
        "fd"
        "stow"
        "zsh"
        "zsh-completions"
        "zsh-syntax-highlighting"
        "zsh-autosuggestions"
    )
    
    sudo pacman -S --needed "${TUI_PACKAGES[@]}"
    print_success "TUI applications installed!"
}

# Install AUR packages
install_aur_packages() {
    print_status "Installing AUR packages..."
    
    AUR_PACKAGES=(
        "pfetch"
        "onefetch"
        "yazi"
        "jp2a"
        "python-pywal"
        "colorscript-collection-git"
        "spotify-tui"
        "spotifyd"
        "starship"
        "eww-wayland"
    )
    
    for package in "${AUR_PACKAGES[@]}"; do
        print_status "Installing $package..."
        paru -S --noconfirm "$package" || print_warning "Failed to install $package"
    done
    
    print_success "AUR packages installation completed!"
}

# Setup zsh as default shell
setup_zsh() {
    print_status "Setting up zsh..."
    
    if [[ $SHELL != "/usr/bin/zsh" ]]; then
        chsh -s /usr/bin/zsh
        print_success "Default shell changed to zsh (restart required)"
    else
        print_success "Zsh is already the default shell!"
    fi
}

setup_dotfiles_structure() {
    print_status "Setting up dotfiles structure with GNU Stow..."
    
    # Create dotfiles directory (hidden)
    DOTFILES_DIR="$HOME/.dotfiles"
    mkdir -p "$DOTFILES_DIR"
    
    # Create package directories for Stow (based on your actual package selection)
    STOW_PACKAGES=(
        "hypr"
        "waybar" 
        "kitty"
        "rofi"
        "fuzzel"
        "mako"
        "swww"
        "hyprpaper"
        "cava"
        "ranger"
        "nvim"
        "zsh"
        "starship"
        "spotifyd"  
        "eww"
        "scripts"
        "themes"
    )
    
    for package in "${STOW_PACKAGES[@]}"; do
        mkdir -p "$DOTFILES_DIR/$package"
    done
    
    # Create the nested .config structure for each package
    mkdir -p "$DOTFILES_DIR/hypr/.config/hypr"
    mkdir -p "$DOTFILES_DIR/waybar/.config/waybar"
    mkdir -p "$DOTFILES_DIR/kitty/.config/kitty"
    mkdir -p "$DOTFILES_DIR/rofi/.config/rofi"
    mkdir -p "$DOTFILES_DIR/fuzzel/.config/fuzzel"
    mkdir -p "$DOTFILES_DIR/mako/.config/mako"
    mkdir -p "$DOTFILES_DIR/swww/.config/swww"
    mkdir -p "$DOTFILES_DIR/cava/.config/cava"
    mkdir -p "$DOTFILES_DIR/ranger/.config/ranger"
    mkdir -p "$DOTFILES_DIR/nvim/.config/nvim"
    mkdir -p "$DOTFILES_DIR/eww/.config/eww"
    mkdir -p "$DOTFILES_DIR/spotifyd/.config/spotifyd"
    
    # Home directory configs (not in .config)
    mkdir -p "$DOTFILES_DIR/zsh"  # For .zshrc, .zshenv, etc.
    mkdir -p "$DOTFILES_DIR/starship/.config"  # starship.toml goes in .config
    
    # Scripts and themes
    mkdir -p "$DOTFILES_DIR/scripts/.local/bin"
    mkdir -p "$DOTFILES_DIR/themes/.config/wal"  # pywal themes
    
    # Create other useful directories
    mkdir -p "$HOME/wallpapers"
    mkdir -p "$HOME/.local/bin"  # For your scripts
}

# Create basic Hyprland configuration
create_hypr_config() {
    print_status "Creating basic Hyprland configuration..."
    
    cat > "$HOME/.dotfiles/hypr/.config/hypr/hyprland.conf" << 'EOF'
# Hyprland configuration
# See https://wiki.hyprland.org/

monitor=,preferred,auto,auto

# Execute your favorite apps at launch
exec-once = waybar
exec-once = swww init
exec-once = dunst

# Some default env vars
env = XCURSOR_SIZE,24

# For all categories, see https://wiki.hyprland.org/Configuring/Variables/
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1

    touchpad {
        natural_scroll = no
    }

    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
}

general {
    gaps_in = 5
    gaps_out = 20
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)

    layout = dwindle
}

decoration {
    rounding = 10
    
    blur {
        enabled = true
        size = 3
        passes = 1
    }

    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

animations {
    enabled = yes

    bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

dwindle {
    pseudotile = yes
    preserve_split = yes
}

master {
    new_is_master = true
}

gestures {
    workspace_swipe = off
}

# Example windowrule v1
# windowrule = float, ^(kitty)$
# Example windowrule v2
# windowrulev2 = float,class:^(kitty)$,title:^(kitty)$

# Keybindings
$mainMod = SUPER

bind = $mainMod, Q, exec, kitty
bind = $mainMod, C, killactive, 
bind = $mainMod, M, exit, 
bind = $mainMod, E, exec, ranger
bind = $mainMod, V, togglefloating, 
bind = $mainMod, R, exec, rofi -show drun
bind = $mainMod, P, pseudo, # dwindle
bind = $mainMod, J, togglesplit, # dwindle

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
EOF

    print_success "Basic Hyprland configuration created!"
}

# Create basic Waybar configuration
create_waybar_config() {
    print_status "Creating basic Waybar configuration..."
    
    cat > "$HOME/.dotfiles/waybar/.config/waybar/config" << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "spacing": 4,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["hyprland/window"],
    "modules-right": ["pulseaudio", "network", "cpu", "memory", "temperature", "backlight", "battery", "clock", "tray"],
    
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "format": "{icon}",
        "format-icons": {
            "1": "",
            "2": "",
            "3": "",
            "4": "",
            "5": "",
            "urgent": "",
            "focused": "",
            "default": ""
        }
    },
    
    "clock": {
        "timezone": "America/New_York",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format-alt": "{:%Y-%m-%d}"
    },
    
    "cpu": {
        "format": "{usage}% ",
        "tooltip": false
    },
    
    "memory": {
        "format": "{}% "
    },
    
    "temperature": {
        "critical-threshold": 80,
        "format": "{temperatureC}°C {icon}",
        "format-icons": ["", "", ""]
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-charging": "{capacity}% ",
        "format-plugged": "{capacity}% ",
        "format-alt": "{time} {icon}",
        "format-icons": ["", "", "", "", ""]
    },
    
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "{ipaddr}/{cidr} ",
        "tooltip-format": "{ifname} via {gwaddr} ",
        "format-linked": "{ifname} (No IP) ",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}"
    },
    
    "pulseaudio": {
        "format": "{volume}% {icon} {format_source}",
        "format-bluetooth": "{volume}% {icon} {format_source}",
        "format-bluetooth-muted": " {icon} {format_source}",
        "format-muted": " {format_source}",
        "format-source": "{volume}% ",
        "format-source-muted": "",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    }
}
EOF

    cat > "$HOME/.dotfiles/waybar/.config/waybar/style.css" << 'EOF'
* {
    border: none;
    border-radius: 0;
    font-family: 'JetBrainsMono Nerd Font';
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background-color: rgba(43, 48, 59, 0.8);
    border-bottom: 3px solid rgba(100, 114, 125, 0.5);
    color: #ffffff;
    transition-property: background-color;
    transition-duration: .5s;
}

window#waybar.hidden {
    opacity: 0.2;
}

#workspaces button {
    padding: 0 5px;
    background-color: transparent;
    color: #ffffff;
    border-bottom: 3px solid transparent;
    min-width: 50px;
}

#workspaces button:hover {
    background: rgba(0, 0, 0, 0.2);
}

#workspaces button.focused {
    background-color: #64727D;
    border-bottom: 3px solid #ffffff;
}

#workspaces button.urgent {
    background-color: #eb4d4b;
}

#mode {
    background-color: #64727D;
    border-bottom: 3px solid #ffffff;
}

#clock,
#battery,
#cpu,
#memory,
#temperature,
#backlight,
#network,
#pulseaudio,
#custom-media,
#tray,
#mode,
#idle_inhibitor,
#mpd {
    padding: 0 10px;
    color: #ffffff;
}

#window,
#workspaces {
    margin: 0 4px;
}

.modules-left > widget:first-child > #workspaces {
    margin-left: 0;
}

.modules-right > widget:last-child > #workspaces {
    margin-right: 0;
}

#clock {
    background-color: #64727D;
}

#battery {
    background-color: #ffffff;
    color: #000000;
}

#battery.charging, #battery.plugged {
    color: #ffffff;
    background-color: #26A65B;
}

@keyframes blink {
    to {
        background-color: #ffffff;
        color: #000000;
    }
}

#battery.critical:not(.charging) {
    background-color: #f53c3c;
    color: #ffffff;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

#cpu {
    background-color: #2ecc71;
    color: #000000;
}

#memory {
    background-color: #9b59b6;
}

#temperature {
    background-color: #f0932b;
}

#temperature.critical {
    background-color: #eb4d4b;
}

#network {
    background-color: #2980b9;
}

#network.disconnected {
    background-color: #f53c3c;
}

#pulseaudio {
    background-color: #f1c40f;
    color: #000000;
}

#pulseaudio.muted {
    background-color: #90b1b1;
    color: #2a5c45;
}

#tray {
    background-color: #2980b9;
}

#tray > .passive {
    -gtk-icon-effect: dim;
}

#tray > .needs-attention {
    -gtk-icon-effect: highlight;
    background-color: #eb4d4b;
}
EOF

    print_success "Basic Waybar configuration created!"
}

# Create kitty configuration
create_kitty_config() {
    print_status "Creating Kitty configuration..."
    
    cat > "$HOME/.dotfiles/kitty/.config/kitty/kitty.conf" << 'EOF'
# Kitty Configuration

# Font
font_family JetBrains Mono
bold_font auto
italic_font auto
bold_italic_font auto
font_size 12.0

# Window
remember_window_size yes
initial_window_width 100c
initial_window_height 30c
window_padding_width 10

# Tab bar
tab_bar_edge bottom
tab_bar_style powerline
tab_powerline_style slanted

# Color scheme (will be overridden by pywal)
background #1e1e2e
foreground #cdd6f4
cursor #f38ba8

# Theme
include ~/.cache/wal/colors-kitty.conf

# Keybindings
map ctrl+shift+c copy_to_clipboard
map ctrl+shift+v paste_from_clipboard
map ctrl+shift+enter new_window
map ctrl+shift+t new_tab
map ctrl+shift+q close_tab
EOF

    print_success "Kitty configuration created!"
}

# Create a welcome script with ASCII art
create_welcome_script() {
    print_status "Creating welcome script..."
    
    cat > "$HOME/.dotfiles/scripts/.local/bin/welcome" << 'EOF'
#!/bin/bash

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Clear screen
clear

# ASCII Art Banner
echo -e "${CYAN}"
figlet -f slant "ARCH RICE"
echo -e "${NC}"

echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# System info
echo -e "${GREEN}Welcome to your TUI rice setup!${NC}"
echo -e "${BLUE}System: ${NC}$(uname -sr)"
echo -e "${BLUE}Uptime: ${NC}$(uptime -p)"
echo -e "${BLUE}Shell:  ${NC}$SHELL"

echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Random color script
if command -v colorscript &> /dev/null; then
    colorscript random
fi

echo ""
EOF

    chmod +x "$HOME/.dotfiles/scripts/.local/bin/welcome"
    print_success "Welcome script created!"
}

# Setup zshrc with Stow structure
setup_zshrc() {
    print_status "Setting up .zshrc..."
    
    # Backup existing .zshrc
    if [[ -f "$HOME/.zshrc" ]]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
    fi
    
    cat > "$HOME/.dotfiles/zsh/.zshrc" << 'EOF'
# Zsh Configuration - Minimal Rice Setup

# History configuration
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_ignore_space

# Auto completion
autoload -Uz compinit
compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Better completion menu
zstyle ':completion:*' menu select

# Enable colors
autoload -U colors && colors

# Prompt configuration (simple and clean)
setopt PROMPT_SUBST

# Git branch function
git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Custom prompt
PROMPT='%{$fg[cyan]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg[yellow]%}%~ %{$fg[green]%}$(git_branch)%{$reset_color%}
%{$fg[red]%}❯%{$reset_color%} '

# Enable syntax highlighting (if available)
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Enable autosuggestions (if available)
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# User configuration
export PATH=$PATH:$HOME/.local/bin

# Aliases
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias lt='eza --tree --icons'
alias cat='bat'
alias grep='rg'
alias find='fd'
alias htop='btop'
alias vim='nvim'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract function for various archive types
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Pywal colors (load if available)
(cat ~/.cache/wal/sequences &) 2>/dev/null

# Welcome message on new terminal (comment out if unwanted)
# welcome

# Key bindings
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char

# Enable spelling correction
setopt correct

# Alternative: Starship prompt (uncomment if you prefer starship)
# eval "$(starship init zsh)"
EOF

    print_success ".zshrc configured with minimal setup!"
}

# Create Stow management script
create_stow_script() {
    print_status "Creating Stow management script..."
    
    cat > "$HOME/.dotfiles/stow.sh" << 'EOF'
#!/bin/bash

# Dotfiles management script using GNU Stow
# Usage: ./stow.sh [install|remove|restow] [package_name|all]

DOTFILES_DIR="$HOME/.dotfiles"
PACKAGES=("hypr" "waybar" "kitty" "alacritty" "rofi" "dunst" "cava" "ranger" "nvim" "zsh" "scripts")

cd "$DOTFILES_DIR" || exit 1

install_package() {
    local package="$1"
    echo "Installing $package..."
    stow -t "$HOME" "$package"
}

remove_package() {
    local package="$1"
    echo "Removing $package..."
    stow -D -t "$HOME" "$package"
}

restow_package() {
    local package="$1"
    echo "Restowing $package..."
    stow -R -t "$HOME" "$package"
}

case "$1" in
    install|i)
        if [[ "$2" == "all" || -z "$2" ]]; then
            for pkg in "${PACKAGES[@]}"; do
                install_package "$pkg"
            done
        else
            install_package "$2"
        fi
        ;;
    remove|r)
        if [[ "$2" == "all" ]]; then
            for pkg in "${PACKAGES[@]}"; do
                remove_package "$pkg"
            done
        else
            remove_package "$2"
        fi
        ;;
    restow|re)
        if [[ "$2" == "all" || -z "$2" ]]; then
            for pkg in "${PACKAGES[@]}"; do
                restow_package "$pkg"
            done
        else
            restow_package "$2"
        fi
        ;;
    list|l)
        echo "Available packages:"
        for pkg in "${PACKAGES[@]}"; do
            echo "  - $pkg"
        done
        ;;
    *)
        echo "Usage: $0 {install|remove|restow|list} [package_name|all]"
        echo ""
        echo "Commands:"
        echo "  install, i    - Install/link dotfiles"
        echo "  remove, r     - Remove/unlink dotfiles"
        echo "  restow, re    - Restow (remove and install)"
        echo "  list, l       - List available packages"
        echo ""
        echo "Examples:"
        echo "  $0 install all     # Install all packages"
        echo "  $0 install hypr    # Install only Hyprland config"
        echo "  $0 remove waybar   # Remove waybar config"
        echo "  $0 restow all      # Restow all packages"
        exit 1
        ;;
esac
EOF

    chmod +x "$HOME/.dotfiles/stow.sh"
    
    # Create README for dotfiles
    cat > "$HOME/.dotfiles/README.md" << 'EOF'
# Arch Linux TUI Rice Dotfiles

This repository contains my dotfiles managed with GNU Stow for a minimal TUI-based rice setup with Hyprland.

## Structure

```
.dotfiles/
├── hypr/          # Hyprland configuration
├── waybar/        # Waybar configuration
├── kitty/         # Kitty terminal configuration
├── alacritty/     # Alacritty terminal configuration
├── rofi/          # Rofi launcher configuration
├── dunst/         # Notification daemon configuration
├── cava/          # Audio visualizer configuration
├── ranger/        # File manager configuration
├── nvim/          # Neovim configuration
├── zsh/           # Zsh configuration
├── scripts/       # Custom scripts
├── stow.sh        # Stow management script
└── README.md      # This file
```

## Usage

### Install all dotfiles:
```bash
cd ~/.dotfiles
./stow.sh install all
```

### Install specific package:
```bash
./stow.sh install hypr
```

### Remove dotfiles:
```bash
./stow.sh remove all
```

### Restow (useful after making changes):
```bash
./stow.sh restow all
```

### List available packages:
```bash
./stow.sh list
```

## Making Changes

1. Edit files in the dotfiles directory structure
2. Run `./stow.sh restow [package]` to apply changes
3. Commit your changes to git (if using version control)

## Git Integration

To track your dotfiles with git:

```bash
cd ~/.dotfiles
git init
git add .
git commit -m "Initial dotfiles commit"
git remote add origin <your-repo-url>
git push -u origin main
```

## Backup

Your original configurations are backed up with `.backup` extension before stowing.
EOF

    print_success "Stow management script and documentation created!"
}

# Apply Stow configurations
apply_stow_configs() {
    print_status "Applying dotfiles with Stow..."
    
    cd "$HOME/.dotfiles" || exit 1
    
    # Stow all packages
    for package in hypr waybar kitty zsh scripts; do
        print_status "Stowing $package..."
        stow -t "$HOME" "$package" 2>/dev/null || print_warning "Failed to stow $package (may already exist)"
    done
    
    print_success "Dotfiles applied with Stow!"
}

# Install fonts
install_fonts() {
    print_status "Installing fonts..."
    
    # Essential fonts
    FONT_PACKAGES=(
        "noto-fonts-emoji"        # Emoji support - essential for modern interfaces
    )
    
    sudo pacman -S --needed "${FONT_PACKAGES[@]}"
    
    # Install JetBrains Mono Nerd Font 
    print_status "Installing JetBrains Mono Nerd Font"
    paru -S --noconfirm nerd-fonts-jetbrains-mono || {
        print_warning "Failed to install Nerd Font, falling back to regular JetBrains Mono"
        sudo pacman -S --needed ttf-jetbrains-mono
    }
    
    # Refresh font cache so new fonts are immediately available
    print_status "Refreshing font cache..."
    fc-cache -fv > /dev/null 2>&1
    
    print_success "Fonts installed and cache refreshed!"
}

# Final setup instructions
show_final_instructions() {
    print_success "Installation completed!"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}NEXT STEPS:${NC}"
    echo ""
    echo "1. Reboot your system or logout/login to apply shell changes"
    echo "2. Start Hyprland session"
    echo "3. Run 'wal -i /path/to/your/wallpaper' to generate color schemes"
    echo "4. Your dotfiles are managed with Stow in ~/.dotfiles/"
    echo "5. Add wallpapers to ~/wallpapers/"
    echo ""
    echo -e "${BLUE}Dotfiles Management:${NC}"
    echo "• cd ~/.dotfiles && ./stow.sh list    - List available packages"
    echo "• ./stow.sh install all              - Install all dotfiles"
    echo "• ./stow.sh remove waybar            - Remove specific config"
    echo "• ./stow.sh restow all               - Reapply all configs"
    echo ""
    echo -e "${BLUE}Useful commands:${NC}"
    echo "• neofetch        - Show system info with ASCII art"
    echo "• btop            - Modern system monitor"
    echo "• ranger          - File manager"
    echo "• cava            - Audio visualizer"
    echo "• colorscript -l  - List available color scripts"
    echo "• welcome         - Show welcome message"
    echo ""
    echo -e "${GREEN}Your dotfiles are now managed with Stow! 📁${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Main installation function
main() {
    echo -e "${CYAN}"
    figlet -f slant "ARCH TUI RICE"
    echo -e "${NC}"
    echo "This script will install and configure a complete TUI-based rice for Hyprland"
    echo ""
    read -p "Continue with installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    
    print_status "Starting installation..."
    
    check_arch
    install_paru
    install_core_packages
    install_tui_apps
    install_aur_packages
    install_fonts
    setup_zsh
    setup_dotfiles_structure
    create_hypr_config
    create_waybar_config
    create_kitty_config
    create_welcome_script
    setup_zshrc
    create_stow_script
    apply_stow_configs
    
    show_final_instructions
}

# Run main function
main "$@"
