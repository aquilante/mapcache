#FROM ubuntu:noble AS development_build
ARG ARCH="amd64"
FROM ${ARCH}/ubuntu:24.04


ARG NRT_DATAPATH
ARG aws_access_key_id
ARG aws_secret_access_key

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
        MEMCACHE=172.31.5.240:11211 \
        MS_ERRORFILE=/var/log/mapserv/error.log

RUN apt-get update

RUN apt-get install -y tzdata
RUN ln -fs /usr/share/zoneinfo/Europe/Rome /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get install -y git binutils rustc cargo pkg-config libssl-dev gettext

#Installing efs-utils
# RUN git clone https://github.com/aws/efs-utils && \
#         cd efs-utils && \
#         ./build-deb.sh
# RUN mv efs-utils/build/amazon-efs-utils*deb .
# RUN apt-get -y install ./amazon-efs-utils*deb
# RUN rm -R efs-utils
# RUN echo "fs-6eb8a8a5:/ /mnt/efs efs _netdev,defaults,nofail 0 0" | tee -a /etc/fstab > /dev/null
RUN mkdir /mnt/efs

RUN apt-get update && apt-get install -y curl gnupg2 rsyslog authbind \
        apache2 apache2-bin apache2-utils cgi-mapserver \
        mapserver-bin mapserver-doc libmapscript-perl\
        python3-mapscript python3-pip libapache2-mod-fcgid \
        lsb-release libmapcache1t64 liblmdb-dev \
        nfs-common unzip vim screen  htop
        # mapcache-cgi mapcache-tools 
        # memcached

RUN a2enmod cgi fcgid rewrite headers 
#remoteip

RUN mkdir /var/log/mapserv
RUN chown www-data:www-data /var/log/mapserv

RUN curl -s https://repos.influxdata.com/influxdb.key | apt-key add -

RUN curl --silent --location -O \
https://repos.influxdata.com/influxdata-archive.key \
&& echo "943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515  influxdata-archive.key" \
| sha256sum -c - && cat influxdata-archive.key \
| gpg --dearmor \
|  tee /etc/apt/trusted.gpg.d/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
|  tee /etc/apt/sources.list.d/influxdata.list

RUN apt-get update && apt-get install telegraf
COPY telegraf.conf /etc/telegraf/telegraf.conf
RUN chmod a+r /etc/telegraf/telegraf.conf

RUN echo "*.* @172.31.4.182:5514;RSYSLOG_SyslogProtocol23Format" | tee -a /etc/rsyslog.conf > /dev/null

COPY apache/ports.conf /etc/apache2/ports.conf
COPY apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY apache/fcgid.conf /etc/apache2/mods-available/fcgid.conf

COPY dates.db  /data/dates.db
# COPY preseed.py  /data/preseed.py
# COPY requirements.txt  /data/requirements.txt
# RUN pip install -r /data/requirements.txt --break-system-packages

RUN apt-get clean -y 
RUN apt-get autoremove -y --purge

RUN mkdir -p /data/tmp && chown -R www-data:www-data /data/tmp
RUN mkdir -p /data/lock && chown -R www-data:www-data /data/lock

COPY build/libmapcache.so.1 /usr/lib/cgi-bin/libmapcache.so.1
COPY build/cgi/mapcache.fcgi /usr/lib/cgi-bin/mapcache

VOLUME /data
WORKDIR /data
EXPOSE 8081 8080
# ENTRYPOINT ["/bin/bash"]
ENV MS_ERRORFILE=/var/log/mapserv/error.log \
    MAPSERVER_CONFIG_FILE=/mnt/efs/mapfiles/mapserver.conf
CMD ["apachectl", "-D", "FOREGROUND"]  
