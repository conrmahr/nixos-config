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

  networking.hostName = "jubjub"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

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
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    git
    gh
    wget
    iperf3
    neofetch
    tmux
    rsync
    iotop
    ncdu
    nmap
    jq
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
        " Turn on syntax highlighting by default
        syntax on
        " ...
      '';
    })
  ];

  nixpkgs = { config = { allowUnfree = true; }; };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.zsh.enable = true;

  # List services that you want to enable:
  services.openssh.enable = true;

  # Setup AFP  Server
  services.netatalk = {
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

  # Setup Avahi Service
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  # Check if share folder is created and set
  systemd.tmpfiles.rules = [ "d /mnt/data1 0755 conor users" ];

  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 548 ];
  networking.firewall.allowedUDPPorts = [ 5353 ];

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
