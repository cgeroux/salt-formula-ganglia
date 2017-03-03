#edit gmond.conf
#if master
#  install 
#  - apache2
#  - ganglia-monitor
#  - ganglia-monitor-python
#  - ganglia-modules-linux
#  - ganglia-webfrontend
#  - rrdtool
#  - gmetad
#  replace "mcast_join = 239.2.11.71" with "host = localhost"
#  replace "host_dmax = 0" or "host_dmax = 86400" with "host_dmax = 90"
#  comment out line with "mcast_join=239.2.11.71"
#  comment out line with "bind=239.2.11.71"
#  copy over apache setting file from "/etc/ganglia-webfrontend/apache.conf" to "/etc/apache2/sites-enabled/ganglia.conf"
#  restart services apache2, ganglia-monitor, gmetad
#else
#  install
#  - ganglia-monitor
#  - ganglia-modules-linux
#  - ganglia-monitor-python
#  replace "mcast_join = 239.2.11.71" with "host = <master-ip>"
#  replace "host_dmax = 0" or "host_dmax = 86400" with "host_dmax = 90"
#  replace "deaf = no" with "def = yes"
#  comment out section between "You can specify as many udp_recv_channels" and "You can specify as many udp_recv_channels"
#  restart services ganglia-monitor, and again after 30 seconds? I think this is required to ensure that master is up before ganglia-monitor has been started


#install packages
ganglia-monitor:
  pkg.installed
ganglia-monitor-python:
  pkg.installed
ganglia-modules-linux:
  pkg.installed

{% if 'ganglia_master' in grains['roles'] %}

#install master specific packages
apache2:
  pkg.installed
ganglia-webfrontend:
  pkg.installed
rrdtool:
  pkg.installed
gmetad:
  pkg.installed

#ensure a directory is available for gmond-default.conf
/etc/ganglia/gmond.conf:
  file.managed:
   - source: salt://ganglia/files/gmond-default-master.conf.jinja
   - template: jinja
   - mode: 644
   - user: root
   - group: root
   - context:
     mcast_join: localhost

copy_apache_conf:
  cmd.run:
  - name: cp /etc/ganglia-webfrontend/apache.conf /etc/apache2/sites-enabled/ganglia.conf

restart_apache:
  cmd.run:
  - name: service apache2 restart

restart_gmetad:
  cmd.run:
  - name: service gmetad restart

restart_ganglia_monitor_master:
  cmd.run:
  - name: service ganglia-monitor restart

{% else%}

/etc/ganglia/gmond.conf:
  file.managed:
   - source: salt://ganglia/files/gmond-default-slave.conf.jinja
   - template: jinja
   - user: root
   - group: root
   - context:
     mcast_join: 192.168.220.129

wait_60:
  cmd.run:
  - name: sleep 60

restart_ganglia_monitor:
  cmd.run:
  - name: service ganglia-monitor restart
{% endif %}

