# Process names and argv[0] basenames, which is what -n matches
function __wl_freeze_names
    awk 'BEGIN { RS = "\0" } FNR == 1 { n = split($0, p, "/"); n = split(p[n], p, sprintf("%c", 92)); print p[n]; f = FILENAME; sub(/cmdline$/, "comm", f); if ((getline c < f) > 0) { sub(/\n$/, "", c); print c }; close(f) }' /proc/*/cmdline 2>/dev/null | sort -u
end

complete -c wl-freeze -s h -l help -d "show help message"
complete -c wl-freeze -s a -l active -d "toggle suspend by active window"
complete -c wl-freeze -s p -l pid -d "toggle suspend by process id" -x -a "(__fish_complete_pids)"
complete -c wl-freeze -s n -l name -d "toggle suspend by process name/command" -x -a "(__wl_freeze_names)"
complete -c wl-freeze -s c -l custom -d "toggle suspend by custom command (outputs a PID)" -x
complete -c wl-freeze -s s -l silent -d "don't send notification"
complete -c wl-freeze -s t -l notif-timeout -d "notification timeout in milliseconds (default 5000)" -x -a "1000 2000 3000 5000 10000"
complete -c wl-freeze -l dry-run -d "don't actually suspend/resume a process"
complete -c wl-freeze -l debug -d "enable debug mode"
complete -c wl-freeze -l no-xwayland-mouse-release -d "skip the XWayland mouse capture release"
