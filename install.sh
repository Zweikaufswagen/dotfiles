#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$HOME/.local/bin:$PATH"

die() { printf 'Fehler: %s\n' "$*" >&2; exit 1; }

as_root() {
    if [[ $(id -u) -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        die "Für die Paketinstallation wird sudo benötigt."
    fi
}

case "$(uname -s)" in
    Linux|Darwin) ;;
    *) die "Bitte unter Linux, WSL oder macOS ausführen; unter Windows in WSL." ;;
esac

missing=()
for dependency in git curl zsh tar gzip; do
    if ! command -v "$dependency" >/dev/null 2>&1; then
        missing+=("$dependency")
    fi
done

if ((${#missing[@]})); then
    printf 'Installiere fehlende Pakete: %s\n' "${missing[*]}"
    if [[ $(uname -s) == Darwin ]]; then
        command -v brew >/dev/null 2>&1 || die "Bitte zuerst Homebrew installieren: https://brew.sh"
        brew install "${missing[@]}"
    elif command -v apt-get >/dev/null 2>&1; then
        as_root apt-get update
        as_root apt-get install -y "${missing[@]}" ca-certificates
    elif command -v dnf >/dev/null 2>&1; then
        as_root dnf install -y "${missing[@]}" ca-certificates
    elif command -v pacman >/dev/null 2>&1; then
        as_root pacman -S --needed --noconfirm "${missing[@]}" ca-certificates
    else
        die "Kein unterstützter Paketmanager. Bitte installieren: ${missing[*]}"
    fi
fi

if ! command -v starship >/dev/null 2>&1; then
    printf 'Installiere Starship nach ~/.local/bin …\n'
    installer="$(mktemp)"
    trap 'rm -f -- "$installer"' EXIT
    curl --fail --show-error --location https://starship.rs/install.sh --output "$installer"
    mkdir -p "$HOME/.local/bin"
    sh "$installer" --yes --bin-dir "$HOME/.local/bin"
    command -v starship >/dev/null 2>&1 || die "Starship wurde nicht erfolgreich installiert."
fi

zsh_dir="$HOME/.oh-my-zsh"
if [[ ! -f "$zsh_dir/oh-my-zsh.sh" ]]; then
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$zsh_dir"
fi

plugins_dir="${ZSH_CUSTOM:-$zsh_dir/custom}/plugins"
mkdir -p "$plugins_dir"
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    if [[ ! -f "$plugins_dir/$plugin/$plugin.plugin.zsh" ]]; then
        git clone --depth=1 "https://github.com/zsh-users/$plugin.git" "$plugins_dir/$plugin"
    fi
done

link_config() {
    local source="$1" target="$2" backup
    mkdir -p "$(dirname -- "$target")"
    if [[ -L "$target" && $(readlink "$target") == "$source" ]]; then
        printf 'Bereits verlinkt: %s\n' "$target"
        return
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        backup="$target.backup.$(date +%Y%m%d-%H%M%S).$$"
        mv -- "$target" "$backup"
        printf 'Sicherung: %s\n' "$backup"
    fi
    ln -s -- "$source" "$target"
    printf 'Verlinkt: %s\n' "$target"
}

link_config "$repo_dir/.zshrc" "${ZDOTDIR:-$HOME}/.zshrc"
link_config "$repo_dir/starship.toml" "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"

if [[ -n ${STARSHIP_CONFIG:-} && $STARSHIP_CONFIG != "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml" ]]; then
    printf 'Hinweis: STARSHIP_CONFIG=%s überschreibt den Standardpfad. Bitte anpassen oder entfernen.\n' "$STARSHIP_CONFIG"
fi

printf '\nFertig! Starte zsh mit: exec zsh\n'
printf 'VSCodium nutzt in diesem Repo AnnotationMNerdFont aus .vscode/settings.json.\n'
