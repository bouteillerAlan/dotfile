Personal dotfile w/ a custom init script.

- install zsh
- make it default `chsh -s $(which zsh)` then reboot
- launch the script
- do a `PackerSync` in neovim

If (for some raison) a command fail, do not re-run the script just re-run the command.

In most of the case docker is setup but the `docker run hello-world` fail because a reboot is expected.

Local conf belong in `/etc/fonts`, `51-local.conf` preset need to be enable ([check here](https://wiki.archlinux.org/title/Font_configuration#Presets), [and here](https://wiki.archlinux.org/title/Font_configuration#Fontconfig_configuration))
