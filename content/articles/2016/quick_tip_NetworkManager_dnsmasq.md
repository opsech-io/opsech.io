Title: Quick Tip: Enable easy NetworkManager local DNS caching
Category: quick-tips
Tags: fedora, dns, linux, quick-tips
Date: Sun Feb 14 06:50:15 EST 2016
Status: published


To enable NetworkManager's feature to start `dnsmasq` and enable dns caching:

1. Add the following `dns=` line to `/etc/NetworkManager/NetworkManager.conf`:

		:::ini
		[main]
		plugins=ifcfg-rh,ibft
		dns=dnsmasq
		
+ Install `dnmasq`:

		:::bash
		sudo dnf install dnsmasq 

+ Add some extra space to the default cache:

		:::bash
		sudo sh -c 'echo "cache-size=1000" >> /etc/NetworkManager/dnsmasq.d/cache.conf'

+ Restart NetworkManager:

		:::bash
		sudo systemctl restart NetworkManager

+ Observe the difference:

		:::bash
		for i in 1 2 ; do \time -f "Attempt $i: %E" nslookup <unvisited_domain> >/dev/null;  done

	Note: if you already have a caching resolver on your network, the impact will probably 
	be minimal.
