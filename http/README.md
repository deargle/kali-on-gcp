The preseeds in this directory differ based on what extra packages they install.
Specifically, the `tasksel tasksel/first` key.

Differing from the Kali preseed, all of these configs specify to  _not_ do full package upgrades:

    d-i pkgsel/upgrade select none

Structure taken from https://github.com/elreydetoda/packer-kali_linux/
