Title: Adding DRC to pulseaudio on Fedora 23
Category: linux
Tags: pulseaudio, fedora, linux
Slug: dynamic-range-compression-linux-pulseaudio
Summary: Showcasing an easy way to enable DRC-like LADSPA-plugin functionality
Date: Fri Nov  6 14:21:06 EST 2015

One of the few things greatly missed from my time using Windows as a media PC was
its easy ability to enable DRC. This is a post-processing effect that basically
compresses the audio stream so that extreme louds and extreme softs have a shorter
range, and thus are easier to percieve by the human ear. (think back to being easily
able to hear a door or footsteps in a video, but not the actor speak, or music thats
arbitrarily loud between tracks.)
*[DRC]: Dynamic Range Compression

```bash
#!/bin/bash
sudo dnf install ladspa-swh-plugins &&

# WARNING: this will remove your current default.pa if you configured one
# One should not exist by default

cat <<-EOF > ~/.config/pulse/default.pa
	$(cat /etc/pulse/default.pa)

	## FOR DYNAMIC RANGE COMPRESSION
	load-module module-ladspa-sink sink_name=ladspa_dyson plugin=dyson_compress_1403 label=dysonCompress control=0,1,0.5,0.99
	load-module module-ladspa-sink sink_name=ladspa_normalized master=ladspa_dyson plugin=fast_lookahead_limiter_1913 label=fastLookaheadLimiter control=10,0,0.8"
EOF

pulseaudio -k
```

You should now use `pavucontrol` (the KDE phonon config kind of wonks out when you restart pulseaudio) to check to see if the proper sinks are active.

Again, with KDE, you'll need to **log out**, then when you log back in, go to *System Settings -> Multimedia -> Audio and Video* and configure the order for the sinks to actually be used. It is the first sink in the chain that should be preferred, so "prefer" "LADSPA Plugin Fast Lookahead limiter" to the top. Copy this order to the other device lists if you wish.

Remember that the way this works is the audio passes to the first sync **ladspa_normalized**, then to the next sink, **ladspa_dyson**, then to the actual audio device. The first sink normalizes the audio so no clipping takes place, the second sink compresses the dynamic range of the audio. The first sink isn't mandatory. Think of these extra sinks as filters, as that's basically what they are.