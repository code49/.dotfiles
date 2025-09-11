{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
	buildInputs = [ pkgs.systemd pkgs.conda ];
	
	shellHook = ''
	  export LD_LIBRARY_PATH=${pkgs.systemd}/lib

	  conda-shell
        '';
}
