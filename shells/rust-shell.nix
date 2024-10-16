{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    gcc
    cargo
    rustc
    pkg-config
    openssl
    rustup
    ninja
    cmake
    llvmPackages_latest.llvm
    # llvm_8
    libffi
    libxml2
  ];
  runScript = "zsh";

  NIX_ENFORCE_PURITY = 0;

  shellHook = ''
    eval "$(zoxide init --cmd cd zsh)"
  '';
}
