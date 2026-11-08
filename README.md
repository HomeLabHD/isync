# 📬 isync

[isync](https://isync.sourceforge.io/), the project behind the `mbsync` command, in a small rootless image: two-way synchronization between two IMAP servers, or an IMAP server and a local Maildir. It keeps state between runs, so moves, flags and deletions on either side reach the other.

<!-- sf:project:start -->
[![GitHub](https://img.shields.io/badge/GitHub-mirror-181717?logo=github)](https://github.com/HomeLabHD/isync) [![GitLab](https://img.shields.io/badge/GitLab-source-FC6D26?logo=gitlab)](https://git.optcp.com/HomeLabHD/isync) [![license](https://raw.githubusercontent.com/HomeLabHD/isync/main/.stagefreight/scribe/license.svg)](https://github.com/HomeLabHD/isync/blob/main/LICENSE) [![Open Issues](https://img.shields.io/github/issues/HomeLabHD/isync)](https://github.com/HomeLabHD/isync/issues) [![Open PRs](https://img.shields.io/github/issues-pr/HomeLabHD/isync)](https://github.com/HomeLabHD/isync/pulls) [![Contributors](https://img.shields.io/github/contributors/HomeLabHD/isync)](https://github.com/HomeLabHD/isync/graphs/contributors) [![donate](https://img.shields.io/badge/donate-FF5E5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/T6T41IT163) [![sponsor](https://img.shields.io/badge/sponsor-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/HomeLabHD)
<!-- sf:project:end -->
<!-- sf:badges:start -->
[![release](https://raw.githubusercontent.com/HomeLabHD/isync/main/.stagefreight/scribe/release.svg)](https://github.com/HomeLabHD/isync/releases) [![build](https://raw.githubusercontent.com/HomeLabHD/isync/main/.stagefreight/scribe/build.svg)](https://git.optcp.com/HomeLabHD/isync/-/pipelines) [![Last Commit](https://img.shields.io/github/last-commit/HomeLabHD/isync)](https://github.com/HomeLabHD/isync/commits) [![StageFreight](https://img.shields.io/badge/StageFreight-0.16.0--dev.89+382f3f0-310937?logo=readthedocs&logoColor=white)](https://stagefreight.prplanit.com)
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
