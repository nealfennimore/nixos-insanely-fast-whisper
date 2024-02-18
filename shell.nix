{ pkgs ? import <nixpkgs> {
  config = {
    allowUnfree = true;
    cudaSupport = true;
  };
} }:
let cuda = pkgs.cudaPackages_12_1;
    py = pkgs.python311Packages;
in
with pkgs;
mkShell {
  buildInputs = [
    cuda.cudatoolkit
    cuda.cudnn
    ffmpeg
    libGL
    libGLU
    py.pip
    py.torch-bin
    py.torchaudio-bin
    py.torchmetrics
    py.torchvision-bin
    py.virtualenv
  ];

  shellHook = ''
    # export CUDA_PATH=${cuda.cudatoolkit}
    # export CUDAToolkit_ROOT=${cuda.cudatoolkit}

    if [[ ! -d .venv ]]; then
      python -m venv .venv
      source .venv/bin/activate
      if [[ -f requirements.txt ]]; then
        pip install \
          -r requirements.txt \
          --require-virtualenv \
          --ignore-requires-python
      fi
    else 
      source .venv/bin/activate
    fi
  '';

  packages = [
    python311
  ];
}
