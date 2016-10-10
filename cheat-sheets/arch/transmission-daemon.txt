Transmission 2.92 (14714)  http://www.transmissionbt.com/
A fast and easy BitTorrent client

transmission-daemon is a headless Transmission session
that can be controlled via transmission-remote
or the web interface.

Usage: transmission-daemon [options]

Options:
 -h   --help                             Display this help page and exit
 -a   --allowed              <list>      Allowed IP addresses. (Default:
                                         127.0.0.1)
 -b   --blocklist                        Enable peer blocklists
 -B   --no-blocklist                     Disable peer blocklists
 -c   --watch-dir            <directory> Where to watch for new .torrent files
 -C   --no-watch-dir                     Disable the watch-dir
      --incomplete-dir       <directory> Where to store new torrents until
                                         they're complete
      --no-incomplete-dir                Don't store incomplete torrents in a
                                         different location
 -d   --dump-settings                    Dump the settings and exit
 -e   --logfile              <filename>  Dump the log messages to this filename
 -f   --foreground                       Run in the foreground instead of
                                         daemonizing
 -g   --config-dir           <path>      Where to look for configuration files
 -p   --port                 <port>      RPC port (Default: 9091)
 -t   --auth                             Require authentication
 -T   --no-auth                          Don't require authentication
 -u   --username             <username>  Set username for authentication
 -v   --password             <password>  Set password for authentication
 -V   --version                          Show version number and exit
      --log-error                        Show error messages
      --log-info                         Show error and info messages
      --log-debug                        Show error, info, and debug messages
 -w   --download-dir         <path>      Where to save downloaded data
      --paused                           Pause all torrents on startup
 -o   --dht                              Enable distributed hash tables (DHT)
 -O   --no-dht                           Disable distributed hash tables (DHT)
 -y   --lpd                              Enable local peer discovery (LPD)
 -Y   --no-lpd                           Disable local peer discovery (LPD)
      --utp                              Enable uTP for peer connections
      --no-utp                           Disable uTP for peer connections
 -P   --peerport             <port>      Port for incoming peers (Default:
                                         51413)
 -m   --portmap                          Enable portmapping via NAT-PMP or UPnP
 -M   --no-portmap                       Disable portmapping
 -L   --peerlimit-global     <limit>     Maximum overall number of peers
                                         (Default: 200)
 -l   --peerlimit-torrent    <limit>     Maximum number of peers per torrent
                                         (Default: 50)
 -er  --encryption-required              Encrypt all peer connections
 -ep  --encryption-preferred             Prefer encrypted peer connections
 -et  --encryption-tolerated             Prefer unencrypted peer connections
 -i   --bind-address-ipv4    <ipv4 addr> Where to listen for peer connections
 -I   --bind-address-ipv6    <ipv6 addr> Where to listen for peer connections
 -r   --rpc-bind-address     <ipv4 addr> Where to listen for RPC connections
 -gsr --global-seedratio     ratio       All torrents, unless overridden by a
                                         per-torrent setting, should seed until
                                         a specific ratio
 -GSR --no-global-seedratio              All torrents, unless overridden by a
                                         per-torrent setting, should seed
                                         regardless of ratio
 -x   --pid-file             <pid-file>  Enable PID file