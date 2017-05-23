Title: Docker DNS with FirewallD on Fedora
Category: docker
Tags: linux, fedora, docker, dns, NetworkManager, firewalld
Slug: docker-dns-with-firewalld-on-fedora
Summary: How to allow docker to use the local system DNS cache (dnsmasq) because otherwise docker defaults to using Google DNS
Date: Tue May 23 14:17:17 EDT 2017
Status: published


By default docker reads in the host's `/etc/resolv.conf` file and if it only contains `nameserver 127.0.0.1`, it is hard-coded to use Google DNS. This is especially pertinent if you're using local DNSMasq for caching [like I instructed in a previous post][1]. For those of us who have DNS properly configured within our own networks, this is undesirable for obvious reasons and what follows is how to fix that.


1.  First, the docker daemon needs to be instructed to only use a certain set of DNS servers. This can be done with the `daemon.json` configuration file, usually located in `/etc/docker/daemon.json` - please create this if it does not exist:

        :::json
        {
            "dns": [
                "172.17.0.1"
            ]
        }

    By default the docker daemon creates an interface `docker0` with a default address of `172.17.0.1/16`. With the above config, this instructs docker to rewrite the `resolv.conf` file ***inside the containers*** as follows:

        :::txt
        nameserver 172.17.0.1

+   Restart the docker engine with `sudo systemctl restart docker.service`.

+   The next step is to lead off of the instructions [here][1] and configure the dnsmasq process that NetworkManager runs to listen to the local docker subnet. The following needs to be placed in `/etc/NetworkManager/dnsmasq.d/docker-bridge.conf`

        :::txt
        listen-address=172.17.0.1

    This is telling `dnsmasq` - specifically the one started from NetworkManager - to listen on the subnet `docker0` is attached to. Please adjust accordingly if you're not using dnsmasq in conjunction with NetworkManager (It is not configured this way by default, see [here][1])

+   Restart NetworkManager with `sudo systemctl restart NetworkManager.service`.

+   The final step is only necessary if you're using FirewallD (or translate yourself for iptables). What we want to do is add a zone for docker, then assign the `docker0` interface to that zone, then finally add a valid source to that zone (**because firewalld will not activate a zone without a valid source or interface it recognizes**. In this case `docker0` is managed by NetworkManager, so firewalld ignores it when activating zones):

        :::bash
        sudo firewall-cmd --permanent --new-zone=docker
        sudo firewall-cmd --permanent --zone=docker --add-interface=docker0
        sudo firewall-cmd --permanent --zone=docker --add-source=172.17.0.1/16
        sudo firewall-cmd --permanent --zone=docker --add-service=dns
        sudo firewall-cmd --reload

    Please check with `sudo firewall-cmd --zone=docker --list-all`, it should look like this:

        :::txt
        docker (active)
          target: default
          icmp-block-inversion: no
          interfaces: docker0
          sources: 172.17.0.1/16
          services: dns
          ports:
          protocols:
          masquerade: no
          forward-ports:
          source-ports:
          icmp-blocks:
          rich rules:

+   You should now be able to run any docker container and it should be able to use your local dns, confirm with:

        :::bash
        docker run -it --rm busybox sh -c 'cat /etc/resolv.conf && echo && nslookup opsech.io'

    It should output something like this:

        :::txt
        nameserver 172.17.0.1

        Server:    172.17.0.1
        Address 1: 172.17.0.1

        Name:      opsech.io
        Address 1: 54.230.163.168 server-54-230-163-168.jax1.r.cloudfront.net
        Address 2: 54.230.163.222 server-54-230-163-222.jax1.r.cloudfront.net
        Address 3: 54.230.163.131 server-54-230-163-131.jax1.r.cloudfront.net
        Address 4: 54.230.163.234 server-54-230-163-234.jax1.r.cloudfront.net
        Address 5: 54.230.163.67 server-54-230-163-67.jax1.r.cloudfront.net
        Address 6: 54.230.163.193 server-54-230-163-193.jax1.r.cloudfront.net
        Address 7: 54.230.163.15 server-54-230-163-15.jax1.r.cloudfront.net
        Address 8: 54.230.163.138 server-54-230-163-138.jax1.r.cloudfront.net

##### Additional Info: <https://github.com/moby/moby/issues/23910>

[1]: {filename}/articles/2016/quick_tip_NetworkManager_dnsmasq.md
