Title: Bootstrapping OpenWRT sysupgrade for snapshot releases
Category: openwrt
Tags: openwrt, scripting, wifi
Slug: bootstrapping-openwrt-sysupgrade-snapshots
Date: Thu Mar 24 00:58:27 EDT 2016

After [figuring out that the new Archer C7 comes with a different flash chip](https://www.reddit.com/r/openwrt/comments/4aukq9/help_archer_c7_v2_not_reachable_on_19216811_after/) that is not yet supported by an official release, I soon realized that it (the snapshot) does not come with all the bells and whistles that a normal release does; namely LuCI and ath10k firmware.

As a result, and after getting a grip on how this software works, I wanted to make a small `rc.local` script to automate the process of going from sysupgrade -> fully working exactly the way it was. (Since a sysupgrade currently removes all `opkg` packages and resets service states when you reinstall the packages) To implement this script, if you have luci, go to http://<your_openwrt_ip>/cgi-bin/luci/admin/system/startup (or navigate to System -> Startup) and look for the "Local Startup" input box. Copy and paste the script there, and make any modifications necessary. 

The result (for me) is that I can throw a sysupgrade image at LuCI, flash that image, and two reboots later I'm back exactly the way I was. **Please understand that this is customized specifically to my needs and you'll need to change things around for yourself**, specifically I am using the Archer as an 802.11ac AP and I don't need typical router functionality, so I'm disabling services like `odhcpd` and `dnsmasq` on boot. 

In the spirit of sharing, here it is: 

<script src="https://gist.github.com/xenithorb/720c85fe1afafb135419.js"></script>

Originally posted to /r/OpenWRT: <https://www.reddit.com/r/openwrt/comments/4bq9en/little_bootstrap_rclocal_script_for_snapshot/> (I am the original author)
