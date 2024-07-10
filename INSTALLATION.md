# Outline of installation process using existing config 
(from memory so hopefully I didn't forget anything)
NOTE: this assumes your system is an nvidia gpu and an intel cpu! 
## Install
### On another machine 
I first downloaded the Graphical ISO image (GNOME) from [here](https://nixos.org/download/#nixos-iso). Then followed instructions [here](https://nixos.org/manual/nixos/stable/#sec-booting-from-usb). 

With a USB stick plugged in, I first ran `lsblk`, which on my system gave: 
```
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda           8:0    1  28.7G  0 disk 
├─sda1        8:1    1   966M  0 part 
└─sda2        8:2    1     3M  0 part 
nvme1n1     259:0    0 953.9G  0 disk 
├─nvme1n1p1 259:1    0   240M  0 part 
├─nvme1n1p2 259:2    0   128M  0 part 
├─nvme1n1p3 259:3    0 929.5G  0 part 
├─nvme1n1p4 259:4    0   990M  0 part 
├─nvme1n1p5 259:5    0  21.5G  0 part 
└─nvme1n1p6 259:6    0   1.5G  0 part 
nvme0n1     259:7    0 931.5G  0 disk 
├─nvme0n1p1 259:8    0  1000M  0 part /efi
├─nvme0n1p2 259:9    0 896.4G  0 part /
└─nvme0n1p3 259:10   0  34.1G  0 part [SWAP]
```
where we see that `sda` is the USB drive here. 
We need to ensure the drive is unmounted, so we can run: `sudo umount /dev/sda` (where replace `sda` with whatever its name is). 
We then run: 
```bash
sudo dd if=<path-to-image> of=/dev/sdX bs=4M conv=fsync
```
### On the device to install on
I then booted from this usb drive into the installer. 
Needed to connect to wifi using settings
Through the graphical installer, I mostly followed the instructions and picked reasonable options. Some stand outs: 
- I chose "no desktop" environment (I plan to install hyprland)
- I allowed unfree software (NVIDIA!!)
- chose to "erase disk" when partitioning
	- also chose to have a swap with hibernate 
- also picked to "encrypt disk"

## Configuration 
We need to do some basic configuration before we can fully proceed. This involves editing the configuration file.

We can use `sudoedit` for editing the configuration file (`/etc/nixos/configuration.nix`) (i.e. `sudoedit /etc/nixos/configuration.nix`) 
I added the following lines to the configuration file: 
```nix
# Enable CUPS to print documents
services.printing.enable = true; 

# Enable sound with pipewire 
sound.enable = true; 
hardware.pulseaudio.enable = false; 
security.rtkit.enable = true; 
services.pipewire = {
  enable = true; 
  alsa.enable = true; 
  alsa.support32Bit = true; 
  pulse.enable = true;
};
```
I also edited the environment packages to add `vim` and `git` (at least initially): 
```nix
environment.systemPackages = with pkgs; [
  vim
  git
]
```
You could use any text editor other than `vim`, like `nano` would work or `helix` or `nvim`.

In order to rebuild nixos, you need internet, which you can connect to by running `nmtui` and then connecting to a wifi network through the UI. This is pretty self-explanatory.

I can then run the following: 
```bash
sudo nixos-rebuild switch
```
to apply changes.

We also want to move to the unstable branch of nixos (scary I know, but this is still far less unstable than arch's main branch):
```bash
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos 
sudo nixos-rebuild switch --upgrade-all
```

## Switching to actual configuration 
Now we can switch to the pre-made configuration we actually want to use. To do so, go to your home directory (`cd ~`) and run: 
```sh
git clone https://github.com/TheSharkhead2/.dotfiles.git
```
Make sure that this is cloned to the path `~/.dotfiles`. From now on, I will assume this is your path. 

We can enter the directory (`cd .dotfiles`). There are a few things we need to change, for starters, we want to use the `hardware-configuration.nix` that was generated when we first installed nix, not the one that is currently included in the configuration we just downloaded. So, we can run `cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix`. 
Additionally, if you picked encryption, if you look at your original generated `configuration.nix` (`vim /etc/nixos/configuration.nix`), you may see lines that look like: 
```nix
  boot.initrd.luks.devices."luks-c63f4f2f-e6cc-4cbf-80d2-b734d6e08c7b".device = "/dev/disk/by-uuid/c63f4f2f-e6cc-4cbf-80d2-b734d6e08c7b";
```
Copy all of these lines into your `~/.dotfiles/hardware-configruation.nix` file. You can put them anywhere within the "body" of the script: 
```nix
{ config, lib, pkgs, modulesPath, ... }: 

{
  # ...
  # this is the body
  # ... 
}
```
Note that you will likely see other almost identical lines in the `hardware-configuration.nix` already. DO NOT REMOVE THESE. If you look closely, they are slightly different. 

Now in your `~/.dotfiles/configuration.nix` file (which will from now on be referred to as your `configuration.nix` file), on (or around) line 112 you will see an `nvidia` section. In particular, you will see: 
```nix
# make sure correct Bus ID for system! Can run: lspci
prime = {
  # sync.enable = true; # might be good when plugged into external monitor? 
  nvidiaBusId = "PCI:1:0:0";
  intelBusId = "PCI:0:2:0";
};
```
We need to ensure that the `nvidiaBusId` and `intelBusId` correspond to the correct devices. We can do this by running `lspci`, where we should see a line that is similar to: 
```
00:02.0 VGA compatible controller: Intel Corporation Raptor Lake-P [Iris Xe Graphics] (rev 04)
```
(we are looking for the `Iris Xe Graphics`) 
and a line that is similar to: 
```
01:00.0 3D controller: NVIDIA Corporation AD107M [GeForce RTX 4060 Max-Q / Mobile] (rev a1)
```
(we are looking for our nvidia gpu)
In particular, our config expects our intel gpu at bus id `0:2:0`, or when translated to `lspci` language `00:02.0`, and our nvidia gpu at bus id `1:0:0` (or `01:00.0`). If these are not what you see in `lspci`, you need to update your config to match. In particular, every id will be similar to the form `01:00.0`. To convert to the id you will put in your config file, replace the `.` with a `:`, and remove the leading zero (if there is one) on the first and second numbers (separated by the colon). For example, `00:15.3` would become `0:15:3`. 

Once you made these changes, you are actually okay to move on, but there might be some other things you will want to change. In particular, you may want to change values seen in `~/.dotfiles/flake.nix`. Here, near the top (after `outputs = {}`) you will see values like `systemSettings.hostname` which you can change to be the desired name of your device (like on your internet or when bluetooth devices see it). You may want to change your `timezone` (here as well). You name also want to change your `username` and `name` under `userSettings` which will be the username and name, respectively, of your (single) user account. 

You probably also want to change your `git` username and email, which are set at the end of your `home/home.nix` file. 

From here, we can rebuild the system with (ensure you are in the directory `~/.dotfiles`): 
```sh
sudo nixos-rebuild switch --flake . --upgrade-all
home-manager switch --flake .
```
Reboot your system after this and you should be set! In particular, you should boot into a screen where you will see a could NixOS builds ("generations"), just pick the latest one. If you selected to encrypt your disk, it will ask you for that password next, and then will boot into your OS. You should see a pretty basic gnome-style screen where you can select your account and log in. This should then boot you straight into Hyprland! Note that `SUPER + Q` is bound to opening the terminal. 

From now on, every time you change your configuration, you can rebuild your system with: 
```sh
sudo nixos-rebuild switch --flake . # make sure you are in ~/.dotfiles
```
Every time you change your home-manager configuration (which I will talk about later), you run: 
```sh
home-manager switch --flake .
```
### Switching to the git version of Hyprland
You probably want to do this as the version of Hyprland in `nixpkgs` is a little old. First, determine that you aren't already on the git version by running: 
```sh
hyprctl version
realpath $(which Hyprland)
```
The first *should* make some mention of being built from some commit and should give a recent date. Further the second command should include a reference to the newest version of Hyprland in the path. As long as the second command checks out, you are good (don't worry too much if the first command just gives no info). But if the second command gives reference to an old version of Hyprland, then proceed: 

We need to rebuild our system without Hyprland once and then add Hyprland back in order to enable the caching functionailty so you don't have to manually build Hyprland every time. To do this, in `home/home.nix` comment out the `./hyprland/hyprland.nix` line in the `imports` array at the top of the file. Further, comment out the following code in `configuration.nix`: 
```nix
  programs.hyprland = {
    enable = true;
    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland; # enable git version of hyprland
    xwayland.enable = true;
  };
```
Now run: 
```sh
sudo nixos-rebuild switch --flake .
home-manager switch --flake .
```
Then, uncomment everything you just commented are re-run the above commands. From there, reboot and you should see that the first steps we took to see if Hyprland was on the git version now return what we expected. 

### Further Configuration
The first thing you may want to do is change the color scheme of the entire system. All of the colors are controlled in `flake.nix` under the `theme` variable set in the `outputs = {}` section. 
Under `theme` is all of the colors for your operating system. The `base00` through `base07` colors are grayscale going from dark to light (for dark mode) and light to dark (for light mode). If you change these, make sure to update the `base0x_rgb` to be the corresponding `rgb` values for the hex-codes you changed.
For `base08` through `base0F`, these are the accent colors for your system. In my config, `base0B` is a 'primary accent' and `base09` is a 'secondary accent', with `base0D` appearing quite often as an 'third accent'. Again make sure to update the `base0x_rgb` values. The `base0xalt` colors should be either slightly darker or slightly lighter across the board as compared to the corresponding `base0x` color. But you can do whatever you want with them, but not following this advice may result in some strange color schemes (also remember to update `base0xalt_rgb` accordingly). For `base0D`, you also need to specify a gradient to be used in a couple of places. This is done through the `base0Dalt2`, `base0Dalt3`, and `base0Dalt4` variables. This will look best if it is a gradient from lighter (`base0Dalt`) to darker `base0Dalt4` (also update the `base0Dalty_rgb` values!). 
Finally, `dark_background_primary` and `dark_background_primary_rgb` (remember to set to same color!) are used as backgrounds for certain ui elements/areas. For dark mode this should be pretty dark, and inverse for light mode. Ideally, this is almost black with a slight shift towards your accent color of choice. But up to you.

Configuration of all applications are done with `home-manager`. With the exception of your shell and git, which are configured in `home/home.nix` near the end, all apps that have configuration are configured within the `home` directory with the path `home/applicationname/applicationname.nix`. In here, you can change the configuration for all these applications. If you want to learn about what configuration is available, go to `mynixos.com` and search for "home-manager [applicationname]" to see all the options. You may want to start with the `home/hyprland/hyprland.nix` file and change settings like monitor settings, transparency, and bindings. 
