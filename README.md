# grscheller/bash-dotfiles

Repository to maintain and install all my Bash configuration files.
I use Bash as my backup shell for Linux and the MSYS2 environment on
Windows 11. This is my actual working setup, take what may be useful
to you, or use as a starting point for your own version.

## Installation scripts

A POSIX shell script, [bashInstall](bin/bashInstall), installs the
"dotfiles" from the cloned repo into my Linux or MSYS2 $HOME directory.
Once your Bash environment has been bootstrapped, this script can be
launched from anywhere with the `bI` bash alias and honors the
[XDG directory specification](https://specifications.freedesktop.org/basedir/latest/).

- bashInstall has shebang `#!/bin/dash`
  - on PopOS `/usr/bin/sh -> dash`
  - on MSYS2 I install dash with `pacman -S dash`
  - will work just fine if shebang is changed to `#!/bin/sh`
- does more than just install, see `fishInstall --help` 

### Note

MSYS2 integration is still a work in progress.

# Public Domain Declaration

To the extent possible under law,
[Geoffrey R. Scheller](https://github.com/grscheller)
has waived all copyright and related or neighboring rights
to [grscheller/dotfiles](https://github.com/grscheller/dotfiles).
This work is published from the United States of America.

See [LICENSE](LICENSE) for details.
