# Kali Rolling 2019.3 on GCP, qemu builder

This packer file creates an image on Google Compute Platform that has the google guest environment ready to go, based off of xfce kali 2019.3 iso.

GCP only officially supports Debian 9, but debian has some Debian 10 google compute engine apt repos compiled. However, a few
extra package installations are required to get GCP onto Kali 2019.3

* install libjson-c3 -- required by google-compute-instance debian packages
* install stretch versions of openssh-client and openssh-server, and regenrate openssh-server host keys.
	* 	Without this, ssh-in-the-browser (the `ssh` button in GCP) does not work. But, regular ssh does work. From my debugging,
		I saw that the ssh client (ssh in the browser) was disconnecting after the kali openssh-server sent its host keys. Internet
		suggests that at this point, the client would be told that it cannot verify the authenticity of the server, do you want to continue,
		etc, but shrug. Downgrading and regenerating worked on a moonshot.
* remove `/etc/hostname` so that the hostname can be dynamically set by gcp to whatever the instance name is


Look in the provisioners in `templates/kali.json` to see what is installed etc.

Things you need to customize in the `templates/kali.json` file:

* Configure the googlecompute-import provisioner.
	* add your bucket name
		* You'll also need to actually create the bucket that you specify in the user vars.
	* add your project id
	* add the filename to a gcp service account private key file that has access to create images, access gcp buckets, etc.
* Specify a public ssh key -- this will be put into `/root/.ssh/authorized_keys`. ssh login with ssh key is permitted for root on this build.

Then,

	packer build templates/kali.json

# Kali 2020.2 on GCP, libvirt / qemu builder

Fill in required fields in `kali-*.json` and `http/preseed-*.cfg`. Then,

	packer build templates/kali-2020-2.json
	packer build templates/kali-nested-virt.json

# debugging

	PACKER_LOG=1 packer build -on-error=ask templates/kali-2020-2.json

# A pentesting lab within kali on gcp!

I have some vagrant boxes that have configs that put them on a network so that they
can be reached by kali, the host. Uses `livbirt` / `virt-manager`. Requires a little
bit more configuration of kali, build script is in the vagrantfile in the [kali-pentest-lab](kali-pentest-lab) folder.

And my vagrant boxes are [here](https://app.vagrantup.com/deargle).

# Todos

* add the nested-virtualization license to the build step
* set up virt-manager with my security class VMs (see [https://daveeargle.com/security-assignments/](https://daveeargle.com/security-assignments/))
