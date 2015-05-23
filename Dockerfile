FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -q

# Install plexWatch Dependencies
RUN apt-get install -qy libwww-perl libxml-simple-perl libtime-duration-perl libtime-modules-perl libdbd-sqlite3-perl perl-doc libjson-perl libfile-readbackwards-perl

# Install plexWatchWeb Dependencies
RUN apt-get install -qy apache2 libapache2-mod-php5 wget php5-sqlite php5-curl

# Enable PHP
RUN a2enmod php5

# Delete the annoying default index.html page
RUN rm -f /var/www/html/index.html

# Update apache configuration with this one
ADD apache-config.conf /etc/apache2/sites-available/000-default.conf
ADD ports.conf /etc/apache2/ports.conf

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# User for the cron jobs
RUN groupadd plexweb
RUN useradd -g plexweb plexweb
RUN passwd -d plexweb
RUN echo "plexweb All=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir -p /var/www/html/plexWatch
RUN chown plexweb:plexweb /var/www/html/plexWatch

ADD startup.sh /etc/startup.sh
RUN chmod +x /etc/startup.sh

# Add our crontab file
ADD crons.conf /root/crons.conf
RUN crontab -u plexweb /root/crons.conf

# Install plexWatchWeb v1.5.4.2
RUN wget -P /tmp/ https://github.com/ecleese/plexWatchWeb/archive/v1.5.4.2.tar.gz
RUN tar -C /var/www/html/plexWatch -xvf /tmp/v1.5.4.2.tar.gz --strip-components 1

EXPOSE 8080
VOLUME /plexWatch

# Set plexWatchWeb to use config.php in /plexWatch
RUN ln -s /plexWatch/config.php /var/www/html/plexWatch/config/config.php

CMD [ "/etc/startup.sh" ]
