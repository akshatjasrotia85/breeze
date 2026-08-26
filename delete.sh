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
rm_dir() {
    local name="$1" dest="$2"
    if [ -d "$dest/$name" ]; then
        rm -rf "$dest/$name"
        log_info "$name"
    fi
}
box_width=$(( ${#THEME_NAME} + 20 ))
printf -v line '%*s' "$box_width" ''
line=${line// /═}
echo -e "${CYAN}╔${line}╗${NC}"
echo -e "${CYAN}║  Theme Remover: ${THEME_NAME}  ║${NC}"
echo -e "${CYAN}╚${line}╝${NC}"
if [ -d "${SCRIPT_DIR}/plasma/desktoptheme" ]; then
    log_head "Plasma Desktop Themes"
    for d in "${SCRIPT_DIR}/plasma/desktoptheme"/*/; do
        [ -d "$d" ] || continue
        rm_dir "$(basename "$d")" "${HOME}/.local/share/plasma/desktoptheme"
    done
fi
if [ -d "${SCRIPT_DIR}/plasma/look-and-feel" ]; then
    log_head "Plasma Look & Feel"
    for d in "${SCRIPT_DIR}/plasma/look-and-feel"/*/; do
        [ -d "$d" ] || continue
        rm_dir "$(basename "$d")" "${HOME}/.local/share/plasma/look-and-feel"
    done
fi
if [ -d "${SCRIPT_DIR}/aurorae" ]; then
    log_head "Aurorae Window Decorations"
    for d in "${SCRIPT_DIR}/aurorae"/*/; do
        [ -d "$d" ] || continue
        rm_dir "$(basename "$d")" "${HOME}/.local/share/aurorae/themes"
    done
fi
if [ -d "${SCRIPT_DIR}/color-schemes" ]; then
    log_head "Color Schemes"
    for f in "${SCRIPT_DIR}/color-schemes"/*.colors; do
        [ -f "$f" ] || continue
        rm -f "${HOME}/.local/share/color-schemes/$(basename "$f")"
        log_info "$(basename "$f")"
    done
fi
if [ -d "${SCRIPT_DIR}/Kvantum" ]; then
    log_head "Kvantum Themes"
    for d in "${SCRIPT_DIR}/Kvantum"/*/; do
        [ -d "$d" ] || continue
        rm_dir "$(basename "$d")" "${HOME}/.config/Kvantum"
    done
    [ -f "${SCRIPT_DIR}/Kvantum/kvantum.kvconfig" ] && rm -f "${HOME}/.config/Kvantum/kvantum.kvconfig" && log_info "kvantum.kvconfig"
fi
if [ -d "${SCRIPT_DIR}/themes" ]; then
    log_head "GTK Themes"
    for d in "${SCRIPT_DIR}/themes"/*/; do
        [ -d "$d" ] || continue
        rm_dir "$(basename "$d")" "${HOME}/.themes"
    done
fi
if [ -d "${SCRIPT_DIR}/icons" ]; then
    log_head "Icons & Cursors"
    for d in "${SCRIPT_DIR}/icons"/*/; do
        [ -d "$d" ] || continue
        if [ -d "$d/cursors" ]; then
            rm_dir "$(basename "$d")" "${HOME}/.icons"
        else
            rm_dir "$(basename "$d")" "${HOME}/.local/share/icons"
        fi
    done
fi
if [ -d "${SCRIPT_DIR}/fonts" ]; then
    log_head "Fonts"
    while read -r f; do
        [ -f "$f" ] || continue
        rm -f "${HOME}/.local/share/fonts/$(basename "$f")"
        log_info "$(basename "$f")"
    done < <(find "${SCRIPT_DIR}/fonts" -type f \( -name "*.ttf" -o -name "*.otf" \))
    fc-cache -f "${HOME}/.local/share/fonts" 2>/dev/null
fi
if [ -d "${SCRIPT_DIR}/wallpapers" ]; then
    log_head "Wallpapers"
    for d in "${SCRIPT_DIR}/wallpapers"/*/; do
        [ -d "$d" ] || continue
        rm_dir "$(basename "$d")" "${HOME}/.local/share/wallpapers"
    done
fi
HAS_SUDO=false
if [ -d "${SCRIPT_DIR}/sddm" ] || [ -d "${SCRIPT_DIR}/grub" ] || [ -d "${SCRIPT_DIR}/plymouth" ]; then
    echo ""
    read -p "Remove system themes (SDDM/GRUB/Plymouth)? Requires sudo. [y/n] " -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Yy]$ ]] && HAS_SUDO=true
fi
if $HAS_SUDO; then
    if [ -d "${SCRIPT_DIR}/sddm" ]; then
        log_head "SDDM Themes"
        for d in "${SCRIPT_DIR}/sddm"/*/; do
            [ -d "$d" ] || continue
            sudo rm -rf "/usr/share/sddm/themes/$(basename "$d")"
            log_info "$(basename "$d")"
        done
    fi
    if [ -d "${SCRIPT_DIR}/plymouth" ]; then
        log_head "Plymouth Themes"
        for d in "${SCRIPT_DIR}/plymouth"/*/; do
            [ -d "$d" ] || continue
            sudo rm -rf "/usr/share/plymouth/themes/$(basename "$d")"
            log_info "$(basename "$d")"
        done
        log_warn "Reset active: sudo plymouth-set-default-theme default -R"
    fi
    if [ -d "${SCRIPT_DIR}/grub" ]; then
        log_head "GRUB Themes"
        for d in "${SCRIPT_DIR}/grub"/*/; do
            [ -d "$d" ] || continue
            sudo rm -rf "/boot/grub/themes/$(basename "$d")"
            log_info "$(basename "$d")"
        done
        for f in "${SCRIPT_DIR}/grub"/*; do
            [ -f "$f" ] || continue
            name="$(basename "$f")"
            sudo rm -f "/etc/grub.d/${name}"
            log_info "grub.d: ${name}"
        done
        log_warn "Remove GRUB_THEME from /etc/default/grub"
        log_warn "Then run: sudo grub-mkconfig -o /boot/grub/grub.cfg"
    fi
fi
if [ -d "${SCRIPT_DIR}/konsole" ]; then
    log_head "Konsole Profiles"
    for f in "${SCRIPT_DIR}/konsole"/*; do
        [ -f "$f" ] || continue
        rm -f "${HOME}/.local/share/konsole/$(basename "$f")"
        log_info "$(basename "$f")"
    done
fi
if [ -d "${SCRIPT_DIR}/oh-my-posh" ]; then
    log_head "Oh My Posh"
    for f in "${SCRIPT_DIR}/oh-my-posh"/*.json; do
        [ -f "$f" ] || continue
        rm -f "${HOME}/.config/oh-my-posh/themes/$(basename "$f")"
        log_info "$(basename "$f")"
    done
fi
if [ -d "${SCRIPT_DIR}/Google/AndroidStudio" ]; then
    log_head "Android Studio Themes"
    for f in "${SCRIPT_DIR}/Google/AndroidStudio"/*.jar; do
        [ -f "$f" ] || continue
        for dest in "${HOME}/.local/share/Google/AndroidStudio"*/; do
            [ -d "$dest" ] || continue
            rm -f "$dest/$(basename "$f")"
            log_info "$(basename "$f")"
        done
    done
fi
if [ -d "${SCRIPT_DIR}/godot" ]; then
    log_head "Godot Editor Themes"
    for f in "${SCRIPT_DIR}/godot"/*; do
        [ -f "$f" ] || continue
        rm -f "${HOME}/.config/godot/text_editor_themes/$(basename "$f")"
        log_info "$(basename "$f")"
    done
fi
echo ""
log_head "Done!"
echo -e "${GREEN}${THEME_NAME} theme removed successfully.${NC}"
echo ""
