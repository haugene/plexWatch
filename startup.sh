#!/bin/bash

# Use provided config if none exists
if [ ! -f /plexWatch/config.php ]; then
  echo "Using default config.php"
  cp /tmp/config.php /plexWatch/config.php
fi

# If no database exists, touch it to make sure we get the right permissions
if [ ! -f /plexWatch/plexWatch.db ]; then
	touch /plexWatch/plexWatch.db
fi

# download plexWatch.pl if it doesn't already exist
if [ ! -f /plexWatch/plexWatch.pl ]; then
  echo "Downloading plexWatch.pl..."
  wget -P /plexWatch/ https://raw.githubusercontent.com/ljunkie/plexWatch/v0.2.8/plexWatch.pl
fi

# download the default plexWatch config.pl file if it doesn't already exist
if [ ! -f /plexWatch/config.pl ]; then
  echo "Downloading plexWatch config.pl"
  wget -P /plexWatch/ https://raw.githubusercontent.com/ljunkie/plexWatch/v0.2.8/config.pl-dist
  mv /plexWatch/config.pl-dist /plexWatch/config.pl

  # set the data_dir location
  sed -i \
	-e "s#\(data_dir = '\).*'#\1/plexWatch/'#" \
	-e "s#\(server = '\).*'#\1plex'#" \
	/plexWatch/config.pl
fi

# set server_log in the plexWatch config.pl file
if [ -f /config/Library/Application\ Support/Plex\ Media\ Server/Logs/Plex\ Media\ Server.log ]; then
  echo "Plex Media Server.log located in /config from Plex container"
  sed -i -e "s#\(server_log = '\).*'#\1/config/Library/Application Support/Plex Media Server/Logs/Plex Media Server.log'#" /plexWatch/config.pl
else
  echo "Error: Unable to locate the 'Plex Media Server.log' file. Did you link your Plex container to this container?"
  echo "Expected file /config/Library/Application Support/Plex Media Server/Logs/Plex Media Server.log"
  exit 1 # terminate and indicate error
fi


echo "Setting permissions"
usermod -a -G www-data plexweb
chown -R plexweb:www-data /plexWatch
chmod g+rwxs /plexWatch
chmod 775 -R /plexWatch

echo "Starting cron"
cron

exec /usr/sbin/apache2 -D FOREGROUND
