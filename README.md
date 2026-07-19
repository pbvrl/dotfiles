# File structure

- `flake.nix`: Entrypoint for the config. Each `outputs.nixosConfiguration.*` defines a configuration for a different machine / virtual machine.
- `hosts/config.nix`: Main config file. Specifies installed programs, `.nix` config files, environment variables, and not much more.
- `hosts/basic_config.nix`: Things I don't put in `hosts/config.nix` because they rarely change, like battery or audio settings.
- `dotfiles/*/**`:  Regular config files for each program, that I symlink using `GNU stow`.
- `dotfiles/*.nix`:  Nix config for some programs.
- `scripts_as_dotfiles/`: Scripts that programs rely on, or that I effectively use as configuration.
- `hosts/`: Configuration specific the different machines / virtual machines; referenced from `flake.nix`.
- `secrets/`:  Encrypted secrets and related config.

# Setup (non-Apple laptop + usb)

1. Flash the [nixos minimal iso](https://nixos.org/download/) to an usb.
   Can use balenaEtcher, dd... With dd on Linux:

```bash
lsblk -pd  # Find the usb. Must be the whole disk e.g. /dev/sdb and not /dev/sdb1
sudo umount /dev/sdb*
sudo dd bs=4M conv=fsync oflag=direct status=progress if=/home/nixos/Downloads/nixos-minimal-26.05.4808.569d57850992-x86_64-linux.iso of=/dev/sdb
```

2. Enter the laptop boot menu, disable secure boot, and delete the secure boot keys

3. Boot from the usb

4. Clone this repo:

```bash
nmcli device wifi list
sudo nmcli device wifi connect "SSID_NAME" password "WIFI_PASSWORD"
git clone "https://github.com/pbvrl/dotfiles" "$HOME/.config/nixos"
```

or restore from local storage...

```bash
nmcli device wifi list
sudo nmcli device wifi connect "SSID_NAME" password "WIFI_PASSWORD"
nix run nixpkgs#bashmount --extra-experimental-features "nix-command flakes" # Xm; e.g. 3m; mount to /home/nixos/mnt/usb
REPO=/home/nixos/mnt/usb/restic-repo 
RESTORE_PATH="$HOME/restic-restored/"
sudo nix run nixpkgs#restic --extra-experimental-features "nix-command flakes" -- restore latest -r "$REPO" --target "$RESTORE_PATH" --include "/home/nixos/.config/nixos" --include "/home/nixos/.config/secretkey"
sudo chown -R nixos:users $RESTORE_PATH
mkdir -p /home/nixos/.config
cp $RESTORE_PATH/home/nixos/.config/nixos /home/nixos/.config/nixos -r

mkdir -p /home/nixos/.config/secretkey
cp $RESTORE_PATH/home/nixos/.config/secretkey/sops_private_key.txt /home/nixos/.config/secretkey/sops_private_key.txt
```

5. Point the partitioning config to the laptop/pc's disk:

```bash
lsblk -pd # Find the main internal disk e.g. /dev/nvme0n1
vim /home/nixos/.config/nixos/hosts/base/disko.nix
```

```nix
      disk1 = {
        type = "disk";
        device = "/dev/nvme0n1"; # <-
```

6. Partition the drive encrypting the main parition:

> WARNING: This wipes the disk.

```bash
echo -n "yourEncryptionPassword" > /tmp/luks-password.txt
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount /home/nixos/.config/nixos/hosts/base/disko.nix
lsblk -pf # Verify the 'vfat' and 'crypto_LUKS' partitions were created
```

7. Generate the hardware config (`--no-filesystems` because disko handles that):

```bash
sudo nixos-generate-config --no-filesystems --show-hardware-config > /home/nixos/.config/nixos/hosts/base/hardware-configuration.nix
```

8. Install nixos on the main partition. Prompts for the root password at the end:

> WARNING: `nixos-install` requires at least 4GB of ram, otherwise there are other alternatives


> Ignore the "Cannot read ssh key" warnings, they resolve on first boot. Ignore "Activation script snippet 'setupSecrets' failed"


```bash
sudo nixos-install --root /mnt --impure --flake /home/nixos/.config/nixos#base
```

9. Symlink dotfiles before rebooting, so rebooting lands in a ready system:

> Ignore the "Cannot read ssh key" and the "su: Authentication service cannot retrieve authentication info" warnings, they resolve on first boot. Ignore "Activation script snippet 'setupSecrets' failed"


```bash
sudo mkdir -p /mnt/home/nixos/.config
sudo cp /home/nixos/.config/nixos /mnt/home/nixos/.config/nixos -r
sudo nixos-enter --root /mnt -c "chown -R nixos:users /home/nixos"
sudo nixos-enter --root /mnt -c "su - nixos -c /home/nixos/.config/nixos/scripts/stow.sh"
```

10. Reboot

> This logs off the temporary environment running from the usb and boots inside the main drive where the flake was installed

> Lanzaboote will automatically reboot a second time from the login screen, and enroll the secureboot keys

```bash
reboot
sudo bootctl status # Secure Boot: disabled
sudo sbctl verify # only the kernel .efi file is not signed
```

11. Reboot a third time, enter the bios console, and reenable SecureBoot. Then check it is enabled.

```bash
reboot
sudo bootctl status # Secure Boot: enabled
```

12. Install browser extensions: Vimium, etc.


# Once done

`Super+h` shows the keybind helper.

For rebuiding, use `--impure` to pick up the private git submodule:

```bash
sudo nixos-rebuild switch --impure --flake "/home/nixos/.config/nixos#$hostname"
```

# Encrypting secrets (api keys, ...)

1. Generate a .sops.yaml file, a public key and a private key:

<table>
<tr>
<td width="50%">

**fish**

```fish
set PUBLIC_KEY (age-keygen -o ~/.config/secretkey/sops_private_key.txt 2>&1 | sed 's/Public key: //')
echo "keys:
  - &personal $PUBLIC_KEY
creation_rules:
  - path_regex: secrets.yaml\$
    key_groups:
      - age:
        - *personal" > ~/.config/nixos/secrets/.sops.yaml
cd ~/.config/nixos/secrets
rm secrets.yaml
```

</td>
<td width="50%">

**bash**

```bash
export PUBLIC_KEY=$(age-keygen -o ~/.config/secretkey/sops_private_key.txt 2>&1 | sed 's/Public key: //')
cat > ~/.config/nixos/secrets/.sops.yaml << EOF
keys:
  - &personal $PUBLIC_KEY
creation_rules:
  - path_regex: secrets.yaml\$
    key_groups:
      - age:
        - *personal
EOF
cd ~/.config/nixos/secrets
rm secrets.yaml
```
</td>
</tr>
</table>

2. Place your secrets in the `secrets.yaml` file:
```bash
~/.config/nixos/scripts/sops.sh
```

For example:

```yaml
OPENROUTER_API_KEY: sk-or-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
USUAL_USBS_SERIALS: |
    xxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxx
git:
    USER_EMAIL: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    USER_NAME: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Make sure your .nix files using `config.sops.secrets`, including `~/.config/nixos/secrets/sopsnix.nix`, only reference secrets you have set in `secrets.yaml`

When you exit the editor the file becomes encrypted.

3. Rebuild:
```bash
sudo nixos-rebuild switch --impure --flake "/home/nixos/.config/nixos#$hostname"
```

# Live iso

Follow the above setup, then:

```bash
nix build "/home/nixos/.config/nixos#nixosConfigurations.iso.config.system.build.isoImage" -o "/home/nixos/.config/nixos/live_iso"
lsblk -pd  # Find the usb. Must be the whole disk e.g. /dev/sdb and not /dev/sdb1
sudo umount /dev/sdb*
sudo dd bs=4M conv=fsync oflag=direct status=progress if=/home/nixos/.config/nixos/live_iso/iso/*.iso of=/dev/sdb
rm "/home/nixos/.config/nixos/live_iso"
```

# Python development

Python dependencies can be troublesome with NixOs's non-FHS filesystem. I either:

- Use [distrobox](https://distrobox.it/) and run an Ubuntu shell
- Use [fix-python](https://github.com/GuillaumeDesforges/fix-python) for something quick from my old laptop

# Paths

- `~/.config/nixos/`: Where this repo lives locally. It didn't necessarily have to be here but I chose this location.
- `~/.config/secretkey/sops_private_key.txt` : Decrypts sops secrets.
- `~/projects/`
- `~/notes/`
- `~/restic-repo/`: Where I backup the above paths to.

# Configuring programs (Stow)

Set up a new dotfile:
1. Add the dotfile in `~/.config/nixos/dotfiles/*/*`
2. Reference it in `~/.config/nixos/scripts/stow.sh`, and run the script, to symlink it where the program expects it.

# Reloading program configs

| Program | Reload options (not necessarily all) |
|:---|:---|
| River | Log out (Super+Shift+E) and back in.  |
|       | `riverctl COMMAND` (avoids logging out) |
| Kanata | `sudo nixos-rebuild switch --impure --flake "/home/nixos/.config/nixos#$hostname"` |
|        | `systemctl stop kanata-default; kanata -c ~/.config/nixos/dotfiles/kanata/kanata.kbd` |
| Helix | `:config-reload` |
| Ghostty | Press `ctrl`+`shift`+`,` (default for `reload_config`) |
| Mako | `makoctl reload` |
| Tmux | `tmux source ~/.tmux.conf` |
| Fish | `source ~/.config/fish/config.fish` |
| Lazygit | Open a new instance |
| Yazi | Open a new instance |
| Claude-code | Open a new instance |
| sigoden/aichat | Open a new instance |

# Installing programs

1. Specify the package in `config.environment.systemPackages`; See `configuration.nix`.
2. Rebuild `sudo nixos-rebuild switch --impure --flake "/home/nixos/.config/nixos#$hostname"`

# Updating programs broadly

1. (Optional) Change `inputs.nixpkgs.url` in `flake.nix`
2. Run `nix flake update` or `nix flake update nixkpgs`
3. Rebuild `sudo nixos-rebuild switch --impure --flake "/home/nixos/.config/nixos#$hostname"`

# Pinning a program to a specific version

I avoid doing that, as a software consumer.
If a program doesn't work on my nixpkgs version, I pass on it until it does.

[How to do it anyways](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/downgrade-or-upgrade-packages)

# Doing backups

I made scripts for my usual backup sceneraios. They are just thin wrappers around the `restic` CLI:

- `~/.config/nixos/scripts/restic_backup.sh`: Do a backup.
- `~/.config/nixos/scripts/restic_copy.sh`: Copy the backup to drives.
- `~/.config/nixos/scripts/restic__backup_and_copy.sh`: Call the above two sequentially.

# Restoring backups
    
<table>
<tr>
<td width="50%">

**fish**

```fish
set REPO /run/media/nixos/USB1/restic-repo 
set RESTORE_PATH "$HOME/restic-restored/"
restic restore latest -r "$REPO" --target "$RESTORE_PATH"
mkdir /home/nixos/.config/secretkey
sudo cp $RESTORE_PATH/home/nixos/.config/secretkey/sops_private_key.txt /home/nixos/.config/secretkey/sops_private_key.txt
sudo cp $RESTORE_PATH/home/nixos/.config/nixos/private /home/nixos/.config/nixos/private -r
sudo cp $RESTORE_PATH/home/nixos/projects /home/nixos/projects -r
sudo cp $RESTORE_PATH/home/nixos/notes /home/nixos/notes -r
sudo cp $REPO /home/nixos/restic-repo -r
sudo chown -R nixos:users /home/nixos
sudo rm $RESTORE_PATH -r
sudo nixos-rebuild switch --impure --flake "/home/nixos/.config/nixos#$hostname"
```

</td>
<td width="50%">

**bash**

```bash
REPO=/run/media/nixos/USB1/restic-repo 
RESTORE_PATH="$HOME/restic-restored/"
restic restore latest -r "$REPO" --target "$RESTORE_PATH"
mkdir /home/nixos/.config/secretkey
sudo cp $RESTORE_PATH/home/nixos/.config/secretkey/sops_private_key.txt /home/nixos/.config/secretkey/sops_private_key.txt
sudo cp $RESTORE_PATH/home/nixos/.config/nixos/private /home/nixos/.config/nixos/private -r
sudo cp $RESTORE_PATH/home/nixos/projects /home/nixos/projects -r
sudo cp $RESTORE_PATH/home/nixos/notes /home/nixos/notes -r
sudo cp $REPO /home/nixos/restic-repo -r
sudo rm $RESTORE_PATH -r
sudo nixos-rebuild switch --impure --flake "/home/nixos/.config/nixos#$hostname"
```
</td>
</tr>
</table>

# Updating secrets (WIP)

`sops-nix` enables referencing the secrets from the nixos config.

1. Run sops `~/.config/nixos/scripts/sops.sh`. This unencrypts the file and opens it in $EDITOR, where you add/edit secrets.
2. Save and exit; The file becomes encrypted again.

- To access a secret from the nixos config (and also expose it at `/run/secrets/$SECRET`, depending on who you set as the owner):

1. Reference it in `~/.config/nixos/secrets/sopsnix.nix`
2. Reference it wherever you want to use it in the config with `config.sops.secrets.SECRET.path`
3. Rebuild `sudo nixos-rebuild switch --impure --flake "/home/nixos/.config/nixos#$hostname"`

- To access a secret from the shell prompt, or a script: 
```bash
cat /run/secrets/$SECRET
```

> WARNING:
- It might be better to have the secrets referenced in `sopsnix.nix` be owned by systemd services and not the user.
- Access through /run/secrets/$SECRET might be problematic if a program keeps a history of the outputs of shell commands.
- I might remove the access through /run/secrets/$SECRET.

# Things I've tried before:
<details>
<summary><strong>Click</strong></summary>

- For automating program installation:
  1. No automation, download from a website on `Windows` or use `wget`.
  2. `Ansible` scripts (too unreliable, always had to tweak something) on `PopOs (Ubuntu)`
  3. `NixOs` (now)

- For managing dotfiles:
  1. Save them 1 by 1 to an usb/cloud and copy them over to a new machine.
  2. `Chezmoi` (too bothersome for a one machine setup)
  3. `NixOs home-manager` (same as chezmoi, and also I felt like it does too many things under the `home-manager` umbrella)
  4. `Gnu Stow` (now)

</details>

