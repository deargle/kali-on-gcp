#!/bin/bash -ex

if ! dpkg -s nessus &> /dev/null ; then
  DEBIAN_FRONTEND=noninteractive \
    apt-get install --assume-yes jq

  # fetch list of downloads
  wget -O nessus.json https://www.tenable.com/downloads/api/v1/public/pages/nessus

  # get latest release of version 8
  VERSION=`jq -rj '[.downloads[] | select( (.meta_data.product | startswith("Nessus")) and (.meta_data.version | startswith("8")))] | [.[].meta_data.version] | unique | max | tostring' nessus.json`

  # get the id for the one that is:
  # - is Nessus
  # - amd64 .deb latest version
  # - contains "Kali"
  ID=`jq -rj --arg VERSION "$VERSION" '.downloads[] | select(( .meta_data.product | startswith("Nessus") ) and ((.meta_data.version|tostring)==$VERSION) and (.file | endswith("amd64.deb")) and (.description | contains("Kali"))) | .id' nessus.json`

  wget -O nessus.deb "https://www.tenable.com/downloads/api/v1/public/pages/nessus/downloads/${ID}/download?i_agree_to_tenable_license_agreement=true"
  dpkg -i nessus.deb
else
  echo 'nessus already installed, skipping...'
fi
systemctl enable nessusd
systemctl start nessusd
