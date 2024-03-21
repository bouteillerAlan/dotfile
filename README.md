Personal dotfile w/ a custom init script.

- install zsh
- make it default `chsh -s $(which zsh)` then reboot
- launch the script
- do a `PackerSync` in neovim

If (for some raison) a command fail, do not re-run the script just re-run the command.

In most of the case docker is setup but the `docker run hello-world` fail because a reboot is expected.
