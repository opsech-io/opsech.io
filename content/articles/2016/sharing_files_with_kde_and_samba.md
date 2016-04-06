Title: Enable usershares and kdenetwork-filesharing in Fedora 23
Category: linux
Tags: linux, samba, filesharing, kde
Slug: sharing-files-with-kde-and-samba
Summary: How to share files with samba usershares and KDE Dolphin file manager (KF5/Plasma 5)
Date: Wed Apr  6 00:42:41 EDT 2016
Status: Published

First a little prologue: I first found a need for this because of virt-manager/libvirt's lacking support for a file-sharing mechanism. According to the Archlinux wiki, [there's even a default way for qemu to set this up for you][1], but it's not available to configure by default with libvirt or virt-manager for that matter.

[1]:https://wiki.archlinux.org/index.php/QEMU#QEMU.27s_built-in_SMB_server

The other piece of the puzzle is that I am using user-mode networking, which means that by default, the hypervisor can not network contact guest operating systems, but the guest operating system can network contact the hypervisor.

The last option left was to setup a samba server on my workstation, so I decided to revisit how this was done as a "user" and I was more than a little disappointed by how
difficult it was to actually get it going:

1. First let's install the necessary items:

		:::bash
		# samba is usually already installed as a dependency
		# of the "Printing Support" or "System Tools" groups
		sudo dnf install kdenetwork samba

+ We need to enable a SELinux boolean:

		:::bash
		sudo setsebool -P samba_enable_home_dirs 1

+ Add the following to `/etc/samba/smb.conf` underneath the `[global]` heading (I put mine right above the workgroup =  definition):

		:::bash
		usershare allow guests = true
        usershare max shares =  5
        usershare owner only = true
        usershare path = /var/lib/samba/shares

+ That last path that we defined above for `usershare path =` above, `/var/lib/samba/shares` needs to be created. It is not optional, and the user that you intend to be able to use this with MUST be able to write inside the directory. (whether by group permissions or user permissions). Here is my personal take on that (the path is also subjective too):

		:::bash
		sudo mkdir -p /var/lib/samba/shares
		sudo groupadd shares
		sudo gpasswd -a $USER shares
		sudo chown root.shares /var/lib/samba/shares
		sudo chmod 1770 /var/lib/samba/shares

+ Restart samba:

		:::bash
		systemctl restart smb nmb

+ Log out of plasma and log back in

When you return you should be able to start `dolphin` and then you should also be able to right-click a folder and go to the share tab to set various share settings. Once you click ok, it should execute behind the scenes `net usershare add` you can check if it's working by running `net usershare list` - other errors can be sorted out by tailing ~/.xsession-errors: `tail -f ~/.xsession-errors`, then do the sharing action in dolphin again and see what it says.

Note: A significant portion of these instructions come from `man smb.conf` and then searching for `usershares` - they give you a little hint how to get this going.
