#!/bin/bash
# ----------------------------------------------------
# PT-CAD Central Automation Boot Setup (Clean App Loop)
# ----------------------------------------------------

# 1. Safely generate the target graphical autostart path
mkdir -p /home/headless/.config/autostart

# 2. Inject the persistent standalone desktop launcher
# Configured: Runs FreeCAD in the foreground. The exact millisecond you close it,
# it executes a hard xfce4-session-logout to recycle the backend window display.
cat << 'EOF' > /home/headless/.config/autostart/freecad-auto.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Auto FreeCAD
Comment=Launches FreeCAD and handles immediate clean session recycling
Exec=bash -c "/opt/FreeCAD/freecad_launcher.sh; xfce4-session-logout --logout"
Icon=freecad
Path=/opt/FreeCAD
Terminal=false
StartupNotify=false
EOF

# 3. Pre-emptively clear any saved Xfce sessions on boot to prevent the "Save Session" bug
mkdir -p /home/headless/.cache/sessions
rm -rf /home/headless/.cache/sessions/*

# 4. Ensure uniform user ownership properties back to the headless user context
chown -R headless:headless /home/headless/.config
chown -R headless:headless /home/headless/.cache

# 5. Clean out leftover trailing hooks from the bash profile if present using python
python3 -c "
path = '/home/headless/.bashrc'
with open(path, 'r') as f:
    lines = f.readlines()
clean_lines = [l for l in lines if 'DISPLAY' not in l and 'freecad' not in l and 'exit 0' not in l]
with open(path, 'w') as f:
    f.writelines(clean_lines)
"
chown headless:headless /home/headless/.bashrc

# 6. Hand execution cycles back to the container's native system startup execution stream
exec /dockerstartup/startup.sh "$@"
