# arch-dotfiles

Arch Linux + Hyprland configuration for a VAIO Pro PG (VJPG11C11N).

- Hyprland + hyprbars
- Waybar (Catppuccin-derived green palette)
- kitty, wofi, mako
- awww wallpaper daemon
- cava visualiser in the bar
- btrfs + snapper, zram + hibernation

## Restoring onto a fresh install

```
git clone git@github.com:USERNAME/arch-dotfiles.git
cd arch-dotfiles
./install.sh
```

`install.sh` handles packages, dotfiles, and services. Anything it would
overwrite is copied to `~/.config-backup-TIMESTAMP/` first.

## Keeping the repo current

```
./sync.sh
git add -A
git commit -m "update configs"
git push
```

`sync.sh` copies the live configs back into the repo and regenerates the
package lists. It also refuses to finish if it spots something that looks
like an API key or private key.

---

## What is NOT in this repo

These are machine-specific or secret, and have to be redone by hand.

### Disk layout

Partitions:

| Partition | Size | Type | Mount |
|---|---|---|---|
| `nvme0n1p1` | 1 GiB | FAT32 | `/boot` |
| `nvme0n1p2` | rest | btrfs | `/` |

btrfs subvolumes:

| Subvolume | Mount |
|---|---|
| `@` | `/` |
| `@home` | `/home` |
| `@log` | `/var/log` |
| `@pkg` | `/var/cache/pacman/pkg` |
| `@snapshots` | `/.snapshots` |
| `@swap` | `/swap` |

Mount options for all btrfs subvolumes except `@swap`:

```
noatime,compress=zstd:1,ssd,discard=async
```

`@swap` uses `noatime` only — no compression on swap.

### Bootloader

systemd-boot, ESP at `/boot`. Two entries, `arch.conf` and `arch-lts.conf`.

Kernel options:

```
root=UUID=<root-uuid> rootflags=subvol=@ rw resume=UUID=<root-uuid> resume_offset=<offset>
```

**`resume_offset` is specific to the swapfile on this disk.** If the swapfile
is ever recreated, get the new value with:

```
sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
```

and update both loader entries.

### Swap and hibernation

zram via `zram-generator` (config is in this repo), plus a 10 GiB swapfile:

```
sudo btrfs subvolume create /swap        # on the top-level volume
sudo btrfs filesystem mkswapfile --size 10g --uuid clear /swap/swapfile
sudo swapon /swap/swapfile
```

`mkinitcpio.conf` needs `resume` in HOOKS, after `filesystems`:

```
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems resume fsck)
```

Then `sudo mkinitcpio -P`.

### Snapper

```
sudo umount /.snapshots && sudo rm -r /.snapshots
sudo snapper -c root create-config /
sudo btrfs subvolume delete /.snapshots
sudo mkdir /.snapshots && sudo mount -a
sudo systemctl enable --now snapper-cleanup.timer
```

`snap-pac` then snapshots automatically around every pacman transaction.

### Secrets

Not in this repo, by design:

- SSH keys (`~/.ssh/`)
- Discord bot `config.yaml` (API keys)
- Wi-Fi credentials (NetworkManager, `/etc/NetworkManager/system-connections/`)

### Hardware notes

- JIS keyboard: `KEYMAP=jp106` in `/etc/vconsole.conf`, `kb_layout = jp` in Hyprland
- Real S3 suspend, not modern standby — hibernation works properly
- Fingerprint reader is unsupported on Linux
- BIOS/firmware updates are Windows-only via VAIO's updater
