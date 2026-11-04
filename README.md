# 📬 isync

[isync](https://isync.sourceforge.io/), the project behind the `mbsync` command, in a small rootless image: two-way synchronization between two IMAP servers, or an IMAP server and a local Maildir. It keeps state between runs, so moves, flags and deletions on either side reach the other.

<!-- sf:project:start -->
[![GitHub](https://img.shields.io/badge/GitHub-mirror-181717?logo=github)](https://github.com/HomeLabHD/isync) [![GitLab](https://img.shields.io/badge/GitLab-source-FC6D26?logo=gitlab)](https://git.optcp.com/HomeLabHD/isync) [![license](https://raw.githubusercontent.com/HomeLabHD/isync/main/.stagefreight/scribe/license.svg)](https://github.com/HomeLabHD/isync/blob/main/LICENSE) [![Open Issues](https://img.shields.io/github/issues/HomeLabHD/isync)](https://github.com/HomeLabHD/isync/issues) [![Open PRs](https://img.shields.io/github/issues-pr/HomeLabHD/isync)](https://github.com/HomeLabHD/isync/pulls) [![Contributors](https://img.shields.io/github/contributors/HomeLabHD/isync)](https://github.com/HomeLabHD/isync/graphs/contributors) [![donate](https://img.shields.io/badge/donate-FF5E5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/T6T41IT163) [![sponsor](https://img.shields.io/badge/sponsor-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/HomeLabHD)
<!-- sf:project:end -->
<!-- sf:badges:start -->
[![release](https://raw.githubusercontent.com/HomeLabHD/isync/main/.stagefreight/scribe/release.svg)](https://github.com/HomeLabHD/isync/releases) [![build](https://raw.githubusercontent.com/HomeLabHD/isync/main/.stagefreight/scribe/build.svg)](https://git.optcp.com/HomeLabHD/isync/-/pipelines) [![Last Commit](https://img.shields.io/github/last-commit/HomeLabHD/isync)](https://github.com/HomeLabHD/isync/commits) [![StageFreight](https://img.shields.io/badge/StageFreight-0.14.0--dev+03e43e86-310937?logo=readthedocs&logoColor=white)](https://stagefreight.prplanit.com)
<!-- sf:badges:end -->
<!-- sf:image:start -->
[![GHCR](https://img.shields.io/badge/GHCR-homelabhd%2Fisync-181717?logo=github&logoColor=white)](https://github.com/HomeLabHD/isync/pkgs/container/isync) [![Docker](https://img.shields.io/badge/Docker-hlhd%2Fisync-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/hlhd/isync) [![pulls](https://img.shields.io/docker/pulls/hlhd/isync?color=1d63ed&logo=docker&logoColor=white)](https://hub.docker.com/r/hlhd/isync) [![Harbor](https://img.shields.io/badge/Harbor-hlhd%2Fisync-60b932)](https://cr.optcp.com/harbor/projects)

[![latest](https://raw.githubusercontent.com/HomeLabHD/isync/main/.stagefreight/scribe/release-latest.svg)](https://github.com/HomeLabHD/isync/pkgs/container/isync) ![updated](https://raw.githubusercontent.com/HomeLabHD/isync/main/.stagefreight/scribe/release-updated.svg) [![size](https://raw.githubusercontent.com/HomeLabHD/isync/main/.stagefreight/scribe/release-size.svg)](https://github.com/HomeLabHD/isync/pkgs/container/isync) [![latest-dev](https://raw.githubusercontent.com/HomeLabHD/isync/main/.stagefreight/scribe/dev-latest.svg)](https://github.com/HomeLabHD/isync/pkgs/container/isync) ![updated](https://raw.githubusercontent.com/HomeLabHD/isync/main/.stagefreight/scribe/dev-updated.svg) [![size](https://raw.githubusercontent.com/HomeLabHD/isync/main/.stagefreight/scribe/dev-size.svg)](https://github.com/HomeLabHD/isync/pkgs/container/isync)
<!-- sf:image:end -->

---

### Features:

| | |
| --- | --- |
| **Two-way sync** | New mail, moves, flags and deletions on either side reach the other |
| **Kept state** | Sync state lives in `/var/lib/mbsync` between runs, so a deletion is never mistaken for new mail |
| **Rootless** | Runs as UID 65532, or any UID in group 0, on a read-only root filesystem |
| **No secrets in config** | Passwords are read from mounted files at run time with `PassCmd` |
| **TLS** | TLS 1.2 and 1.3 only, certificates verified |
| **Tini init** | Signal handling and zombie reaping via tini |

## Usage

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

## Image Contents

<!-- sf:contents-base:start -->
[![alpine 3.22.7](https://img.shields.io/badge/alpine-3.22.7-0078D4?style=flat)](https://hub.docker.com/_/alpine)
<!-- sf:contents-base:end -->

<!-- sf:contents-apk:start -->
[![ca-certificates](https://img.shields.io/badge/ca--certificates-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=ca-certificates) [![isync 1.5.1](https://img.shields.io/badge/isync-1.5.1-0078D4?style=flat)](https://pkgs.alpinelinux.org/packages?name=isync) [![tini](https://img.shields.io/badge/tini-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=tini)
<!-- sf:contents-apk:end -->

---

## Contributing

- Fork the repository
- Submit Pull Requests / Merge Requests
- [File issues](../../issues/new) with the image tag, run command and the mbsync output

## Credits

* [isync](https://isync.sourceforge.io/) by Oswald Buddenhagen and its contributors: the `mbsync` tool this image runs — [source](https://sourceforge.net/projects/isync/) · [GPL-2.0-or-later](LICENSE)

## License

isync is distributed under the [GPL-2.0-or-later](LICENSE) license; this packaging follows it.
