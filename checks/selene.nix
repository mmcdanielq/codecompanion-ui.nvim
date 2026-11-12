{ self, pkgs, ... }:
pkgs.runCommand "selene"
  {
    nativeBuildInputs = [ pkgs.selene ];
  }
  ''
    selene ${self}/lua ${self}/tests --config ${self}/selene.toml
    touch $out
  ''
