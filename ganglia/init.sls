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
   - source: /srv/salt/formulas/ganglia-formula/ganglia/files/gmond-default.conf.jinja:
   - template: jinja
   - mode: 644
   - user: root
   - group: root
   - context:
     mcast_join: localhost

#restart ganglia-monitor
ganglia-monitor:
  service.running:
    - enable: True
    - reload: True
    - init_delay: 60
{% else%}

#configure gmond.conf
/etc/ganglia/gmond.conf:
  file.managed:
   - name: 
   - source: /srv/salt/formulas/ganglia-formula/ganglia/files/gmond-default.conf.jinja:
   - template: jinja
   - user: root
   - group: root
   - context:
     mcast_join: hs-master

#restart ganglia-monitor
ganglia-monitor:
  service.running:
    - enable: True
    - reload: True
{% endif %}

