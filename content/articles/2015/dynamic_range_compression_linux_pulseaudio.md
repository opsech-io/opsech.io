Title: Adding DRC to pulseaudio on Fedora 23
Category: linux
Tags: pulseaudio, fedora, linux
Slug: dynamic-range-compression-linux-pulseaudio
Summary: Showcasing an easy way to enable DRC-like LADSPA-plugin functionality
Date: Fri Nov  6 14:21:06 EST 2015
Modified: Sun Jan 17 18:49:51 EST 2016
Status: Published

One of the few things greatly missed from my time using Windows as a media PC was
its easy ability to enable DRC. This is a post-processing effect that basically
compresses the audio stream so that extreme louds and extreme softs have a shorter
range, and thus are easier to percieve by the human ear. (think back to being easily
able to hear a door or footsteps in a video, but not the actor speak, or music thats
arbitrarily loud between tracks.)
*[DRC]: Dynamic Range Compression

```bash
#!/bin/bash
set -e

sudo dnf install ladspa-swh-plugins

# Making an assumption here about the first listed sink being the right one
FIRST_SINK=$(pacmd list-sinks | grep name: | awk -F'[<>]' 'NR==1 {print $2}')

# WARNING: this will remove your current default.pa if you configured one
# One should not exist by default
cat <<-EOF > ~/.config/pulse/default.pa
	$(cat /etc/pulse/default.pa)

	## FOR DYNAMIC RANGE COMPRESSION - Replace ${FIRST_SINK} if this doesn't work
	load-module module-ladspa-sink sink_name=ladspa_normalized master=${FIRST_SINK} plugin=fast_lookahead_limiter_1913 label=fastLookaheadLimiter control=10,0,0.8
	load-module module-ladspa-sink sink_name=ladspa_dyson master=ladspa_normalized plugin=dyson_compress_1403 label=dysonCompress control=0,1,0.5,0.99
EOF

pulseaudio -k
```

You should now use `pavucontrol` (the KDE phonon config kind of wonks out when you restart pulseaudio) to check to see if the proper sinks are active.

Again, with KDE, you'll need to **log out**, then when you log back in, go to *System Settings -> Multimedia -> Audio and Video* and configure the order for the sinks to actually be used. It is the first sink in the chain that should be preferred, so "prefer" "LADSPA Plugin Dyson compressor on LADSPA Plugin Fast Lookahead limiter on <your_master_audio_device>" to the top, where <your_master_audio_device> is actually the one that should be your primary output device. **If this device is incorrect:** Then, `${FIRST_SINK}` in the script above is incorrect. Copy this order to the other device lists if you wish. (In KDE there are different device orders for music, video, notifications, etc)

Remember that the way this works is the audio passes to the first sync **ladspa_dyson**, then to the next sink, **ladspa_normalized**, then to the actual audio device. The first sink compresses the dynamic range of the audio, the second sink normalizes it. The second sink isn't mandatory.
