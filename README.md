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

## 🖥️ Supported compositors
- **Hyprland**
- **Sway**
- **Niri**

### Unsupported compositors

If your compositor is not natively supported, you can use the `-c` flag with a command that outputs the focused window's PID. Example for Niri:

```bash
wl-freeze -c "niri msg --json focused-window | jq '.pid'"
```
The command output must be the pid number and nothing else, like: `12345`.

### Adding support for new compositors
If your compositor is not supported yet, please consider [opening an issue](https://github.com/Zerodya/wl-freeze/issues) and fill the template so that it can be implemented natively. Thank you!

## 📦 Installation
### Arch Linux
Available in the [AUR](https://aur.archlinux.org/packages/wl-freeze-git). (Maintained by [Aethar](https://github.com/Aethar01))

### NixOS
Available in [nixpkgs](https://search.nixos.org/packages?channel=unstable&query=hyprfreeze).  **(update pending)**

### Manual
**Dependencies**
- `jq` to parse JSON
- `psmisc` contains `pstree` which is required to list child processes
- `xdotool` to find the PID of XWayland windows created via `xwayland-satellite` (Mainly for **Niri**)
- `libnotify` for desktop notifications (Optional)

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


## 🧰 Usage

### Bind it in your compositor
```sh
# Hyprland
bind = , PAUSE, exec, wl-freeze -a

# Sway
bindsym Pause exec wl-freeze -a

# Niri
binds {
    Mod+Pause { spawn "wl-freeze" "-a"; }
}
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

## 🐛 Known issues
- **When pausing native games**: System audio may stop when pausing Linux native games (no Proton/Wine) like Minecraft. This is a Pipewire [issue](https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/3509).
  - **workaround**: Run the game with the env variable: `ALSOFT_DRIVERS=pulse`

- **When pausing Gamescope**: Game audio and input may still work when pausing Gamescope windows. This is because `wl-freeze` doesn't implement a logic to find the PID of the actual game inside Gamescope yet, so it just pauses the Gamescope PID which is not optimal. This is something I plan to fix in the future.

- **When pausing XWayland**: Pausing XWayland games (no Gamescope or Proton Wayland) may stop the mouse from working in other XWayland apps like Discord. 
  - **workaround**: A mouse capture release has been implemented that quickly switches workspaces before pausing the window, but this may not be implemented for all compositors right now. Please open an issue to help support your compositor too! See below:
    - Hyprland: Implemented ✅
    - Sway: Not implemented ❌
    - Niri: Implemented ✅

## 📜 FAQ
- **Q:** How is this better than just sending SIGSTOP and SIGCONT signals manually?

  - **A:** Obviously, it's way more ergonomic. But what actually makes it better is: 
    1. A robust freezing logic that captures and stops the entire process tree to suspend the game properly. Using SIGSTOP on just the parent process will give you issues in most games.
    2. Ways to get the actual game PID when using things like `xwayland-satellite` that hide the real game PID.
    3. A mouse capture release before pausing XWayland windows. If you freeze a XWayland game while the mouse cursor is still inside the game window, you're going to trap it and mouse input will stop working in other XWayland windows too.

- **Q:** Why Bash and not a more robust language?

  - **A:** I wanted something that didn't require compiling, but that was also very fast for quick pausing, so Python was out of the question. If I ever start to find Bash limiting I may give in and rewrite it in Rust.

- **Q:** Can this script suspend games to disk?

  - **A:** No, only to RAM. There is currently no way to suspend and resume complex software like Proton games to disk, and if there is, I'd be happy to be proven wrong.

## 📄 Disclaimer
There is always the risk, although slim, that an application may crash.

This is intrinsically related to modifying running processes and is not something that wl-freeze can prevent.

Please make sure to **save your data** before using wl-freeze.
