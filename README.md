# Dotfiles

Meine Git- und zsh-Konfiguration mit **Starship, Catppuccin Mocha und Powerline**.
Der Prompt zeigt Benutzer, Verzeichnis, Git-Branch und Status sowie die Uhrzeit.
Eine kompakte eigene Konfiguration, inspiriert vom
[Catppuccin-Powerline-Preset](https://starship.rs/presets/catppuccin-powerline).

## Einrichten

Im Repo-Verzeichnis ausführen, unter Windows in **WSL**:

```sh
bash install.sh
exec zsh
```

Das Skript installiert fehlende Voraussetzungen: Git, curl, zsh, tar, gzip,
[Starship](https://starship.rs/), [Oh My Zsh](https://ohmyz.sh/),
zsh-autosuggestions und zsh-syntax-highlighting. Unterstützt werden Linux/WSL
mit apt, dnf oder pacman sowie macOS mit bereits installiertem Homebrew.
Für Systempakete wird bei Bedarf `sudo` verwendet. Das Skript als normaler
Benutzer starten, damit die Dotfiles im eigenen Home-Verzeichnis landen.
Downloads benötigen Internetzugriff auf starship.rs und GitHub.

Starship wird bei Bedarf über den offiziellen Installer nach `~/.local/bin`
installiert. Vorhandene Programme und Plugins werden beibehalten.
`.zshrc` und `starship.toml` werden verlinkt; vorhandene Zieldateien werden als
`*.backup.<Zeitstempel>.<PID>` gesichert. Erneutes Ausführen ist möglich.
Das Repo muss an seinem Platz bleiben, damit die Links funktionieren.

`XDG_CONFIG_HOME`, `ZDOTDIR` und `ZSH_CUSTOM` werden berücksichtigt.
Falls `STARSHIP_CONFIG` bereits gesetzt ist, muss es auf die verlinkte
`starship.toml` zeigen oder entfernt werden. Die Login-Shell wird nicht geändert;
zum direkten Start in VSCodium das zsh-Terminalprofil auswählen.

## Schrift in VSCodium

Die auf deinem PC bereits installierte **AnnotationMNerdFont** ist in
`.vscode/settings.json` als Terminal-Schrift eingetragen. Öffne diesen Ordner
in VSCodium; die Einstellung gilt für diesen Workspace, auch beim Arbeiten in WSL.
Eine zusätzliche Font-Installation in WSL ist nicht nötig.

Für alle Projekte dieselbe Einstellung in VSCodium unter
**Einstellungen (JSON) öffnen** in die Benutzereinstellungen übernehmen:

```json
"terminal.integrated.fontFamily": "'AnnotationMNerdFont', monospace"
```

Falls die Schrift vom Betriebssystem unter einem abweichenden Familiennamen
angezeigt wird, diesen Namen statt des Font-Dateinamens verwenden. Nach einer
Font-Installation VSCodium neu starten. Starship selbst legt keine Schrift fest.

## Anpassen

Farben und Segmente stehen in `starship.toml`, die Shell-Konfiguration in `.zshrc`.
Oh My Zsh lädt die Plugins; Starship übernimmt den Prompt.

Optional die Git-Konfiguration übernehmen; vorher Name und E-Mail in
`.gitconfig` anpassen und eine vorhandene `~/.gitconfig` sichern:

```sh
ln -s "$PWD/.gitconfig" "$HOME/.gitconfig"
```
