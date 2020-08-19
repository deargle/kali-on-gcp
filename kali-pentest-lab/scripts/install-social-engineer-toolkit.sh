#!/bin/bash -ex

apt update
apt install -y python3-pip

###########################################################################
# social-engineer-toolkit
# https://github.com/trustedsec/social-engineer-toolkit, accessed 7/31/2020
###########################################################################

cd /opt
SET_DIR=setoolkit/
if [ ! -d $SET_DIR ]; then
  git clone https://github.com/trustedsec/social-engineer-toolkit/ $SET_DIR
  cd $SET_DIR
else
  cd $SET_DIR
  git pull
fi
pip3 install -r requirements.txt
python setup.py
