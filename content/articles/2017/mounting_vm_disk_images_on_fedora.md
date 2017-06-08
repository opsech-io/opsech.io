Title: How to mount VM disk images on Fedora
Category: linux
Tags: linux, fedora, qemu, virt
Date: Wed Jun 7 19:18:00 EDT 2017
Status: published

There are two ways to currently mount disk images on Linux. Both of them involve using QEMU in different aspects. Both of them support the image formats that are supported by QEMU itself. I won't enumerate that list, but for practical sake, it's whatever images you're used to working with when using hypervisors like VirtualBox, Hyper-V, KVM, et al.

### Why?

Perhaps you're in a situation where you need to mount an image to extract something from it, but you can't or don't want to mess around with network shares like NFS or Samba, and you need a way to transfer data to and from the virtual machine.

Perhaps you have a failing hard drive that is dubious at best with transferring large amounts of data at once. You could attempt to use `rsync -P` and chip away at transferring the image, in hopes that it runs and has your data intact on the destination, or you could mount it as described below and target the important data immediately.

### Notes

If `libguestfs-tools` are available on your operating system, I would suggest going with this method as it was specifically intended to be used for the aforementioned task. The latter method is more of a hack taking advantage of the NBD protocol.

Both methods involve what amounts to starting an on-the-fly virtual machine (via qemu) to read the image and export the data. Verify with `ps aux | grep qemu` in the midst of one of the following methods if you're curious.

