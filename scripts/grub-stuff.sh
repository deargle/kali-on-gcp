#!/bin/bash -e

sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*$/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX=.*$/GRUB_CMDLINE_LINUX=\"console=tty0 console=ttyS0,38400n8d\"/' /etc/default/grub
update-grub
