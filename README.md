# Kali on GCP

__Currently builds Kali 2021.2__

Heads up! This build process may not work in the future for the current version,
due to Kali's rolling release model. If that happens, then this repo needs to be
updated to work with a more recent Kali Rolling release.

---

This repository lets you build a version of Kali that will run on GCP. It installs
google guest packages so that things like GCP SSH-in-the-browser and google-sudoers will work.

Look in the provisioners in `templates/kali.json` to see what all is installed.

It works like this:

* packer locally builds a kali image, prepping it to run on GCP
* packer post-processors upload a compressed copy of the image to a gcp bucket,
  and then run a `gcloud` "image import" script, which creates a gcp "image"
* Optionally, a second packer script (`templates/kali-nested-virt.json`) creates a
  new image based on the first, adding licenses which enable nested virtualization
  within Kali on GCP.


## Before you build

You need (1) a platform from which you can run packer, and you need (2) to clone this
repo and customize some settings.

### 1. Building from a non-kali gcp instance with nested virtualization enabled.

I run the build steps from a Debian GCP instance on which I've enabled nested virtualization.
* Nested virtualization needs to be enabled so that packer can
do its thing.
* Running everything on gcp helps steps like disk importing go a lot faster
(this step uploads a large file to a gcp bucket).
* Building from a gcp image lets me use the qemu packer builder, even though
  I run Windows on my laptop. There's no real benefit to using qemu over some
  other builder, though.

1. First, create a GCP instance with nested virtualization enabled. See [this document about enabling nested virtualization](https://cloud.google.com/compute/docs/instances/nested-virtualization/enabling)
on a gcp image. Either method described in that document requires using `gcloud`. You could run that from
a [gcp cloud shell](https://cloud.google.com/shell) to avoid having to configure your local machine.

   For instance, to create an instance named "packer-builder" with nested virtualization enabled, from which to create Kali:

   ```
   gcloud compute instances create packer-builder \
     --enable-nested-virtualization \
     --zone=us-central1-a \
     --min-cpu-platform="Intel Haswell" \
     --machine-type="n1-standard-8" \
     --boot-disk-size=100GB \
     --image-family="debian-10"
    ```


2.  ssh to the instance using gcp's ssh-in-the-browser. Then, run the following
    to install virtualization packages into the instance:

    ```
    sudo apt update -y && sudo apt install -y git software-properties-common

    # install packer

    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install packer

    # Install qemu-kvm & libvirt packages

    sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon virt-manager -y


    # Install some gtk stuff, idk, found it on https://github.com/sickcodes/Docker-OSX/issues/7

    sudo apt install x11-sxerver-utils
    xhost +
  ```

3.  Next, check out this repository to your gcp instance:

    ```
    git clone https://github.com/deargle/kali-on-gcp && cd kali-on-gcp
    ```

4. Then, proceed below to customize settings, then build with packer.

### 2. Customizing settings

You need to customize a few things in the `templates/kali-*.json` files:

* Configure the googlecompute-import provisioner.
  * add your gcp bucket name
    * You'll also need to actually create the bucket on gcp that you specify in the user vars.
  * add your project id
  * add the filename to a gcp service account private key file that has access to create images, access gcp buckets, etc. This repo assumes a service
    keyfile named `account.json` in the root of this repository.
    * see [how to create a gcp service account and get a private key file for it](#)
* Specify a public ssh key -- this will be put into `/root/.ssh/authorized_keys`. ssh login with ssh key is permitted for root on this build.
  * **This means that if you use my prebuilt images, I can in theory ssh in as root to your kali instance via your instance's public ip address (if any).**

    If you're not comfortable with this, you can build your own Kali image, setting
    your own ssh key.


## Building

Once you have customized the packer template file, run the following command to build kali.

```.terminal
$ packer build templates/kali-rolling.json
```

Or, with more verbose output:

```.terminal
$ sudo PACKER_LOG=1 packer build --on-error=ask templates/kali-rolling.json
```

## Optional: create a version with nested virtualization enabled

Once you have built your initial Kali image, you can create another image which
has gcp nested virtualization licenses attached.

Open `templates/kali-nested-virt.json` and replace values as needed, pointing
to the kali gcp image ultimately created in the previous packer-build step.

Then,

```.terminal
$ packer build templates/kali-nested-virt.json
```


### Historical: Customizations that were necessary for Kali Rolling 2019.3

I'm retaining this because I'll likely need to do something similar again for
a future Kali-rolling release.

When I needed to build Kali 2019.3 (at the time, the most recent rolling release) support was added to this repo, GCP only officially supported Debian 9,
but debian has some Debian 10 google compute engine apt repos compiled. However, a few
extra package installations are required to get GCP onto Kali 2019.3

* install libjson-c3 -- required by google-compute-instance debian packages
* install stretch versions of openssh-client and openssh-server, and regenrate openssh-server host keys.
  *   Without this, ssh-in-the-browser (the `ssh` button in GCP) does not work. But, regular ssh does work. From my debugging,
    I saw that the ssh client (ssh in the browser) was disconnecting after the kali openssh-server sent its host keys. Internet
    suggests that at this point, the client would be told that it cannot verify the authenticity of the server, do you want to continue,
    etc, but shrug. Downgrading and regenerating worked on a moonshot.
* remove `/etc/hostname` so that the hostname can be dynamically set by gcp to whatever the instance name is


## A pentesting lab within kali on gcp!

I have some vagrant boxes that have configs that put them on a network so that they
can be reached by kali, the host. Uses `livbirt` / `virt-manager`. Requires a little
bit more configuration of kali, build script is in the vagrantfile in the [kali-pentest-lab](kali-pentest-lab) folder.

And my vagrant boxes are [here](https://app.vagrantup.com/deargle).
