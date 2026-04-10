---
name: Add new compositor
about: Module for adding support to a new compositor
title: 'Add compositor: compositor-name'
labels: enhancement, new compositor
assignees: ''

---

**Compositor:** <Your compositor here> <version>

**Distro:** <Your distro here> <version>

**Environment:**
First command:
```sh
loginctl show-session "$(loginctl | grep "$(whoami)" | awk '{print $1}' | head -1)" -p Desktop
```
My output:
```
<Your output here>
```
Second command:
```sh
echo $XDG_SESSION_DESKTOP
```
My output:
```
<Your output here>
```

**Command to get the focused window PID:** <Command here> (must return the pid number and nothing else, like `12345`)

**Does mouse input work in other XWayland apps like Discord when pausing XWayland games?** <yes/no>

**Any other issues or relevant info:**
