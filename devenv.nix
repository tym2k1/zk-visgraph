{ pkgs, lib, config, inputs, ... }:

{

  packages = with pkgs; [
    gtk3
    glib
    webkitgtk
    python311Packages.pygobject3
  ];
  languages.python = {
    enable = true;
    venv = {
      enable = true;
      requirements = (builtins.readFile ./requirements.txt);
    };
  };
}
