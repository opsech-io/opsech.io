Title: NFSv4-Only on CentOS 7.2
Category: linux
Tags: nfs, centos, systemd
Date: Tue Jan 26 15:52:10 EST 2016
Status: Published

The road to a NFSv4 only server is not very clearly documented on the internet
regarding Fedora/CentOS 7 - as the move to systemd has changed some operations of
how `nfs.service` pulls in configuration variables from `/etc/sysconfig/nfs`.

Why should you consider doing this? If like me you run modern distributions as your
primary OS that fully support NFSv4.1,2 out of the box. Why run all of the unnecessary
services if, by default, the client maximizes the capable version, anyway?

One interesting aspect is that since this a kernel-space daemon, some commands, like
`ss -ntupl | grep 2049` will ***not*** show the daemon's name as `knfsd`, but rather be blank.

<br />

1. Open up `/etc/sysconfig/nfs` in your favorite editor and change the following:

		:::bash
		RPCNFSDARGS=""
		...
		RPCMOUNTDOPTS=""

	to

		:::bash
		RPCNFSDARGS="-N2 -N3 -V4"
		...
		# -u is optional, disables UDP
		RPCMOUNTDOPTS="-N2 -N3 -V4 -u"

+ I'm not exactly sure why, but it would appear that there are compat issues with
using `/etc/sysconfig/nfs` as the `EnvironmentFile=` directly for `nfs-server.service` (also aliased as `nfs.service`). As a result, now there is an ancillary service `nfs-config.service` which **must** be restarted in the event of changing `/etc/sysconfig/nfs`.

		:::bash
		systemctl restart nfs-config

		# The following should show you the values that
		# we entered above
		cat /run/sysconfig/nfs

+ For good measure stop all the services that might be running (`nfs-server.service` will start these by dependency, but not stop them. While we're at it, let's stop and disable `rpcbind.service`, too:

		:::bash
		systemctl stop {rpcbind,rpc-statd,nfs-mountd,nfs-server}.service
		systemctl disable rpcbind.service

		# NFSv2,3 can not start without rpcbind, if the service
		# starts, it probably worked
		systemctl mask rpcbind.service

+ Now start `nfs-server.service`:

		:::bash
		systemctl start nfs-server.service
	Hopefully your service started. If you have the following error:
	`rpc.nfsd: unable to set any sockets for nfsd`
	Then your nfsd is still looking for `rpcbind` - try making sure you have the
	right vars in `/run/sysconfig/nfs` again.

+ Last but not least, add some firewall rules. NFSv4 operates on port 2049. I'm still using iptables instead of firewalld, so:

		:::bash
		# Put this somewhere below your RELATED, ESTABLISHED line
		# For me, inserting at rulenum #15 was reasonable.
		# check with `iptables -nL --line-numbers`
		for i in udp tcp; do
			-I INPUT 15 -s 192.168.1.0/24 -p ${i} -m ${i} --dport 2049 -m conntrack \
			--ctstate NEW -m comment --comment "NFSv4 ${i^^}" -j ACCEPT
		done
		cp /etc/sysconfig/iptables{,-$(date +'%F-%H.old')}
		iptables-save > /etc/sysconfig/iptables

