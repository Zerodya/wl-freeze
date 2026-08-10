# ❄️ wl-freeze 

**wl-freeze** is a community-driven utility to **suspend a game process** (and other programs) in Wayland compositors.

https://github.com/user-attachments/assets/7ffdfde5-2028-4936-b61c-092b2cf224c3

**Useful to:**
- Pause single-player games that can't normally be paused (Elden Ring, Baldur's Gate 3, ...)
- Pause cutscenes to read the subtitles or if you suddenly need to leave your desk
- Save system resources (excluding RAM) if you need them for another computer task, or if the game's pause menu uses too many

> Why **community-driven**? 
>
> This script has to extract the Process ID number (PID) from the game window and then use a custom logic to correctly suspend it.
>
> But in Wayland **each compositor has its own way** to extract the PID from the currently focused window, so this script relies on **people like you** to add support to new compositors. See how below!

## Supported compositors
> **NOTE:** Playing via **Wayland** (Proton Wayland or Gamescope) is *HIGHLY RECOMMENDED.*
>
> Pausing XWayland windows is possible, but it may not be the best experience and we have to use workarounds for that. Check [Known issues](#known-issues) to learn more.

| Compositor | XWayland workaround | Notes | Contributors |
|------------|-------------|-------|-------------|
| **Hyprland** | ✅ Implemented |  |  |
| **KDE Plasma** | ✅ Implemented | We also unfullscreen the game because Plasma glitches when trying to switch to a workspace containing a frozen window in fullscreen | @ExistingPerson08 |
| **Niri** | ✅ Implemented | Assumes Niri + xwayland-satellite setup for XWayland games |  |
| **Sway** | ⚠️ Not yet implemented |  | @alterNERDtive |

### Other compositors

If your compositor is not natively supported, you can use the `-c` flag with a command that outputs the focused window's PID. Example for Niri:

```bash
wl-freeze -c "niri msg --json focused-window | jq '.pid'"
```
The command output must be the pid number and nothing else, like: `12345`.

Please consider [opening an issue](https://github.com/Zerodya/wl-freeze/issues) and fill the template so that it can be implemented natively. Thank you!

## Installation
### Arch Linux
Available in the AUR:
- [wl-freeze-git](https://aur.archlinux.org/packages/wl-freeze-git)
- [wl-freeze](https://aur.archlinux.org/packages/wl-freeze)

(Contact their respective maintainers if there are issues with the PKGBUILDs)

### NixOS
Available in [nixpkgs](https://search.nixos.org/packages?channel=unstable&query=wl-freeze).

### Manual
**Dependencies**
- `jq` to parse JSON
- `psmisc` contains `pstree` which is required to list child processes
- `libnotify` for desktop notifications 
- `xdotool` to find the PID of XWayland windows created via `xwayland-satellite`, as well as a fallback method for XWayland window detection
- `kdotool` to find the PID of windows in KWin (KDE Plasma)
- `qdbus6`/`qttols` for interacting windows and workspaces in KWin (KDE Plasma)

**Symlink script**

Clone this repo and symlink the `wl-freeze` script to a directory in your `PATH`:
```bash
git clone https://github.com/Zerodya/wl-freeze.git
ln -s $(pwd)/wl-freeze/wl-freeze $HOME/.local/bin
```
**Shell Completions**

<details><summary>Bash</summary>
<p>

```bash
sudo ln -s $(pwd)/completions/bash/wl-freeze /usr/share/bash-completion/completions/
```
</p>
</details> 

<details><summary>Zsh</summary>
<p>

```bash
sudo ln -s $(pwd)/completions/zsh/_wl-freeze /usr/share/zsh/site-functions/
```
</p>
</details> 

<details><summary>Fish</summary>
<p>

```bash
sudo ln -s $(pwd)/completions/fish/wl-freeze.fish /usr/share/fish/completions/
```
</p>
</details> 


## Usage

### Bind it in your compositor
```sh
# Hyprland
bind = , PAUSE, exec, wl-freeze -a

# KDE Plasma
## Settings -> Keyboard -> Shortcuts -> Add New (Command or Script...) -> Add a script that launches `wl-freeze -a`

# Niri
binds {
    Mod+Pause { spawn "wl-freeze" "-a"; }
}

# Sway
bindsym Pause exec wl-freeze -a
```

### Available flags
```
-h, --help            show help message

-a, --active          toggle suspend by active window
-p, --pid             toggle suspend by process id
-n, --name            toggle suspend by process name/command
-c, --custom          toggle suspend by custom command (outputs a PID)

-s, --silent          don't send notification
-t, --notif-timeout   notification timeout in milliseconds (default 5000)
--dry-run             don't actually suspend/resume a process
--debug               enable debug mode
--no-xwayland-mouse-release  skip the XWayland mouse capture release
```

### Examples:

```sh
# Pause game by process name
wl-freeze -n eldenring.exe

# Pause game by using your compositor window picker (example for Hyprland)
wl-freeze -c "hyprprop | jq '.pid'"
```

## Known issues
- **When pausing XWayland**: Pausing XWayland games (no Proton Wayland or Gamescope) will stop the mouse from working in other XWayland apps like Steam. 
  - **workaround**: A workaround has already been implemented in the script to quickly switch workspaces back and forth before pausing the target window in order to release the mouse capture. This needs to be implemented differently for each compositor, so some of them may not support it yet.
- **When pausing native games**: System audio may stop when pausing native Linux games (no Proton/Wine) like Minecraft. This is a Pipewire [issue](https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/3509).
  - **workaround**: Run the game with the env variable: `ALSOFT_DRIVERS=pulse`

## FAQ
- **Q:** How is this better than just sending SIGSTOP and SIGCONT signals manually?

  - **A:** Obviously, it's way more ergonomic. But what actually makes it better is: 
    1. A **robust freezing logic** that captures and stops the entire process tree to suspend the game properly. Using SIGSTOP on just the parent process will give you issues in most games, like audio and game logic still playing in the background. This is true especially when using `gamescope`.
    2. Ways to get the **actual game PID** when using things like `xwayland-satellite` that hide the real game PID.
    3. A **mouse capture release** before pausing XWayland windows. If you freeze a XWayland game while the mouse cursor is still inside the game window, you're going to trap it and mouse input will stop working in other XWayland windows too.

- **Q:** Why Bash and not a more robust language?

  - **A:** I wanted something that didn't require compiling, but that was also very fast for quick pausing, so Python was out of the question. If I ever start to find Bash limiting I may give in and rewrite it in Rust.

- **Q:** Can this script suspend games to disk?

  - **A:** No, only to RAM. There is currently no way to suspend and resume complex software like Proton games to disk, and if there is, I'd be happy to be proven wrong.

## 📄 Disclaimer
There is always the risk, although slim, that an application may crash.

This is intrinsically related to modifying running processes and is not something that wl-freeze can prevent.

Please make sure to **save your data** before using wl-freeze.
