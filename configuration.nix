# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  my-kubernetes-helm = with pkgs; wrapHelm kubernetes-helm {
    plugins = with pkgs.kubernetes-helmPlugins; [
      helm-secrets
      helm-diff
      helm-s3
      helm-git
    ];
  };

  my-helmfile = pkgs.helmfile-wrapped.override {
    inherit (my-kubernetes-helm) pluginsDir;
  };
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lenovo-p330-1"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "id_ID.UTF-8";
    LC_IDENTIFICATION = "id_ID.UTF-8";
    LC_MEASUREMENT = "id_ID.UTF-8";
    LC_MONETARY = "id_ID.UTF-8";
    LC_NAME = "id_ID.UTF-8";
    LC_NUMERIC = "id_ID.UTF-8";
    LC_PAPER = "id_ID.UTF-8";
    LC_TELEPHONE = "id_ID.UTF-8";
    LC_TIME = "id_ID.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm = {
    enable = true;
    autoSuspend = false;
    autoLogin = {
      delay = 5;
    };
  };
  services.xserver.desktopManager.gnome.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "guest";
  };   

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      variant = "";
      layout = "us";
    };
  };

  services.openssh = {
    enable = true;
  };
  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hilman = {
    isNormalUser = true;
    description = "Hilman Kurniawan";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;

  };

  users.users.guest = {
    uid = 1100;
    isNormalUser = true;
    description = "guest";
    password = "";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    firefox
    git
    google-chrome
    gnomeExtensions.appindicator
    gnomeExtensions.freon
    gnomeExtensions.lock-keys
    gnomeExtensions.onedrive
    gnomeExtensions.net-speed-simplified
    gnome-settings-daemon
    htop
    jq
    k9s
    kubectl-neat
    kubectl-cnpg
    kubectx
    libreoffice
    lm_sensors
    microsoft-edge
    meld
    my-helmfile
    my-kubernetes-helm
    shutter
    spotify
    telegram-desktop
    terminator
    thunderbird
    variety
    vlc
    vscode-fhs
    zoom-us
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.vim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.vim-full;
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      _ffmpeg-anbernic = "ffmpeg -i \${FF_INPUT} -vf scale=640x480 -vcodec libx264 -profile:v main -level 3.1 -preset medium -crf 23 -x264-params ref=4 -acodec libvorbis -movflags +faststart \${FF_INPUT}.mkv";
      _kube-activate = "export PROMPT='$(kube_ps1)'$PROMPT";
      _kube-deactivate = "export PROMPT=\${PROMPT//'$(kube_ps1)'}";
    };

    ohMyZsh = {
      enable = true;
      plugins = ["aws" "git" "kubectl" "kubectx" "kube-ps1" "man"];
      theme = "robbyrussell";
    };
  };
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.tailscale.enable = true;
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [
      " --node-label node-group=dns"
      " --service-node-port-range=30000-32767"
    ];
  };

  services.coredns = {
    enable = true;
    config = ''
.:53 {
  forward . 127.0.0.1:30053
}
'';
  };
  # Open ports in the firewall.
  networking = {
    firewall = {
      enable = false;
      allowedTCPPorts = [6443 30053 8080];
      allowedUDPPorts = [30053];
    };
  };
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
