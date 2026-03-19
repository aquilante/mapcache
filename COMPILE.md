TO BUILD THE IMAGE
==================
This doesn't have a container but it just provide binaries for the mapserver (wms2) image

TO DEPLOY
=========
This is note deployed by its own but trough the mapserver project

NOTE: the naming convention for the node-groupos in the cluster is:
- for AMD64 arch: *nodegroup-name*
- for ARM64 arch: arm-*nodegroup-name*
and the same naming convention is used for tolerations and taints

AOB
==============

STYLE
======
host: change the host and create the legend url automatically based on the parameters of the source
href: the full url to use for the legend


sudo apt install apache2-dev apache2-ssl-dev libfcgi-dev libpixman-1-dev

look at the file workflow.sh


PATH_INFO=/wmts MAPCACHE_CONFIG_FILE=/mnt/nfs/mapfiles/mapcache_gwis.xml QUERY_STRING='SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=ecmwf.fwi&STYLE=default&FORMAT=image/png;%20mode%3D8bit&TILEMATRIXSET=ECMWF3857&TILEMATRIX=3&time=2025-03-19&TILEROW=5&TILECOL=0' /usr/lib/cgi-bin/mapcache


PATH_INFO=/wmts MAPCACHE_CONFIG_FILE=/mnt/nfs/mapfiles/mapcache_gwis.xml QUERY_STRING='SERVICE=WMTS&REQUEST=GetCapabilities' /usr/lib/cgi-bin/mapcache