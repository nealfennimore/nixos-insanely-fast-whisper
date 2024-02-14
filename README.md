# NixOS Insanely Fast Whisper

## NixOS System

On versions:

```sh
nixos: "24.05pre583447.f9d39fb9aff0"
nixpkgs: "24.05pre583579.2d627a2a7047"
```

Relevant config:

```nix
services.xserver = {
    videoDrivers = [ "nvidia" ];
    exportConfiguration = true;
    # For 3rd eGPU
    extraConfig = ''
    Section "Device"
      Identifier "Device-nvidia[1]"
      Driver "nvidia"
      BusID "PCI:8:0:0"
      Option "AllowExternalGpus"
      Option "AllowEmptyInitialConfiguration"
    EndSection
    '';
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    prime = {
      allowExternalGpu = true;
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
```
