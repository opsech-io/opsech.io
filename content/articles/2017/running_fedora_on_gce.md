Title: Running Fedora 25 on Google Compute Engine
Category: cloud
Tags: gce, google cloud, fedora
Slug: running-fedora-on-gce
Summary: How to convert, upload and create a Fedora 25 image on Google Compute Engine
Date: Mon Jun 12 23:43:26 EDT 2017
Status: published

Recently I had an opportunity to mess around with Google Compute Engine and noticed a distinct lack of presence of my beloved Fedora OS. A quick searching turned up [this how-to](http://rancher.com/running-fedora-21-on-google-compute-engine/), that while OK, was slightly outdated (insofar as the options didn't work exactly as is). So, I've decided to record the exact steps I took to get a fully-functioning Fedora 25 image on [GCE](Google Compute Engine).

#### Prerequisites

1.  A Google Account
+   A Google Cloud Platform Project-ID
+   A Linux machine (preferably local Fedora 25) to install `google-cloud-sdk`
+   Expected programs: `sfdisk`, `wget`, `xz`, `python`, `ssh`, `dnf`

#### Instructions

1.  Image prep:

    First we need to get the Fedora Cloud RAW image and convert it to be compatible with GCE. Make note of `IMAGE_NAME` and `BUCKET_NAME`, you may need to change those and we will be using those going forward (If you set it once and use the same shell for everything you're fine):

        ::bash
        IMAGE_NAME=Fedora-Cloud-Base-25-1.3.x86_64
        BUCKET_NAME=my-unique-bucket-name

        wget -O - "https://download.fedoraproject.org/pub/fedora/linux/releases/25/CloudImages/x86_64/images/${IMAGE_NAME}.raw.xz" \
            | xz -cd - > disk.raw


    Now that we have a `disk.raw` (the file name **GCE expects** inside the `.tar.gz`) we also need to temporarily mount it, upgrade `cloud-init`, and enable the `GCE` cloud-init datasource. `Fedora-Cloud-Base-25` comes with cloud-init pre-installed, but no datasources are enabled by default. This is simply the best way I could find to configure that before uploading the image:

        ::bash
        # Get /dev/sda1 parition offset:
        OFFSET=$( sfdisk -J disk.raw | python -c 'import sys, json; a=json.load(sys.stdin); print(a["partitiontable"]["partitions"][0]["start"]*512)' | tee /dev/tty )

        # Either become root and paste these line-by-line or the whole block at once
        sudo OFFSET="$OFFSET" sh -c '\
        # Make mounting directory
        mkdir -p /mnt/disk
        # Mount the image and prepare the chroot
        mount -o offset=$OFFSET disk.raw /mnt/disk
        mount -t proc /proc /mnt/disk/proc
        mount --rbind /sys /mnt/disk/sys
        mount --make-rslave /mnt/disk/sys
        mount --rbind /dev /mnt/disk/dev
        mount --make-rslave /mnt/disk/dev'

    **Alternatively**: Consider using my [steps here]({filename}/articles/2017/mounting_vm_disk_images_on_fedora.md) on mounting virtual machine disk images. Though it will certainly work, this was not needed here because we're dealing with a RAW image instead of VDI, VMDK, or QCOW2. (i.e. just use `guestmount` for just mounting, and `virt-rescue` for a minimal virtual host. They are both from `libguestfs-tools`)

    Now that the image is mounted, we need to add to the clout-init `cloud.cfg.d` in order to enable the `GCE` datasource:

        ::text
        sudo tee /mnt/disk/etc/cloud/cloud.cfg.d/GCE.cfg <<EOF
        datasource_list: [ 'GCE' ]
        datasource: { GCE: {} }
        EOF

    This enables the `GCE` datasource for cloud-init. Without this, the imagine will hang during boot and fail on loading the metadata information, and then when SSH finally does come up you won't be able to login because no SSH keys will have been inserted.

    There is [a bug](https://github.com/cloud-init/cloud-init/commit/328fe5ab399b1f5b48d1985f41fc2ef66e368922#diff-6a1bacc7c738db3b0d2cc0dc15960d70) presently in Fedora 25 stable's version of `cloud-init`, which is at `0.7.8` - this version based on my findings was completely incompatible with modern `GCE` and I couldn't get it to work. Thus, we must upgrade `cloud-init`'s package as well (Upgrade everything else later as to not bloat the image). The current version in Fedora 25 as of this writing is `0.7.9` which is just recent enough to include the fix:

        ::bash
        sudo chroot /mnt/disk dnf -yq --enablerepo=updates-testing upgrade cloud-init

    **Optional**: Now to install the `google-compute-engine` and associated packages. This is **not mandatory**, but the Google Cloud Platform console won't be able to SSH in and other functionality will be missing. Copy paste the following and hit enter:

        ::text
        sudo tee /mnt/disk/etc/yum.repos.d/google-cloud.repo << EOF
        [google-cloud-compute]
        name=Google Cloud Compute
        baseurl=https://packages.cloud.google.com/yum/repos/google-cloud-compute-el7-x86_64
        enabled=1
        gpgcheck=1
        repo_gpgcheck=1
        gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
               https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
        EOF

        chroot /mnt/disk dnf install -yq google-compute-engine google-compute-engine-init google-config
        chroot /mnt/disk dnf clean all

    ***WARNING***: Try to do as little as possible in the chroot because it will balloon the image size. Don't do a full `dnf upgrade` yet.

    *Pro tip*: Try `virt-sparsify disk.raw disk.raw.sparse && mv disk.raw.sparse disk.raw` to save a little extra space.

    Finally, unmount and package up the `disk.raw` image into a compatible `.tar.gz` file:

        ::bash
        sudo umount -AR /mnt/disk
        tar caf "${IMAGE_NAME}.tar.gz" disk.raw

+   Now that the image prep is done, we need to install the `google-cloud-sdk` from Google's official repositories on our workstation:

        ::text
        sudo tee /etc/yum.repos.d/google-cloud-sdk.repo << EOF
        [google-cloud-sdk]
        name=Google Cloud SDK
        baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
        enabled=1
        gpgcheck=1
        repo_gpgcheck=1
        gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
               https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
        EOF

        sudo dnf install -y google-cloud-sdk

+   Now that the SDK is installed `gcloud` and `gsutil` commands are present. Next, we will authenticate with the Google Cloud Platform, then set the active project:

        ::bash
        gcloud auth login
        gcloud config set project my-project-id


+   Then transfer and create the bucket and image:

        ::bash
        gsutil mb "gs://${BUCKET_NAME}" # OPTIONAL, could exist already
        gsutil cp "${IMAGE_NAME}.tar.gz" "gs://${BUCKET_NAME}/"

    Should output the following:

        ::text
        | [1 files][170.6 MiB/170.6 MiB]    2.5 MiB/s
        Operation completed over 1 objects/170.6 MiB.

+   Finally, register the image:

        ::bash
        # Sanitize the name of the image for GCE
        CLOUD_IMAGE="$(sed 's|[\._]|-|g;s|.*|\L&|' <<< "${IMAGE_NAME}")"
        echo -e "Cloud image name: $CLOUD_IMAGE\n"
        gcloud compute images create --source-uri "gs://${BUCKET_NAME}/${IMAGE_NAME}.tar.gz" "${CLOUD_IMAGE}"

    Should output something like:

        ::text
        Cloud image name: fedora-cloud-base-25-1-3-x86-64

        Created [https://www.googleapis.com/compute/v1/projects/my-project-id/global/images/fedora-cloud-base-25-1-3-x86-64].
        NAME                             PROJECT         FAMILY  DEPRECATED  STATUS
        fedora-cloud-base-25-1-3-x86-64  my-project-id                        READY

+   Configure your GCE SSH keys, either go [here (console, use for **ssh-agent users**)](https://console.cloud.google.com/compute/metadata/sshKeys?project=kuber-course), or use key files setup by:

        ::bash
        gcloud compute config-ssh

    Which will make a new key, save it to `~/.ssh/google_compute_engine*` and upload it for you. NOTE: If you want to use `ssh-agent`, then you must configure it through the web console manually. Hint: Get your public keys via `ssh-add -L`

+   Now you're ready to start creating new instances either via the commandline or the [GUI console](https://console.cloud.google.com/compute/instances)

        ::bash
        gcloud compute instances create fedora-25-test \
            --machine-type g1-small \
            --boot-disk-size 20GB \
            --image "${CLOUD_IMAGE}" \
            --zone us-east1-b

    Should output something like:

        ::text
        Created [https://www.googleapis.com/compute/v1/projects/kuber-course/zones/us-east1-b/instances/fedora-25-test1].
        NAME             ZONE        MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
        fedora-25-test1  us-east1-b  g1-small                   10.142.0.2   104.196.42.60  RUNNING

+   SSH-Agent users:

        ::bash
        ssh fedora@104.196.42.60

    `gcloud compute config-ssh` users:

        ::bash
        gcloud compute ssh fedora-25-test

    **Note:** If you installed the `google-compute-engine` packages, additional users will be created for each SSH key in your Google Cloud Platform Metadata.

    **Hint**: If this doesn't work or you otherwise run into trouble, you can output the serial console log in the following manner:

        ::bash
        gcloud beta compute instances get-serial-port-output fedora-25-test
