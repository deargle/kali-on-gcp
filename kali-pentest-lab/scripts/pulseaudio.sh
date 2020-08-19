#!/usr/bin/bash -ex
# nu11secur1ty - http://nu11secur1ty.com/
# Taken from: https://github.com/nu11secur1ty/pulseaudio

##### Running pulseaudio autostart ~ gui desktop audio
echo -e "\n\e[01;32m[+]\e[00m Preparing pulseaudio-user"
file=/usr/local/bin/pulseaudio.sh; [ -e $file ] && cp -n $file{,.bkup}

cat <<EOF> $file
#!/bin/bash
timeout 10 pulseaudio -D
sleep 15
exit 0;
EOF

chmod 0755 $file

file=/etc/xdg/autostart/pulseaudioscript.sh.desktop; [ -e $file ] && cp -n $file{,.bkup}
cat <<EOF> $file
[Desktop Entry]
Type=Application
Exec=/usr/local/bin/pulseaudio.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=pulseaudio-user
Name=pulseaudio-user
Comment[en_US]=
Comment=
EOF

sleep 5;
exit 0;
