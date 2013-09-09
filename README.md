# gfk

Securely share files between computers with a USB drive.

## Motivation

Private keys (SSH and GPG) are difficult to manage securely.  This script and
method gives you a way to securely store them on a USB drive in such a way that
losing the USB drive does not compromise or lose your keys.  Really this can be
used for any number of files, but the idea is to secure private keys.

This security is achieved using Daniel Silverstone's incredible [libgfshare][]
and [secretfs][].  You can read the details of those projects there.  All this
script does it make it easier to deal with them.

## Setup

Firstly, you will need a thumb drive to work with.  I recommend using only a
small partition for this as your private keys probably aren't that big and then
you can put whatever you want on the rest of the drive.  Namely, I recommend
putting a FAT partition for the majority of the drive and your partition for
this after that using whatever filesystem you like.  This will prevent Windows
from helpfully offering to erase all your files should you plug it in to a
Windows machine.  This is what my drive looks like:

       Device Boot      Start         End      Blocks   Id  System
    /dev/sdc1              58    14845447     7422695    c  W95 FAT32 (LBA)
    /dev/sdc2        14845448    15240575      197564   83  Linux

You will also need to install the aforementioned software packages.  I have
included them in this repository to make your life easier.

Once you get that all set, I strongly suggest you find a way to automatically
and consistently mount the partition to a known spot.  I gave the partition a
label and [udevil][] liked that just fine.  If you want to do it manually
that's fine too but you will want to mount it to the same path always.

After you have all that working, just run a `make install` (probably as root)
and the script will be installed.  You will probably want to edit the
configuration file located at `/etc/gfk.conf`.  After you set everything, run
`gfk setup` to mount secretfs.  I recommend you put this in your `.bash_profile`
to run automatically at login.

## Configuration

The configuration file is sourced from the script so the syntax is the same as
setting bash variables.  The following variables are defined:

### TEMP

Temporary location when generating shares.  This should be a ram disk for best
security.

### USB

Directory for file shares stored on the USB key.  This should usually be on a
removable media such as a USB drive.

### LOCAL

Directory for file shares stored locally and symlinks to files stored on the USB
key.  This should not be readable by other users as it will contain sufficient
data to reconstruct your files when the USB symlinks are active.

### MOUNT

Directory for mounting secretfs.  This is where your reconstructed files will
appear when they USB symlinks are active.  As such, it should not be readable by
other users although the default for secretfs is to give the files 0400
permissions.

### STORE

Directory for storing unused shares.  This is the weakest point of the system as
it can potentially store enough data to reconstruct the files without any other
point of access.  As such, it is recommended to use something secure to store
these and that the shares are distributed quickly to your other computers.

## Usage

Running `gfk` without arguments will give you a basic usage menu.  The following
commands exist.

### add <file>

Add the file to the USB drive.  This will split the file with `gfsplit` and move
two of the shares to the USB drive.  It will move one share to your local
computer and the rest to the configured storage area.  It will then verify that
the file was correctly split and replace the file with a symlink to the copy of
the file in secretfs.  If the USB drive files are inaccessible, the secretfs
copy will disappear, rendering the file useless.

### grab <file>

Grabs a share from the storage area and copies it to your local filesystem.
This is how you add a file to a second client after using `add` on the first.

### rm <file>

Removes a file from the USB drive and places it in your local filesystem.  This
is the inverse of `add`.  If you do this, the file will stay broken on any other
system where it was being used.

### ls

Lists all the files available on the USB drive.  Note that secretfs doesn't
support directories so this is just a flat list.  You will have to remember
yourself where to put them on your client machines.

### eject

Tries to unmount the USB drive.  It will use `udevil`, `sudo`, and plain old
`umount` in that order.  I strongly encourage you to do this before you pull the
drive out.

### setup

Mounts the secretfs system.  You must do this before the files will start
appearing magically.  I recommend adding this to your `.bash_profile` or
whatever equivalent thing you have if you don't use bash.

## Demonstration

I know that was a lot to read so here's a "TL;DR" version:

    [22:25:20 alan@gandalf ~] $ ssh-keygen -t dsa
    Generating public/private dsa key pair.
    Enter file in which to save the key (/home/alan/.ssh/id_dsa):
    Enter passphrase (empty for no passphrase):
    Enter same passphrase again:
    Your identification has been saved in /home/alan/.ssh/id_dsa.
    Your public key has been saved in /home/alan/.ssh/id_dsa.pub.
    The key fingerprint is:
    36:e9:0b:e8:62:bd:3d:cf:e1:0d:a9:8f:2e:a1:2c:ef alan@gandalf.eab.local
    The key's randomart image is:
    +--[ DSA 1024]----+
    |                 |
    |                 |
    |                 |
    |         .       |
    |        S        |
    |    .. o o       |
    | . o... =        |
    |. =.o..* =       |
    | =E.o+=+* .      |
    +-----------------+
    [22:25:41 alan@gandalf ~] $ gfk add .ssh/id_dsa
    .ssh/id_dsa is now stored on the USB key
    Remaining shares are found in /home/alan/Dropbox/gfshare
    [22:26:33 alan@gandalf ~] $ gfk eject
    USB key unmounted

Later…

    [22:37:15 alan@radagast ~] $ gfk grab .ssh/id_dsa
    id_dsa shared from USB key to .ssh/id_dsa
    [22:39:17 alan@radagast ~] $ ssh-keygen -yf .ssh/id_dsa > .ssh/id_dsa.pub
    [22:39:28 alan@radagast ~] $ ssh-keygen -lf .ssh/id_dsa
    1024 36:e9:0b:e8:62:bd:3d:cf:e1:0d:a9:8f:2e:a1:2c:ef .ssh/id_dsa.pub (DSA)

## Other Thoughts

For good measure, I keep a copy of this repository on the partition with the keys
so that I can get things setup even if I don't have the internet although I'm
not sure what good my private keys are without the internet.

I also put a fun image on the FAT partition in case someone finds the drive:

![lost](https://raw.github.com/bentglasstube/gfk/master/lost.png)

## Future

In the future I want to devise a better storage system, perhaps encrypting the
unused shares on the USB drive.

[libgfshare]: http://www.digital-scurf.org/software/libgfshare
[secretfs]: http://www.digital-scurf.org/software/secretfs
[udevil]: http://ignorantguru.github.io/udevil/
[sshfs]: https://wiki.archlinux.org/index.php/Sshfs
