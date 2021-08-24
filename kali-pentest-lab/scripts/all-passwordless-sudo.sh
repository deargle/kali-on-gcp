#!/bin/bash -ex

FILE=/etc/sudoers.d/all-users-passwordless

if [ ! -f $FILE ]; then
  cat <<EOF > $FILE
ALL ALL=(ALL:ALL) NOPASSWD:ALL
EOF

  echo "file written to disk."
else
  echo "file already exists, doing nothing..."
fi
