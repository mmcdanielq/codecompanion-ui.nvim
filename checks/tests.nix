{
  self,
  pkgs,
  codecompanion-nvim,
  plenary-nvim,
  ...
}:
pkgs.runCommand "tests"
  {
    nativeBuildInputs = with pkgs; [
      neovim
      lua51Packages.busted
      lua51Packages.nlua
    ];
  }
  ''
    export HOME="$(mktemp -d)"
    export CODECOMPANION_NVIM_PATH=${codecompanion-nvim}
    export PLENARY_NVIM_PATH=${plenary-nvim}
    cd ${self}
    busted
    touch $out
  ''
