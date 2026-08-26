#!/bin/bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
THEME_NAME="$(basename "$SCRIPT_DIR")"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'
log_info()  { echo -e "${GREEN}[+]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_head()  { echo -e "\n${CYAN}=== $1 ===${NC}"; }
copy_dir() {
    local src="$1" dest="$2"
    if [ -d "$src" ]; then
        mkdir -p "$dest"
        cp -rf "$src"/* "$dest/" 2>/dev/null && log_info "$(basename "$src")" || true
    fi
}
box_width=$(( ${#THEME_NAME} + 21 ))
printf -v line '%*s' "$box_width" ''
line=${line// /═}
echo -e "${CYAN}╔${line}╗${NC}"
echo -e "${CYAN}║  Theme Installer: ${THEME_NAME}  ║${NC}"
echo -e "${CYAN}╚${line}╝${NC}"
if [ -d "${SCRIPT_DIR}/plasma/desktoptheme" ]; then
    log_head "Plasma Desktop Themes"
    for d in "${SCRIPT_DIR}/plasma/desktoptheme"/*/; do
        [ -d "$d" ] || continue
        copy_dir "$d" "${HOME}/.local/share/plasma/desktoptheme/$(basename "$d")"
    done
    log_info "installed at ${HOME}/.local/share/plasma/desktoptheme/"
fi
if [ -d "${SCRIPT_DIR}/plasma/look-and-feel" ]; then
    log_head "Plasma Look & Feel"
    for d in "${SCRIPT_DIR}/plasma/look-and-feel"/*/; do
        [ -d "$d" ] || continue
        copy_dir "$d" "${HOME}/.local/share/plasma/look-and-feel/$(basename "$d")"
    done
    log_info "installed at ${HOME}/.local/share/plasma/look-and-feel/"
fi
if [ -d "${SCRIPT_DIR}/aurorae" ]; then
    log_head "Aurorae Window Decorations"
    for d in "${SCRIPT_DIR}/aurorae"/*/; do
        [ -d "$d" ] || continue
        copy_dir "$d" "${HOME}/.local/share/aurorae/themes/$(basename "$d")"
    done
    log_info "installed at ${HOME}/.local/share/aurorae/themes/"
fi
if [ -d "${SCRIPT_DIR}/color-schemes" ]; then
    log_head "Color Schemes"
    mkdir -p "${HOME}/.local/share/color-schemes"
    for f in "${SCRIPT_DIR}/color-schemes"/*.colors; do
        [ -f "$f" ] || continue
        cp -f "$f" "${HOME}/.local/share/color-schemes/"
        log_info "$(basename "$f")"
    done
    log_info "installed at ${HOME}/.local/share/color-schemes/"
fi
if [ -d "${SCRIPT_DIR}/Kvantum" ]; then
    log_head "Kvantum Themes"
    for d in "${SCRIPT_DIR}/Kvantum"/*/; do
        [ -d "$d" ] || continue
        copy_dir "$d" "${HOME}/.config/Kvantum/$(basename "$d")"
    done
    [ -f "${SCRIPT_DIR}/Kvantum/kvantum.kvconfig" ] && cp -f "${SCRIPT_DIR}/Kvantum/kvantum.kvconfig" "${HOME}/.config/Kvantum/" && log_info "kvantum.kvconfig"
    log_info "installed at ${HOME}/.config/Kvantum/"
fi
if [ -d "${SCRIPT_DIR}/themes" ]; then
    log_head "GTK Themes"
    for d in "${SCRIPT_DIR}/themes"/*/; do
        [ -d "$d" ] || continue
        copy_dir "$d" "${HOME}/.themes/$(basename "$d")"
    done
    log_info "installed at ${HOME}/.themes/"
fi
if [ -d "${SCRIPT_DIR}/icons" ]; then
    log_head "Icons & Cursors"
    for d in "${SCRIPT_DIR}/icons"/*/; do
        [ -d "$d" ] || continue
        if [ -d "$d/cursors" ]; then
            copy_dir "$d" "${HOME}/.icons/$(basename "$d")"
        else
            copy_dir "$d" "${HOME}/.local/share/icons/$(basename "$d")"
        fi
    done
    log_info "cursors installed at ${HOME}/.icons/"
    log_info "icons installed at ${HOME}/.local/share/icons/"
fi
if [ -d "${SCRIPT_DIR}/fonts" ]; then
    log_head "Fonts"
    mkdir -p "${HOME}/.local/share/fonts"
    find "${SCRIPT_DIR}/fonts" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp -f {} "${HOME}/.local/share/fonts/" \;
    fc-cache -f "${HOME}/.local/share/fonts" 2>/dev/null
    log_info "installed at ${HOME}/.local/share/fonts/"
fi
if [ -d "${SCRIPT_DIR}/wallpapers" ]; then
    log_head "Wallpapers"
    for d in "${SCRIPT_DIR}/wallpapers"/*/; do
        [ -d "$d" ] || continue
        copy_dir "$d" "${HOME}/.local/share/wallpapers/$(basename "$d")"
    done
    log_info "installed at ${HOME}/.local/share/wallpapers/"
fi
HAS_SUDO=false
if [ -d "${SCRIPT_DIR}/sddm" ] || [ -d "${SCRIPT_DIR}/grub" ] || [ -d "${SCRIPT_DIR}/plymouth" ]; then
    echo ""
    read -p "Install system themes (SDDM/GRUB/Plymouth)? Requires sudo. [y/n] " -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Yy]$ ]] && HAS_SUDO=true
fi
if $HAS_SUDO; then
    if [ -d "${SCRIPT_DIR}/sddm" ]; then
        log_head "SDDM Themes"
        for d in "${SCRIPT_DIR}/sddm"/*/; do
            [ -d "$d" ] || continue
            name="$(basename "$d")"
            sudo mkdir -p "/usr/share/sddm/themes/${name}"
            sudo cp -rf "$d"/* "/usr/share/sddm/themes/${name}/"
            log_info "${name}"
        done
        log_info "installed at /usr/share/sddm/themes/"
    fi
    if [ -d "${SCRIPT_DIR}/plymouth" ]; then
        log_head "Plymouth Themes"
        for d in "${SCRIPT_DIR}/plymouth"/*/; do
            [ -d "$d" ] || continue
            name="$(basename "$d")"
            sudo mkdir -p "/usr/share/plymouth/themes/${name}"
            sudo cp -rf "$d"/* "/usr/share/plymouth/themes/${name}/"
            log_info "${name}"
        done
        log_info "installed at /usr/share/plymouth/themes/"
        log_warn "Set active: sudo plymouth-set-default-theme <name> -R"
    fi
    if [ -d "${SCRIPT_DIR}/grub" ]; then
        log_head "GRUB Themes"
        for d in "${SCRIPT_DIR}/grub"/*/; do
            [ -d "$d" ] || continue
            name="$(basename "$d")"
            sudo mkdir -p "/boot/grub/themes/${name}"
            sudo cp -rf "$d"/* "/boot/grub/themes/${name}/"
            log_info "${name}"
        done
        log_info "installed at /boot/grub/themes/"
        for f in "${SCRIPT_DIR}/grub"/*; do
            [ -f "$f" ] || continue
            name="$(basename "$f")"
            sudo cp -f "$f" "/etc/grub.d/${name}"
            sudo chmod +x "/etc/grub.d/${name}"
            log_info "grub.d: ${name}"
        done
        log_info "installed at /etc/grub.d/"
        log_warn "Update /etc/default/grub → GRUB_THEME=/boot/grub/themes/<name>/theme.txt"
        log_warn "Then run: sudo grub-mkconfig -o /boot/grub/grub.cfg"
    fi
fi
if [ -d "${SCRIPT_DIR}/konsole" ]; then
    log_head "Konsole Profiles"
    mkdir -p "${HOME}/.local/share/konsole"
    for f in "${SCRIPT_DIR}/konsole"/*; do
        [ -f "$f" ] || continue
        cp -f "$f" "${HOME}/.local/share/konsole/"
        log_info "$(basename "$f")"
    done
    log_info "installed at ${HOME}/.local/share/konsole/"
fi
if [ -d "${SCRIPT_DIR}/oh-my-posh" ]; then
    log_head "Oh My Posh"
    mkdir -p "${HOME}/.config/oh-my-posh/themes"
    for f in "${SCRIPT_DIR}/oh-my-posh"/*.json; do
        [ -f "$f" ] || continue
        cp -f "$f" "${HOME}/.config/oh-my-posh/themes/"
        log_info "$(basename "$f")"
    done
    log_info "installed at ${HOME}/.config/oh-my-posh/themes/"
fi
if [ -d "${SCRIPT_DIR}/Google/AndroidStudio" ]; then
    log_head "Android Studio Themes"
    andest=""
    for f in "${SCRIPT_DIR}/Google/AndroidStudio"/*.jar; do
        [ -f "$f" ] || continue
        for dest in "${HOME}/.local/share/Google/AndroidStudio"*/; do
            [ -d "$dest" ] || continue
            cp -f "$f" "$dest"
            log_info "$(basename "$f")"
            andest="$dest"
        done
    done
    [ -n "$andest" ] && log_info "installed at $andest"
fi
if [ -d "${SCRIPT_DIR}/godot" ]; then
    log_head "Godot Editor Themes"
    mkdir -p "${HOME}/.config/godot/text_editor_themes"
    for f in "${SCRIPT_DIR}/godot"/*; do
        [ -f "$f" ] || continue
        cp -f "$f" "${HOME}/.config/godot/text_editor_themes/"
        log_info "$(basename "$f")"
    done
    log_info "installed at ${HOME}/.config/godot/text_editor_themes/"
fi
echo ""
log_head "Done!"
echo -e "${GREEN}${THEME_NAME} theme installed successfully.${NC}"
echo ""
