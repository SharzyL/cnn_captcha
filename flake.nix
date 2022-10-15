{
  description = "captcha recognizer";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    py36nixpkgs.url = github:NixOS/nixpkgs/860b56be91fb874d48e23a950815969a7b832fbc;
    cu8nixpkgs.url = github:NixOS/nixpkgs/bed08131cd29a85f19716d9351940bdc34834492;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, py36nixpkgs, cu8nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs { inherit system; config = {allowUnfree = true; };};
        py36 = (import py36nixpkgs { inherit system; }).python36;
        cu8pkgs = import cu8nixpkgs { inherit system; config = { allowUnfree = true; }; };
      in
        rec {
          defaultApp = pkgs.writeScriptBin "recognize" ''
                export CUDA_PATH=${cu8pkgs.cudatoolkit}
                export LD_LIBRARY_PATH=${cu8pkgs.cudnn6_cudatoolkit_8}/lib:$LD_LIBRARY_PATH
                export LD_LIBRARY_PATH=${cu8pkgs.cudatoolkit_8}/lib:$LD_LIBRARY_PATH
                export LD_LIBRARY_PATH=${cu8pkgs.cudatoolkit_8.lib}/lib:$LD_LIBRARY_PATH
                export LD_LIBRARY_PATH=${cu8pkgs.linuxPackages.nvidia_x11}/lib:$LD_LIBRARY_PATH
                LD_LIBRARY_PATH=${py36.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH ${pkgs.poetry}/bin/poetry run python recognize.py
            '';
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              cudatoolkit
              poetry
            ];
            shellHook = ''
              export CUDA_PATH=${cu8pkgs.cudatoolkit}
              export LD_LIBRARY_PATH=${cu8pkgs.cudnn6_cudatoolkit_8}/lib:$LD_LIBRARY_PATH
              export LD_LIBRARY_PATH=${cu8pkgs.cudatoolkit_8}/lib:$LD_LIBRARY_PATH
              export LD_LIBRARY_PATH=${cu8pkgs.cudatoolkit_8.lib}/lib:$LD_LIBRARY_PATH
              export LD_LIBRARY_PATH=${cu8pkgs.linuxPackages.nvidia_x11}/lib:$LD_LIBRARY_PATH

              echo "-----------"
              echo "Please use tensorflow with the following prefix:"
              echo 'export LD_LIBRARY_PATH=${py36.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH'
              echo "-----------"

              poetry env use ${py36}/bin/python3 -q
              source $(poetry env info --path)/bin/activate -q
            '';
          };
        }
      );
}
