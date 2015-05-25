PlexWatchWeb configured for container linking
----------

I was having issues setting up PlexWatch and PlexWatchWeb using images from the registry.
First it seems like PlexWatchWeb is not compatible with the lastest version of PlexWatch(?) and I wanted to avoid putting the containers in host or bridge mode. Also getting past some permission and other issues was a hassle.

I'm using the timhaak/plex image for my Plex server, and it exposes a /config volume where the logs can be found. I therefore configured this container to work by container linking to my Plex container so that I don't have to update the config files manually.

This container, with one prerequisite, will run a preconfigured plexWatchWeb and no configuration is neccessary.

Prerequisite
----------
When we start the container, we will link our Plex container exposing /config to the plexWatchWeb.
For plexWatch to access Plex we need to tell Plex to allow access from hosts in the Docker ip-range.

We need to edit Preferences.xml in Plex so that the allowedNetworks attribute looks something like this:
>allowedNetworks="192.168.1.0/255.255.255.0,172.17.0.0/255.255.0.0"

In this case, devices on the home network (192.168.1.x) and docker network (172.17.x.x) will be allowed access without password prompt.

Start the container
----------
After configuring Plex to let us in, start PlexWatchWeb

```
$ docker run -d \
              -v /your/storage/path/:/plexWatch \
              -p 8080:8080 \
              --link <your-plex>:plex
              --volumes-from plex
              haugene/plexWatchWeb
```

PlexWatchWeb will be avaliable at http://your-host:8080 and you should go there to finish the setup.
Plex IP Address: plex
Port: 32400 (default)
Secure port: 32443 (default)
PlexWatch db: /plexWatch/plexWatch.db

This should then give you a working plexWatchWeb instance. Be aware that the plexWatch cron job runs once every minute. On the first run it will initialize the database and quit, the next run will initialize the DB and start reading the logs. In short: be sure to actually play something and give it some minutes before concluding it doesn't work on the first run.

Troubleshooting
----------
There are several areas for improvements in this container. Things like external configuration options and run newer version of plexWatch. But I'm leaving that for later, PR's are welcome!

Other than that, this is a fork and you can check the main repository for more info.
