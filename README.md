# 📬 isync

[isync](https://isync.sourceforge.io/), the project behind the `mbsync` command, in a small rootless image: two-way synchronization between two IMAP servers, or an IMAP server and a local Maildir. It keeps state between runs, so moves, flags and deletions on either side reach the other.

<!-- sf:project:start -->
<!-- sf:project:end -->
<!-- sf:badges:start -->
<!-- sf:badges:end -->

### Usage

The image runs `mbsync` (Alpine, isync 1.5.1) as UID 65532 and accepts any UID in group 0, with a read-only root filesystem. Mount a config and a writable state directory, and let the platform schedule it (a Kubernetes CronJob or a systemd timer); nothing in the image runs on a timer. Arguments starting with `-` go to `mbsync`; any other command (`sh`, a script) runs as given.

```sh
docker run --rm --read-only \
  -v ./mbsyncrc:/etc/mbsyncrc:ro \
  -v ./secrets:/run/secrets:ro \
  -v mbsync-state:/var/lib/mbsync \
  hlhd/isync -c /etc/mbsyncrc -a
```

- `/var/lib/mbsync`: sync state. Keep it between runs; without it the next run cannot tell a deletion from a new message.
- Passwords come from files at run time, never from the config: `PassCmd "cat /run/secrets/<name>"`.
- TLS 1.2 and 1.3 only, certificates verified.

Two-way sync between two IMAP servers, here a Gmail account and a self-hosted mailbox:

```
IMAPAccount gmail
Host imap.gmail.com
User someone@gmail.com
PassCmd "cat /run/secrets/gmail"
TLSType IMAPS
TLSVersions +1.2 +1.3

IMAPAccount home
Host imap.example.com
User someone@example.com
PassCmd "cat /run/secrets/home"
TLSType IMAPS
TLSVersions +1.2 +1.3

IMAPStore gmail
Account gmail

IMAPStore home
Account home

Channel mail
Far :gmail:
Near :home:
# Gmail shows every message under "All Mail" and again under each label;
# syncing it would duplicate everything.
Patterns * !"[Gmail]/All Mail" !"[Gmail]/Important" !"[Gmail]/Starred"
Create Both
Remove Both
Expunge Both
Sync All
CopyArrivalDate yes
SyncState /var/lib/mbsync/
```

### License

isync is GPL-2.0-or-later; this packaging follows it.
