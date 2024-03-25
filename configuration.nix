# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.zfs.extraPools = [ "jjpool" ];

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.conor = {
    isNormalUser = true;
    home = "/home/conor";
    description = "";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINkuFaBSpJHo/xVAoYXaxdfH9RBx/3/poeZF2FloDgBB conor@itchy"
    ];
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    sbctl
    niv
    git
    gh
    wget
    neofetch
    tmux
    rsync
    iotop
    nmap
    lsof
    htop
    nixfmt
    ((vim_configurable.override { }).customize {
      name = "vim";
      # Install plugins for example for syntax highlighting of nix files
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
        start = [ vim-nix vim-lastplace ];
        opt = [ ];
      };
      vimrcConfig.customRC = ''
        " your custom vimrc
        set nocompatible
        set backspace=indent,eol,start
        set number
        set title
        " Turn on syntax highlighting by default
        syntax on
        " ...
      '';
    })
  ];

  # Unlock storage disks
  environment.etc.crypttab.text = ''
    cryptssd1 /dev/disk/by-uuid/b37a75d9-2a49-405e-9f28-9984550ae210 /dev/mapper/cryptkey keyfile-size=8192
    cryptssd2 /dev/disk/by-uuid/8a299f1c-d217-4798-ad1e-5fc9abfd6d3d /dev/mapper/cryptkey keyfile-size=8192
    crypthdd1 /dev/disk/by-uuid/79435cec-1da7-432a-8799-9fdd608d3761 /dev/mapper/cryptkey keyfile-size=8192
    crypthdd2 /dev/disk/by-uuid/fd608556-e193-4df1-bd2d-3018791ad169 /dev/mapper/cryptkey keyfile-size=8192
  '';

  nixpkgs = { config = { allowUnfree = true; }; };

  # List of programs to enable
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
    };
  };

  # List services that you want to enable:
  services = {
    # Start SSHD
    openssh.enable = true;

    # Setup AFP  Server
    netatalk = {
      enable = true;
      settings = {
        audio = {
          path = "/mnt/data1/audio";
          "valid users" = "conor";
        };
        files = {
          path = "/mnt/data1/files";
          "valid users" = "conor";
        };
        inbox = {
          path = "/mnt/data1/inbox";
          "valid users" = "conor";
        };
        photo = {
          path = "/mnt/data1/photo";
          "valid users" = "conor";
        };
        video = {
          path = "/mnt/data1/video";
          "valid users" = "conor";
        };
        backup-itchy = {
          path = "/mnt/data1/backup/itchy";
          "valid users" = "conor";
          "time machine" = "yes";
        };
      };
    };

    # Enable Avahi Service
    avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
  };

  networking = {
    hostName = "jubjub"; # Define your hostname.
    firewall = {
      enable = true; # Enable firewall
      allowedTCPPorts = [ 548 ];
      allowedUDPPorts = [ 5353 ];
    };
  };

  # Check if share folder is created and set
  systemd.tmpfiles.rules =
    [ "d /mnt/data1 0755 conor users" "Z /mnt/data1 0755 conor users" ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

}
