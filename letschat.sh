echo "

+--------------------------------------------------------------------------+
|                           Let's Chat Install Script,                     |
|                                by Damien B.                              |
|                                    https://alphagame.dev/                |
|             https://github.com/AlphaGameDeveloper/LetsChatInstallScript/ |
+--------------------------------------------------------------------------+


NOTE >>>
  - I did not find out any of the command(s) in this InstallScript.
  - Please go to < https://www.atlantic.net/vps-hosting/how-to-install-lets-chat-on-an-ubuntu-20-04/ > to give some credit.

Description >>>
  - Just automates commands from "https://www.atlantic.net/vps-hosting/how-to-install-lets-chat-on-an-ubuntu-20-04/".
  - Go to < https://github.com/AlphaGameDeveloper/AutoInstallScripts/ > for more information.
  
  Thanks for using this script.





"
if (whoami != root)
  then echo "Please run as root"
  exit
fi

echo "Updating repositories before starting...




"
apt-get update -y
echo "




Done updating repositories; Installation starting.




"
apt-get install curl gnupg2 unzip software-properties-common git build-essential sudo -y
echo "




Installing Node.JS Install Script.




"
curl -sL https://deb.nodesource.com/setup_10.x | bash -
echo "




Installing Node.JS.




"
apt-get install nodejs -y
echo "




Checking if Node.JS is installed.  Should display 'v10.23.0'."
node -v
echo "




Installing MongoDB.




"
curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
echo "




Adding it to APT.




"
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
echo "




Re-updating.




"
apt-get update -y
echo "




Finally installing MongoDB.




"
apt-get install mongodb-org -y
systemctl start mongod
systemctl enable mongod
echo "




Finally installing Let's Chat!




"
git clone https://github.com/sdelements/lets-chat.git
cd lets-chat
npm install
cp settings.yml.sample settings.yml
echo "




Copying service file.




"
echo "[Unit]
Description=Let's Chat Server
Wants=mongodb.service
After=network.target mongod.service

[Service]
Type=simple
WorkingDirectory=/root/lets-chat
ExecStart=/usr/bin/npm start
User=root
Group=root
Restart=always
RestartSec=9

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/letschat.service
systemctl daemon-reload
systemctl start letschat.service
systemctl enable letschat.service
echo "




Installing Nginx for Let's Chat.



"
echo "server {
server_name letschat.example.com;
listen 80;

access_log /var/log/nginx/lets_chat-access.log;
error_log /var/log/nginx/lets_chat-error.log;

location / {
proxy_set_header   X-Real-IP $remote_addr;
proxy_set_header   Host      $host;
proxy_http_version 1.1;
proxy_set_header   Upgrade $http_upgrade;
proxy_set_header   Connection 'upgrade';
proxy_cache_bypass $http_upgrade;
proxy_pass         http://127.0.0.1:5000;
}

}" > /etc/nginx/sites-available/letschat.conf
ln -s /etc/nginx/sites-available/letschat.conf /etc/nginx/sites-enabled/
echo "user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
        # multi_accept on;
}

http {

        ##
        # Basic Settings
        ##
        server_names_hash_bucket_size 64; sendfile on; tcp_nopush on; tcp_nodelay on; keepalive_timeout 65; types_hash_max_size 2048;
        # server_tokens off;

        # server_names_hash_bucket_size 64;
        # server_name_in_redirect off;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ##
        # SSL Settings
        ##

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        ##
        # Logging Settings
        ##

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        ##
        # Gzip Settings
        ##

        gzip on;

        # gzip_vary on;
        # gzip_proxied any;
        # gzip_comp_level 6;
        # gzip_buffers 16 8k;
        # gzip_http_version 1.1;
        # gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

        ##
        # Virtual Host Configs
        ##

        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
}


#mail {
#       # See sample authentication script at:
#       # http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript
# 
#       # auth_http localhost/auth.php;
#       # pop3_capabilities "TOP" "USER";
#       # imap_capabilities "IMAP4rev1" "UIDPLUS";
# 
#       server {
#               listen     localhost:110;
#               protocol   pop3;
#               proxy      on;
#       }
# 
#       server {
#               listen     localhost:143;
#               protocol   imap;
#               proxy      on;
#       }
#}" > /etc/nginx/nginx.conf
echo "Restarting Nginx before exiting..."
systemctl restart nginx
echo "




+----------------------------------------------------------------------------+
|                 Script complete.                                           |
|     https://github.com/AlphaGameDeveloper/LetsChatInstallScript            |
|         https://alphagame.dev/                                             |
|        Script by Damien Boisvert (AlphaGameDeveloper)                      |
|                      Thank you ;)                                          |
+----------------------------------------------------------------------------+




"
