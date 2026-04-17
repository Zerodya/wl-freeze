---
name: Add new compositor
about: Module for adding support to a new compositor
title: 'Add compositor: compositor-name'
labels: enhancement, new compositor
assignees: ''

---

**Compositor:** <Your compositor here> <version>

**Distro:** <Your distro here> <version>

**Environment 1** (run command):
```sh
loginctl show-session "$(loginctl | grep "$(whoami)" | awk '{print $1}' | head -1)" -p Desktop
```
```sh
<Your output here>
```

**Environment 2** (run command):
```sh
echo $XDG_SESSION_DESKTOP
```
```sh
<Your output here>
```

**Command to get the focused window PID:** `<Command here>` (must return the pid number and nothing else, like `12345`)


**Command debug** (run command):
```sh
wl-freeze -c "your-command-here" --debug
```
```sh
<Your output here>
```


**Does mouse input work in other XWayland apps like Discord when pausing XWayland games?** <yes/no>

**Any other issues or relevant info:**
