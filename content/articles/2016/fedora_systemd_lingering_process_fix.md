Title: Fedora 23 systemd lingering processes after logout fix
Category: quick-tips
Tags: fedora, linux, quick-tips, systemd
Slug: fedora-systemd-lingering-process-fix
Summary: Small tip to help after logging out of your Xsession to make sure lingering processes are killed
Date: Fri Jan 15 12:31:21 EST 2016
Status: published

Annoyed by lingering processes after you logout of a Plasma or GNOME session?

Me too.

To fix:

```bash
sed -i 's/^#\(KillUserProcesses=\)no$/\11/' /etc/systemd/logind.conf
```

Specifically, edit `/etc/systemd/logind.conf` and then change `#KillUserProcesses=no`
to `KillUserProcesses=1`. This is particularly useful on Fedora due to the amount
of updates, and especially if you do lots of test updates. I find myself logging-off
frequently due to the amount of updates, since I want to make sure what's in memory
is fresh code.

**WARNING**: On server oriented systems, anything you might leave behind a `screen`
or `tmux` type lingering session, this *will* cause that to be terminated upon
logging out of something like an SSH session.