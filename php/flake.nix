{
  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = { self, nixpkgs, devenv, systems, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
      });

      devShells = forEachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            default = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [ ({ pkgs, config, ... }: {
                  env.DBNAME = "my_db_name";
                  env.DBUSER = "myusername";
                  env.HOSTNAME = "localhost";

                  packages = with pkgs; [ pkgs.bashInteractive ];

                  # Enable PHP-FPM languages
                  languages.php = {
                    enable = true;
                    version = "8.3";
                    ini = ''
                      memory_limit = 256M
                    '';
                    fpm.pools.web = {
                      settings = {
                        "listen" = "127.0.0.1:9000";
                        "pm" = "dynamic";
                        "pm.max_children" = 5;
                        "pm.start_servers" = 2;
                        "pm.min_spare_servers" = 1;
                        "pm.max_spare_servers" = 3;
                      };
                    };
                  };

                  # see full options: https://devenv.sh/supported-services/mysql/
                  services.mysql.enable = true;
                  services.mysql.package = pkgs.mysql80;
                  services.mysql.ensureUsers = [
                  {
                      name = "myusername";
                      password = "mypassword";
                      ensurePermissions =
                      {
                          "database.*" = "ALL PRIVILEGES";
                          "*.*" = "ALL PRIVILEGES";
                      };
                  }];
                  services.mysql.initialDatabases = [ { name = "my_db_name"; } ];

                  # see full options: https://devenv.sh/supported-services/nginx/
                  # Nginx configuration
                  services.nginx = {
                    enable = true;
                    
                    # HTTP configuration
                    httpConfig = ''
                      # Default server block
                      server {
                          listen 80;
                          server_name localhost;
                          
                          # Root directory set to the same directory as flake.nix
                          root ${config.env.DEVENV_ROOT}/public;
                          
                          # Default index files - added index.php
                          index index.php index.html index.htm;
                          
                          # Basic location block for the root path
                          location / {
                              try_files $uri $uri/ /index.php?$args;
                          }
                          
                          # PHP handling
                          location ~ \.php$ {
                              fastcgi_split_path_info ^(.+\.php)(/.+)$;
                              fastcgi_pass 127.0.0.1:9000;
                              fastcgi_index index.php;
                              include ${pkgs.nginx}/conf/fastcgi_params;
                              include ${pkgs.nginx}/conf/fastcgi.conf;
                              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                              fastcgi_param PATH_INFO $fastcgi_path_info;
                          }

                          # Deny access to .htaccess files
                          location ~ /\.ht {
                              deny all;
                          }
                          
                          # Example API proxy
                          location /api {
                              proxy_pass http://localhost:3000;
                              proxy_http_version 1.1;
                              proxy_set_header Upgrade $http_upgrade;
                              proxy_set_header Connection 'upgrade';
                              proxy_set_header Host $host;
                              proxy_cache_bypass $http_upgrade;
                          }
                          
                          # Security headers
                          add_header X-Frame-Options "SAMEORIGIN";
                          add_header X-XSS-Protection "1; mode=block";
                          add_header X-Content-Type-Options "nosniff";
                          
                          # Enable gzip compression
                          gzip on;
                          gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
                          
                          # Error pages
                          error_page 404 /404.html;
                          error_page 500 502 503 504 /50x.html;
                      }
                    '';
                  };

                  scripts.up.exec = # bash
                  ''
                    devenv up
                  '';
                })
              ];
            };
          }
        );
    };
}