The following method (#1) also has the ability to attach to a live system. This could be useful if you just want to transfer something simple that you _know will not intersect with anything on the running system_. This implies a strict warning. I mean it, the [man page](https://linux.die.net/man/3/guestfs) (ctrl+f "ATTACH") literally says:

>Note (1): This is highly experimental and has a tendency to eat babies. Use with caution.

See: `--live` at the [guestmount man page](https://linux.die.net/man/1/guestmount) for more information.

### Easiest method using libguestfs-tools

1.  Install `libguestfs-tools`:

        ::text
        $ sudo dnf install libguestfs-tools

+   Being that we now have `libguestfs-tools`, we have the `virt-*` suite at our disposal. Let's take a look at what partitions are available to mount on a test `qcow2` image.

        ::text
        $ sudo -i
        # cd /var/lib/libvirt/images
        # virt-filesystems -a fedora25.qcow2
        /dev/sda1
        btrfsvol:/dev/sda3/root
        btrfsvol:/dev/sda3/home
        /dev/sda3

+   We can see here that our mountable options are `sda1` and `sda3` - and we're probably after `sda3` since that contains our important data. Let's mount it with `guestmount`:

        ::text
        # guestmount -r -a fedora25.qcow2 -m /dev/sda3 /mnt/point
        # ls -l /mnt/point
        total 0
        drwxr-xr-x. 1 root root  12 Jun  3 18:12 home
        dr-xr-xr-x. 1 root root 132 Jun  3 19:38 root

    Where `-r` is to mount the image read-only, `-m` is the internal partition you want to mount, and `/mnt/point` is a directory on the host filesystem that you want to mount the internal partition to.

    Here we see `home` and `root` directories that contain the `btrfs` home and root subvolumes. That's because we mounted `/dev/sda3` directly and the default subvolume to mount on a `btrfs` filesystem is `subvol=/` aka `subvolid=5`. If that's not relevant or doesn't make sense to you, just note that this would ordinarily be the root of the filesystem (i.e. `/` where `home`, `var`, `usr`, `etc`, etc live) were it not `btrfs`.

+   That's it! Now, when you're done, simply use `guestunmount` to un-mount the device much in the same way you would use `umount`:

        ::text
        # exit
        $ cd # in case we're in /mnt/point
        $ sudo guestunmount /mnt/point

### Harder method using `qemu-nbd`

1.  Start off by installing `qemu-img` and `nbd` packages:

        ::text
        $ sudo dnf install qemu-img nbd

+   Load the `nbd` kernel module with option `max_part=8`. This option is basically a required option unless your images are flat and have no internal partitions because we need that in order for it to create `nbdNpY` devices once `nbdN` is linked to an image:

        $ sudo modprobe nbd max_part=8

+   Now let's attach the virtual image to one of the nbd devices:

        ::text
        $ sudo qemu-nbd -c /dev/nbd0 /var/lib/libvirt/images/fedora25.qcow2
        $ # check dmesg for partitions indicating it was loaded properly
        $ dmesg | grep nbd0
        [348950.439938]  nbd0: p1 p2 p3

    Note: Optionally use `-r` to export the image read-only. Or you can also use `mount -o ro` in one of the following steps. It's probably best to be read-only at the lowest level, however.

    Here we can see `p1` through `p3` are active, let's explore that further next

+   Optional: check partitions with `fdisk` or `parted`:

        ::text
        $ sudo fdisk -l /dev/nbd0
        Disk /dev/nbd0: 20 GiB, 21474836480 bytes, 41943040 sectors
        Units: sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        Disklabel type: dos
        Disk identifier: 0xf4520513

        Device      Boot   Start      End  Sectors Size Id Type
        /dev/nbd0p1 *       2048  2099199  2097152   1G 83 Linux
        /dev/nbd0p2      2099200  6293503  4194304   2G 82 Linux swap / Solaris
        /dev/nbd0p3      6293504 41943039 35649536  17G 83 Linux

        $  sudo parted /dev/nbd0 print
        Model: Unknown (unknown)
        Disk /dev/nbd0: 21.5GB
        Sector size (logical/physical): 512B/512B
        Partition Table: msdos
        Disk Flags:

        Number  Start   End     Size    Type     File system     Flags
         1      1049kB  1075MB  1074MB  primary  ext4            boot
         2      1075MB  3222MB  2147MB  primary  linux-swap(v1)
         3      3222MB  21.5GB  18.3GB  primary  btrfs

+   We will select `/dev/nbd0p3` as our mount target, this corresponds to `/dev/sda3` from inside the virtual machine, and is the `btrfs` filesystem we're interested in:

        ::text
        $ sudo mount /dev/nbd0p3 /mnt/point
        $ ls -l /mnt/point
        total 0
        drwxr-xr-x. 1 root root  12 Jun  3 18:12 home
        dr-xr-xr-x. 1 root root 132 Jun  3 19:38 root

    Where `/mnt/point` is any directory on the filesystem you would like to mount on.

+   Success! Now when you're done clean up with:

        ::text
        $ cd # in case we're under /mnt/point
        $ sudo umount /mnt/point
        $ sudo qemu-nbd -d /dev/nbd0
        $ sudo modprobe -r nbd

### Caveats

1.  **libguestfs: error: invalid value for backingformat parameter 'vdi':** Edit: Actually, this is [a bug that I apparently found and reported on IRC that was fixed here](https://www.redhat.com/archives/libguestfs/2017-June/msg00043.html), thanks to Richard Jones for fixing it! The gist is that it was caused by a stringent whitelist that didn't account for all image types.

    <s>For reasons unknown to me</s> `libguestfs`'s tools sometimes work fine with images other than `qcow2` and `raw`, and sometimes not. For example, `virt-rescue` and `guestmount` seem to work with most image formats, but `virt-filesystems` seems to support only the abovementioned two. In case you run up agasint this when intending to use `libguestfs-tools`, use `virt-rescue` instead and utilize the rescue shell to enumerate partitions as described during 1. on the next caveat.

+   **Read only file system:** You may get to the point after you mount the filesystem, especially with ones like `ntfs`, where the dirty bit has been set by an unclean shutdown and the surrogate ad-hoc virtual machine that is created by `guestmount` mounts it read-only under the hood forcefully. This is very hard to notice unless you add `-v | --verbose` to `guestmount`, and then you can clearly see what is going on (by contrast with method 2, when you go to manually mount it will be quite evident). Amidst all the other output, you should find toward the end:

        ::text
        commandrvf: mount -o  /dev/sda2 /sysroot/
        [    0.982901] fuse init (API version 7.26)
        The disk contains an unclean file system (0, 0).
        Metadata kept in Windows cache, refused to mount.
        Falling back to read-only mount because the NTFS partition is in an
        unsafe state. Please resume and shutdown Windows fully (no hibernation
        or fast restarting.)
        guestfsd: main_loop: proc 74 (mount_options) took 0.13 seconds

    In this case, use the `ntfsfix` command in order to make the filesystem properly mount. Be aware that this can be potentially dangerous, and the instructions to use windows for this should be heeded. That being said, I haven't really had any issues with it myself:

    #### Using `ntfsfix` with option 1:

    1.  Manually start the rescue shell:

            virt-rescue -a Windows.vdi
            ...
            ...
            ><rescue> lsblk
            NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
            sdb      8:16   0    4G  0 disk /
            sda      8:0    0   50G  0 disk
            |-sda2   8:2    0 49.5G  0 part
            `-sda1   8:1    0  500M  0 part

    +   Use `ntfsfix` to reset the filesystem:

            ><rescue> ntfsfix /dev/sda2
            Mounting volume... The disk contains an unclean file system (0, 0).
            Metadata kept in Windows cache, refused to mount.
            FAILED
            Attempting to correct errors...
            Processing $MFT and $MFTMirr...
            Reading $MFT... OK
            Reading $MFTMirr... OK
            Comparing $MFTMirr to $MFT... OK
            Processing of $MFT and $MFTMirr completed successfully.
            Setting required flags on partition... OK
            Going to empty the journal ($LogFile)... OK
            Checking the alternate boot sector... OK
            NTFS volume version is 3.1.
            NTFS partition /dev/sda2 was processed successfully.

    #### Using `ntfsfix` with option 2:

    1.  After `qemu-nbd -c /dev/nbd0 <image_file>` do the following:

            $ ntfsfix /dev/nbd0p2
            Mounting volume... The disk contains an unclean file system (0, 0).
            Metadata kept in Windows cache, refused to mount.
            FAILED
            Attempting to correct errors...
            Processing $MFT and $MFTMirr...
            Reading $MFT... OK
            Reading $MFTMirr... OK
            Comparing $MFTMirr to $MFT... OK
            Processing of $MFT and $MFTMirr completed successfully.
            Setting required flags on partition... OK
            Going to empty the journal ($LogFile)... OK
            Checking the alternate boot sector... OK
            NTFS volume version is 3.1.
            NTFS partition /dev/nbd0p2 was processed successfully.

    You should then be able to (with both methods) mount the `ntfs` filesystem read-write and continue on.
