{
  go = {
    path = ./go;
    description = "Go development environment";
  };

  node = {
    path = ./node;
    description = "Nodejs development environment";
  };

  ##########################################################################################
  # $ nix develop --no-substitute "github:budhilaw/dvt?dir=php" --impure --refresh -c $SHELL
  ##########################################################################################
  php = {
    path = ./php;
    description = "PHP development environment";
  };

}