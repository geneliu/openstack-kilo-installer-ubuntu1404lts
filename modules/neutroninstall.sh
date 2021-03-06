#!/bin/bash
#
# Unattended/SemiAutomatted OpenStack Installer
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
# OpenStack KILO for Ubuntu 14.04lts
#
#

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

#
# First, we source our config file and verify that some important proccess are 
# already completed.
#

#
# NOTE: Neutron and Nova are the most difficult and long to install from all OpenStack
# components. Don't be surprised by all the comments we have here documented in the
# installer code
#

if [ -f ./configs/main-config.rc ]
then
	source ./configs/main-config.rc
	mkdir -p /etc/openstack-control-script-config
else
	echo "Can't access my config file. Aborting !"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/db-installed ]
then
	echo ""
	echo "DB Proccess OK. Let's continue"
	echo ""
else
	echo ""
	echo "DB Proccess not completed. Aborting !"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/keystone-installed ]
then
	echo ""
	echo "Keystone Proccess OK. Let's continue"
	echo ""
else
	echo ""
	echo "Keystone Proccess not completed. Let's continue"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/neutron-installed ]
then
	echo ""
	echo "This module was already completed. Exiting !"
	echo ""
	exit 0
fi

echo "Installing NEUTRON packages"

#
# We do some preseeding, but we are going to install in non-interactive mode
#

echo "keystone keystone/auth-token password $SERVICE_TOKEN" > /tmp/keystone-seed.txt
echo "keystone keystone/admin-password password $keystoneadminpass" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-password-confirm password $keystoneadminpass" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-user string admin" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-tenant-name string $keystoneadminuser" >> /tmp/keystone-seed.txt
echo "keystone keystone/region-name string $endpointsregion" >> /tmp/keystone-seed.txt
echo "keystone keystone/endpoint-ip string $keystonehost" >> /tmp/keystone-seed.txt
echo "keystone keystone/register-endpoint boolean false" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-email string $keystoneadminuseremail" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-role-name string $keystoneadmintenant" >> /tmp/keystone-seed.txt
echo "keystone keystone/configure_db boolean false" >> /tmp/keystone-seed.txt
echo "keystone keystone/create-admin-tenant boolean false" >> /tmp/keystone-seed.txt

debconf-set-selections /tmp/keystone-seed.txt

echo "glance-common glance/admin-password password $glancepass" > /tmp/glance-seed.txt
echo "glance-common glance/auth-host string $keystonehost" >> /tmp/glance-seed.txt
echo "glance-api glance/keystone-ip string $keystonehost" >> /tmp/glance-seed.txt
echo "glance-common glance/paste-flavor select keystone" >> /tmp/glance-seed.txt
echo "glance-common glance/admin-tenant-name string $keystoneadmintenant" >> /tmp/glance-seed.txt
echo "glance-api glance/endpoint-ip string $glancehost" >> /tmp/glance-seed.txt
echo "glance-api glance/region-name string $endpointsregion" >> /tmp/glance-seed.txt
echo "glance-api glance/register-endpoint boolean false" >> /tmp/glance-seed.txt
echo "glance-common glance/admin-user	string $keystoneadminuser" >> /tmp/glance-seed.txt
echo "glance-common glance/configure_db boolean false" >> /tmp/glance-seed.txt
echo "glance-common glance/rabbit_host string $messagebrokerhost" >> /tmp/glance-seed.txt
echo "glance-common glance/rabbit_password password $brokerpass" >> /tmp/glance-seed.txt
echo "glance-common glance/rabbit_userid string $brokeruser" >> /tmp/glance-seed.txt

debconf-set-selections /tmp/glance-seed.txt

echo "cinder-common cinder/admin-password password $cinderpass" > /tmp/cinder-seed.txt
echo "cinder-api cinder/region-name string $endpointsregion" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/configure_db boolean false" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/admin-tenant-name string $keystoneadmintenant" >> /tmp/cinder-seed.txt
echo "cinder-api cinder/register-endpoint boolean false" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/auth-host string $keystonehost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/start_services boolean false" >> /tmp/cinder-seed.txt
echo "cinder-api cinder/endpoint-ip string $cinderhost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/volume_group string cinder-volumes" >> /tmp/cinder-seed.txt
echo "cinder-api cinder/keystone-ip string $keystonehost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/admin-user string $keystoneadminuser" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/rabbit_password password $brokerpass" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/rabbit_host string $messagebrokerhost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/rabbit_userid string $brokeruser" >> /tmp/cinder-seed.txt

debconf-set-selections /tmp/cinder-seed.txt

echo "neutron-common neutron/admin-password password $keystoneadminpass" > /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/admin-password password $keystoneadminpass" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/keystone-ip string $keystonehost" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/local_ip string $neutron_computehost" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/configure_db boolean false" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/region-name string $endpointsregion" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/region-name string $endpointsregion" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/register-endpoint boolean false" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/tenant_network_type select vlan" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/admin-user string $keystoneadminuser" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/admin-user string $keystoneadminuser" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/tunnel_id_ranges string 0" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/enable_tunneling boolean false" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/auth-host string $keystonehost" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/auth-host string $keystonehost" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/endpoint-ip string $neutronhost" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/admin-tenant-name string $keystoneadmintenant" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/admin-tenant-name string $keystoneadmintenant" >> /tmp/neutron-seed.txt
echo "openswan openswan/install_x509_certificate boolean false" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/rabbit_password password $brokerpass" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/rabbit_userid string $brokeruser" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/rabbit_host string $messagebrokerhost" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/tunnel_id_ranges string 1" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/tenant_network_type select vlan" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/enable_tunneling boolean false" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/configure_db boolean false" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/plugin-select select ml2" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/local_ip string $neutron_computehost" >> /tmp/neutron-seed.txt


debconf-set-selections /tmp/neutron-seed.txt

#
# First, we install Neutron Packages, including the optional ones (controlled
# by it's own variables from the main config file)
#
# Non Interactive mode !!
#
# The actual packages installed depends of the installation mode. If we are deploying
# a controller or a compute node, the package list changes !.
#

export DEBIAN_FRONTEND=noninteractive

echo ""

if [ $neutron_in_compute_node == "yes" ]
then
	DEBIAN_FRONTEND=noninteractive aptitude -y install neutron-common \
		python-neutron \
		python-neutronclient \
		neutron-plugin-openvswitch-agent \
		neutron-plugin-ml2 \
		ipset
else
	echo "Installing haproxy"
	DEBIAN_FRONTEND=noninteractive aptitude -y install haproxy

	DEBIAN_FRONTEND=noninteractive aptitude -y install neutron-server \
		neutron-common neutron-dhcp-agent \
		neutron-l3-agent neutron-lbaas-agent \
		neutron-metadata-agent python-neutron \
		python-neutronclient \
		neutron-plugin-openvswitch-agent \
		neutron-plugin-ml2 \
		ipset \
		neutron-lbaas-agent \
		python-neutron-lbaas \
		python-neutron-fwaas
		

	echo NEUTRON_PLUGIN_CONFIG=\"/etc/neutron/plugins/ml2/ml2_conf.ini\" > /etc/default/neutron-server


	if [ $vpnaasinstall == "yes" ]
	then
		DEBIAN_FRONTEND=noninteractive aptitude -y install neutron-vpn-agent \
			openswan \
			openswan-modules-dkms \
			python-neutron-vpnaas
	fi

	if [ $neutronmetering == "yes" ]
	then
		DEBIAN_FRONTEND=noninteractive aptitude -y install neutron-metering-agent
	fi
fi

echo ""
echo "Done"

echo ""
echo "Configuring Neutron"

#
# We are not sure if this is still needed in KILO ubuntu packages, but just in case....
#

echo NEUTRON_PLUGIN_CONFIG=\"/etc/neutron/plugins/ml2/ml2_conf.ini\" > /etc/default/neutron-server

#
# We create the plugin symlink to ml2 config
#

ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

rm -f /tmp/neutron-seed.txt
rm -f /tmp/cinder-seed.txt
rm -f /tmp/glance-seed.txt
rm -f /tmp/keystone-seed.txt

if [ $neutron_in_compute_node == "yes" ]
then
	stop neutron-plugin-openvswitch-agent > /dev/null 2>&1
	stop neutron-plugin-openvswitch-agent > /dev/null 2>&1
else
	stop neutron-plugin-openvswitch-agent > /dev/null 2>&1
	stop neutron-plugin-openvswitch-agent > /dev/null 2>&1
	stop neutron-dhcp-agent > /dev/null 2>&1
	stop neutron-dhcp-agent > /dev/null 2>&1
	stop neutron-lbaas-agent > /dev/null 2>&1
	stop neutron-lbaas-agent > /dev/null 2>&1
	stop neutron-metadata-agent > /dev/null 2>&1
	stop neutron-metadata-agent > /dev/null 2>&1
	stop neutron-l3-agent > /dev/null 2>&1
	stop neutron-l3-agent > /dev/null 2>&1
	stop neutron-server > /dev/null 2>&1
	stop neutron-server > /dev/null 2>&1
	if [ $vpnaasinstall == "yes" ]
	then
		stop neutron-vpn-agent > /dev/null 2>&1
		stop neutron-vpn-agent > /dev/null 2>&1
	fi
	if [ $neutronmetering == "yes" ]
	then
		stop neutron-metering-agent > /dev/null 2>&1
		stop neutron-metering-agent > /dev/null 2>&1
	fi
fi

echo "Initial config done"

#
# We install a custom DNSMASQ file with samples that are described in our main README.
# Also we ensure "dhcp-option" as required by Neutron DHCP Service
#

#
# DNSMASQ is installed ONLY if we are installing a Neutron Server in a Controller server,
# Network Node or ALL-IN-ONE Server
#


if [ $neutron_in_compute_node == "no" ]
then
	echo ""
	echo "Configuring DNSMASQ"

	sleep 5
	cat /etc/dnsmasq.conf > $dnsmasq_config_file
	mkdir -p /etc/dnsmasq-neutron.d
	echo "user=neutron" >> $dnsmasq_config_file
	echo "group=neutron" >> $dnsmasq_config_file
	echo "dhcp-option-force=26,1454" >> $dnsmasq_config_file
	echo "conf-dir=/etc/dnsmasq-neutron.d" >> $dnsmasq_config_file
	echo "# Extra options for Neutron-DNSMASQ" > /etc/dnsmasq-neutron.d/neutron-dnsmasq-extra.conf
	echo "# Samples:" >> /etc/dnsmasq-neutron.d/neutron-dnsmasq-extra.conf
	echo "# dhcp-option=option:ntp-server,192.168.1.1" >> /etc/dnsmasq-neutron.d/neutron-dnsmasq-extra.conf
	echo "# dhcp-option = tag:tag0, option:ntp-server, 192.168.1.1" >> /etc/dnsmasq-neutron.d/neutron-dnsmasq-extra.conf
	echo "# dhcp-option = tag:tag1, option:ntp-server, 192.168.1.1" >> /etc/dnsmasq-neutron.d/neutron-dnsmasq-extra.conf
	echo "# expand-hosts"  >> /etc/dnsmasq-neutron.d/neutron-dnsmasq-extra.conf
	echo "# domain=dominio-interno-uno.home,192.168.1.0/24"  >> /etc/dnsmasq-neutron.d/neutron-dnsmasq-extra.conf
	echo "# domain=dominio-interno-dos.home,192.168.100.0/24"  >> /etc/dnsmasq-neutron.d/neutron-dnsmasq-extra.conf
	sync
	sleep 5

	echo "Done"
	echo ""
fi

source $keystone_admin_rc_file

#
# We apply IPTABLES rules, then begin neutron configuration
#

echo ""
echo "Applying IPTABLES rules"
iptables -A INPUT -p tcp -m multiport --dports 9696 -j ACCEPT
iptables -A INPUT -p udp -m state --state NEW -m udp --dport 67 -j ACCEPT
iptables -A INPUT -p udp -m state --state NEW -m udp --dport 68 -j ACCEPT
iptables -t mangle -A POSTROUTING -p udp -m udp --dport 67 -j CHECKSUM --checksum-fill
iptables -t mangle -A POSTROUTING -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill
/etc/init.d/iptables-persistent save
echo "Done"

echo ""
echo "Configuring Neutron"

sync
sleep 5
sync

echo "#" >> /etc/neutron/neutron.conf

#
# Neutron Main Parameters
#

crudini --set /etc/neutron/neutron.conf DEFAULT debug False
crudini --set /etc/neutron/neutron.conf DEFAULT verbose False
crudini --set /etc/neutron/neutron.conf DEFAULT log_dir /var/log/neutron
crudini --set /etc/neutron/neutron.conf DEFAULT bind_host 0.0.0.0
crudini --set /etc/neutron/neutron.conf DEFAULT bind_port 9696
crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
# Just in case....
# crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin neutron.plugins.ml2.plugin.Ml2Plugin
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
crudini --set /etc/neutron/neutron.conf DEFAULT base_mac "$basemacspec"
crudini --set /etc/neutron/neutron.conf DEFAULT mac_generation_retries 16
crudini --set /etc/neutron/neutron.conf DEFAULT dhcp_lease_duration $dhcp_lease_duration
crudini --set /etc/neutron/neutron.conf DEFAULT allow_bulk True
crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips False
crudini --set /etc/neutron/neutron.conf DEFAULT control_exchange neutron
crudini --set /etc/neutron/neutron.conf DEFAULT default_notification_level INFO
crudini --set /etc/neutron/neutron.conf DEFAULT notification_topics notifications
crudini --set /etc/neutron/neutron.conf DEFAULT state_path /var/lib/neutron
crudini --set /etc/neutron/neutron.conf DEFAULT lock_path /var/lib/neutron/lock
 
 
mkdir -p /var/lib/neutron/lock
chown neutron.neutron /var/lib/neutron/lock
 
crudini --set /etc/neutron/neutron.conf DEFAULT api_paste_config api-paste.ini

#
# Neutron message broker config - we configure according to the flavor selected in the main config
#
 
case $brokerflavor in
"qpid")
	# crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend neutron.openstack.common.rpc.impl_qpid
	crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend qpid
	crudini --set /etc/neutron/neutron.conf DEFAULT qpid_hostname $messagebrokerhost
	crudini --set /etc/neutron/neutron.conf DEFAULT qpid_port 5672
	crudini --set /etc/neutron/neutron.conf DEFAULT qpid_username $brokeruser
	crudini --set /etc/neutron/neutron.conf DEFAULT qpid_password $brokerpass
	crudini --set /etc/neutron/neutron.conf DEFAULT qpid_heartbeat 60
	crudini --set /etc/neutron/neutron.conf DEFAULT qpid_protocol tcp
	crudini --set /etc/neutron/neutron.conf DEFAULT qpid_tcp_nodelay True
	crudini --set /etc/neutron/neutron.conf DEFAULT notification_driver neutron.openstack.common.notifier.rpc_notifier
	crudini --set /etc/neutron/neutron.conf oslo_messaging_qpid qpid_hostname $messagebrokerhost
	crudini --set /etc/neutron/neutron.conf oslo_messaging_qpid qpid_port 5672
	crudini --set /etc/neutron/neutron.conf oslo_messaging_qpid qpid_username $brokeruser
	crudini --set /etc/neutron/neutron.conf oslo_messaging_qpid qpid_password $brokerpass
	crudini --set /etc/neutron/neutron.conf oslo_messaging_qpid qpid_heartbeat 60
	crudini --set /etc/neutron/neutron.conf oslo_messaging_qpid qpid_protocol tcp
	crudini --set /etc/neutron/neutron.conf oslo_messaging_qpid qpid_tcp_nodelay True
	;;
 
"rabbitmq")
	# crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend neutron.openstack.common.rpc.impl_kombu
	crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_host $messagebrokerhost
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_password $brokerpass
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_userid $brokeruser
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_port 5672
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_use_ssl false
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_virtual_host $brokervhost
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_max_retries 0
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_retry_interval 1
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_ha_queues false
	crudini --set /etc/neutron/neutron.conf DEFAULT notification_driver neutron.openstack.common.notifier.rpc_notifier
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host $messagebrokerhost
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password $brokerpass
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid $brokeruser
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_port 5672
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_use_ssl false
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_virtual_host $brokervhost
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_max_retries 0
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_retry_interval 1
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_ha_queues false
	;;
esac

#
# Sudo Wrapper
#
crudini --set /etc/neutron/neutron.conf agent root_helper "sudo neutron-rootwrap /etc/neutron/rootwrap.conf"

#
# Neutron Keystone Config
#
 
# crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_host $keystonehost
# crudini --set /etc/neutron/neutron.conf keystone_authtoken admin_tenant_name $keystoneservicestenant
# crudini --set /etc/neutron/neutron.conf keystone_authtoken admin_user $neutronuser
# crudini --set /etc/neutron/neutron.conf keystone_authtoken admin_password $neutronpass
# crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_port 35357
# crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_protocol http
# crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri http://$keystonehost:5000/v2.0
# crudini --set /etc/neutron/neutron.conf keystone_authtoken identity_uri http://$keystonehost:35357
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri http://$keystonehost:5000
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://$keystonehost:35357
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_plugin password
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_id default
crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_id default
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name $keystoneservicestenant
crudini --set /etc/neutron/neutron.conf keystone_authtoken username $neutronuser
crudini --set /etc/neutron/neutron.conf keystone_authtoken password $neutronpass
 
crudini --set /etc/neutron/neutron.conf DEFAULT agent_down_time 60
crudini --set /etc/neutron/neutron.conf DEFAULT dhcp_agents_per_network 1
crudini --set /etc/neutron/neutron.conf DEFAULT dhcp_agent_notification True
 
 
nova_admin_tenant_id=`keystone tenant-get $keystoneservicestenant|grep "id"|awk '{print $4}'`
 
crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes True
crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes True
crudini --set /etc/neutron/neutron.conf DEFAULT nova_url http://$novahost:8774/v2
crudini --set /etc/neutron/neutron.conf DEFAULT nova_admin_username $novauser
crudini --set /etc/neutron/neutron.conf DEFAULT nova_admin_tenant_id $nova_admin_tenant_id
crudini --set /etc/neutron/neutron.conf DEFAULT nova_admin_password $novapass
crudini --set /etc/neutron/neutron.conf DEFAULT nova_admin_auth_url http://$keystonehost:35357/v2.0
crudini --set /etc/neutron/neutron.conf DEFAULT report_interval 20
crudini --set /etc/neutron/neutron.conf DEFAULT notification_driver neutron.openstack.common.notifier.rpc_notifier
crudini --set /etc/neutron/neutron.conf DEFAULT api_workers 0

crudini --set /etc/neutron/neutron.conf nova region_name $endpointsregion
crudini --set /etc/neutron/neutron.conf nova auth_url http://$keystonehost:35357
crudini --set /etc/neutron/neutron.conf nova auth_plugin password
crudini --set /etc/neutron/neutron.conf nova project_domain_id default
crudini --set /etc/neutron/neutron.conf nova user_domain_id default
crudini --set /etc/neutron/neutron.conf nova region_name $endpointsregion
crudini --set /etc/neutron/neutron.conf nova project_name $keystoneservicestenant
crudini --set /etc/neutron/neutron.conf nova username $novauser
crudini --set /etc/neutron/neutron.conf nova password $novapass

#
# Neutron Service Plugins
#

if [ $neutronmetering == "yes" ]
then
	thirdplugin=",metering"
else
	thirdplugin=""
fi
 
if [ $vpnaasinstall == "yes" ]
then
	crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins "router,firewall,lbaas,vpnaas$thirdplugin"
else
	crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins "router,firewall,lbaas$thirdplugin"
fi

#
# VPNaaS, FWaaS and Metering Agent Configuration
#
 
echo "#" >> /etc/neutron/fwaas_driver.ini
 
crudini --set /etc/neutron/fwaas_driver.ini fwaas driver "neutron_fwaas.services.firewall.drivers.linux.iptables_fwaas.IptablesFwaasDriver"
crudini --set /etc/neutron/fwaas_driver.ini fwaas enabled True
 
if [ $vpnaasinstall == "yes" ]
then
	echo "#" >> /etc/neutron/vpn_agent.ini
	crudini --set /etc/neutron/vpn_agent.ini DEFAULT debug False
	crudini --set /etc/neutron/vpn_agent.ini DEFAULT interface_driver "neutron.agent.linux.interface.OVSInterfaceDriver"
	crudini --set /etc/neutron/vpn_agent.ini DEFAULT ovs_use_veth True
	crudini --set /etc/neutron/vpn_agent.ini DEFAULT use_namespaces True
	crudini --set /etc/neutron/vpn_agent.ini DEFAULT external_network_bridge ""
	crudini --set /etc/neutron/vpn_agent.ini vpnagent vpn_device_driver "neutron_vpnaas.services.vpn.device_drivers.ipsec.OpenSwanDriver"
	crudini --set /etc/neutron/vpn_agent.ini ipsec ipsec_status_check_interval 60
fi
 
if [ $neutronmetering == "yes" ]
then
	echo "#" >> /etc/neutron/metering_agent.ini
	crudini --set /etc/neutron/metering_agent.ini DEFAULT debug False
	crudini --set /etc/neutron/metering_agent.ini DEFAULT ovs_use_veth True
	crudini --set /etc/neutron/metering_agent.ini DEFAULT use_namespaces True
	crudini --set /etc/neutron/metering_agent.ini DEFAULT driver neutron.services.metering.drivers.iptables.iptables_driver.IptablesMeteringDriver
	crudini --set /etc/neutron/metering_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
	crudini --set /etc/neutron/metering_agent.ini DEFAULT measure_interval 30
	crudini --set /etc/neutron/metering_agent.ini DEFAULT report_interval 300
fi

#
# L3 Agent Configuration
#
 
echo "#" >> /etc/neutron/l3_agent.ini
 
crudini --set /etc/neutron/l3_agent.ini DEFAULT debug False
crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/l3_agent.ini DEFAULT ovs_use_veth True
crudini --set /etc/neutron/l3_agent.ini DEFAULT use_namespaces True
crudini --set /etc/neutron/l3_agent.ini DEFAULT handle_internal_only_routers True
crudini --set /etc/neutron/l3_agent.ini DEFAULT send_arp_for_ha 3
crudini --set /etc/neutron/l3_agent.ini DEFAULT periodic_interval 40
crudini --set /etc/neutron/l3_agent.ini DEFAULT periodic_fuzzy_delay 5
crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge ""
crudini --set /etc/neutron/l3_agent.ini DEFAULT metadata_port 9697
crudini --set /etc/neutron/l3_agent.ini DEFAULT enable_metadata_proxy True
crudini --set /etc/neutron/l3_agent.ini DEFAULT router_delete_namespaces True
 
sync
sleep 2
sync

#
# DHCP Agent Configuration
#
 
echo "#" >> /etc/neutron/dhcp_agent.ini
 
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT debug False
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT resync_interval 30
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT ovs_use_veth True
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT ovs_integration_bridge $integration_bridge
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT use_namespaces True
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT state_path /var/lib/neutron
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dnsmasq_config_file $dnsmasq_config_file
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_domain $dhcp_domain
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_delete_namespaces True
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT root_helper "sudo neutron-rootwrap /etc/neutron/rootwrap.conf"
 
sync
sleep 2
sync

#
# Neutron Database configured according to selected flavor in main config
#
 
case $dbflavor in
"mysql")
	crudini --set /etc/neutron/neutron.conf database connection mysql://$neutrondbuser:$neutrondbpass@$dbbackendhost:$mysqldbport/$neutrondbname
	;;
"postgres")
	crudini --set /etc/neutron/neutron.conf database connection postgresql://$neutrondbuser:$neutrondbpass@$dbbackendhost:$psqldbport/$neutrondbname
	;;
esac
 
crudini --set /etc/neutron/neutron.conf database retry_interval 10
crudini --set /etc/neutron/neutron.conf database idle_timeout 3600

#
# ML2 Plugin Configuration
#
 
echo "#" >> /etc/neutron/plugins/ml2/ml2_conf.ini
 
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers "local,flat"
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers "openvswitch,l2population"
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types "flat"
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks "*"
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_security_group True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset True
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs enable_tunneling False
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs network_vlan_ranges $network_vlan_ranges
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs local_ip $neutron_computehost
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini ovs bridge_mappings $bridge_mappings

#
# Database Flavor in ML2 Plugin configured according to selected flavor in main config
#

case $dbflavor in
"mysql")
	crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini database connection mysql://$neutrondbuser:$neutrondbpass@$dbbackendhost:$mysqldbport/$neutrondbname
	;;
"postgres")
	crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini database connection postgresql://$neutrondbuser:$neutrondbpass@$dbbackendhost:$psqldbport/$neutrondbname
	;;
esac

#
# More database related settings for both neutron server and ml2 plugin
#

crudini --set /etc/neutron/neutron.conf database retry_interval 10
crudini --set /etc/neutron/neutron.conf database idle_timeout 3600
crudini --set /etc/neutron/neutron.conf database min_pool_size 1
crudini --set /etc/neutron/neutron.conf database max_pool_size 10
crudini --set /etc/neutron/neutron.conf database max_retries 100
crudini --set /etc/neutron/neutron.conf database pool_timeout 10

crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini database retry_interval 10
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini database idle_timeout 3600
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini database min_pool_size 1
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini database max_pool_size 10
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini database max_retries 100
crudini --set /etc/neutron/plugins/ml2/ml2_conf.ini database pool_timeout 10
 
sync
sleep 2
sync

#
# The plugin SymLink
#

ln -f -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

#
# api-paste and metadata agent configuration
#

echo "#" >> /etc/neutron/metadata_agent.ini
# echo "#" >> /etc/neutron/api-paste.ini
 
# crudini --set /etc/neutron/api-paste.ini filter:authtoken paste.filter_factory "keystonemiddleware.auth_token:filter_factory"
# crudini --set /etc/neutron/api-paste.ini filter:authtoken auth_protocol http
# crudini --set /etc/neutron/api-paste.ini filter:authtoken auth_host $keystonehost
# crudini --set /etc/neutron/api-paste.ini filter:authtoken admin_tenant_name $keystoneservicestenant
# crudini --set /etc/neutron/api-paste.ini filter:authtoken admin_user $neutronuser
# crudini --set /etc/neutron/api-paste.ini filter:authtoken admin_password $neutronpass
# crudini --set /etc/neutron/api-paste.ini filter:authtoken auth_port 35357
# crudini --set /etc/neutron/api-paste.ini filter:authtoken auth_uri http://$keystonehost:5000/v2.0/
# crudini --set /etc/neutron/api-paste.ini filter:authtoken identity_uri http://$keystonehost:35357
 
crudini --set /etc/neutron/metadata_agent.ini DEFAULT debug False
# crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_url "http://$keystonehost:35357/v2.0"
crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_region $endpointsregion
crudini --set /etc/neutron/metadata_agent.ini DEFAULT admin_tenant_name $keystoneservicestenant
crudini --set /etc/neutron/metadata_agent.ini DEFAULT admin_user $neutronuser
crudini --set /etc/neutron/metadata_agent.ini DEFAULT admin_password $neutronpass
crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_ip $novahost
crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_port 8775
crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret $metadata_shared_secret

crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_uri "http://$keystonehost:5000"
crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_url "http://$keystonehost:35357"
crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_plugin password
crudini --set /etc/neutron/metadata_agent.ini DEFAULT project_domain_id default
crudini --set /etc/neutron/metadata_agent.ini DEFAULT user_domain_id default
crudini --set /etc/neutron/metadata_agent.ini DEFAULT project_name $keystoneservicestenant
crudini --set /etc/neutron/metadata_agent.ini DEFAULT username $neutronuser
crudini --set /etc/neutron/metadata_agent.ini DEFAULT password $neutronpass
 
sync
sleep 2
sync

#
# LBaaS configuration
#
 
echo "#" >> /etc/neutron/lbaas_agent.ini
echo "#" >> /etc/neutron/neutron_lbaas.conf
 
crudini --set /etc/neutron/lbaas_agent.ini DEFAULT periodic_interval 10
crudini --set /etc/neutron/lbaas_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/lbaas_agent.ini DEFAULT ovs_use_veth True
crudini --set /etc/neutron/lbaas_agent.ini DEFAULT device_driver neutron.services.loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver
crudini --set /etc/neutron/lbaas_agent.ini DEFAULT use_namespaces True
crudini --set /etc/neutron/lbaas_agent.ini haproxy user_group neutron
crudini --set /etc/neutron/lbaas_agent.ini haproxy user_group send_gratuitous_arp 3

crudini --set /etc/neutron/neutron_lbaas.conf service_providers service_provider "LOADBALANCER:Haproxy:neutron_lbaas.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default"

chown neutron.neutron /etc/neutron/neutron_lbaas.conf

sync
sleep 2
sync
 
mkdir -p /etc/neutron/plugins/services/agent_loadbalancer
cp -v /etc/neutron/lbaas_agent.ini /etc/neutron/plugins/services/agent_loadbalancer/
chown root.neutron /etc/neutron/plugins/services/agent_loadbalancer/lbaas_agent.ini
sync
 
sync
sleep 5
sync

#
# We paranoically re-re-re-configure again the message broker in main neutron service file
#
 
case $brokerflavor in
"qpid")
	# crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend neutron.openstack.common.rpc.impl_qpid
	crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend qpid
	crudini --set /etc/neutron/neutron.conf DEFAULT qpid_hostname $messagebrokerhost
	crudini --set /etc/neutron/neutron.conf DEFAULT qpid_port 5672
	crudini --set /etc/neutron/neutron.conf DEFAULT qpid_username $brokeruser
	crudini --set /etc/neutron/neutron.conf DEFAULT qpid_password $brokerpass
	crudini --set /etc/neutron/neutron.conf DEFAULT qpid_heartbeat 60
	crudini --set /etc/neutron/neutron.conf DEFAULT qpid_protocol tcp
	crudini --set /etc/neutron/neutron.conf DEFAULT qpid_tcp_nodelay True
	crudini --set /etc/neutron/neutron.conf DEFAULT notification_driver neutron.openstack.common.notifier.rpc_notifier
	crudini --set /etc/neutron/neutron.conf oslo_messaging_qpid qpid_hostname $messagebrokerhost
	crudini --set /etc/neutron/neutron.conf oslo_messaging_qpid qpid_port 5672
	crudini --set /etc/neutron/neutron.conf oslo_messaging_qpid qpid_username $brokeruser
	crudini --set /etc/neutron/neutron.conf oslo_messaging_qpid qpid_password $brokerpass
	crudini --set /etc/neutron/neutron.conf oslo_messaging_qpid qpid_heartbeat 60
	crudini --set /etc/neutron/neutron.conf oslo_messaging_qpid qpid_protocol tcp
	crudini --set /etc/neutron/neutron.conf oslo_messaging_qpid qpid_tcp_nodelay True
	;;
 
"rabbitmq")
	# crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend neutron.openstack.common.rpc.impl_kombu
	crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_host $messagebrokerhost
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_password $brokerpass
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_userid $brokeruser
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_port 5672
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_use_ssl false
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_virtual_host $brokervhost
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_max_retries 0
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_retry_interval 1
	crudini --set /etc/neutron/neutron.conf DEFAULT rabbit_ha_queues false
	crudini --set /etc/neutron/neutron.conf DEFAULT notification_driver neutron.openstack.common.notifier.rpc_notifier
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host $messagebrokerhost
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password $brokerpass
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid $brokeruser
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_port 5672
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_use_ssl false
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_virtual_host $brokervhost
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_max_retries 0
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_retry_interval 1
	crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_ha_queues false
	;;
esac
 
 
sync
sleep 2
sync
 
echo ""
echo "Done"
echo ""

rm -f /var/lib/neutron/neutron.sqlite

echo ""
echo "Provisioning NEUTRON Database"
echo ""

#
# Then we provision/update Neutron database
#

su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
        --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade kilo" neutron


sync
sleep 2
sync
 
echo ""
echo "Done"
echo ""

#
# Time to start and enable all services. We enable/start the right services for the right case (controller or compute)
#

echo "Starting Neutron"
 
if [ $neutron_in_compute_node == "yes" ]
then
	stop neutron-server
	echo 'manual' > /etc/init/neutron-server.override

	stop neutron-dhcp-agent
	echo 'manual' > /etc/init/neutron-dhcp-agent.override

	stop neutron-l3-agent
	echo 'manual' > /etc/init/neutron-l3-agent.override

	stop neutron-lbaas-agent
	echo 'manual' > /etc/init/neutron-lbaas-agent.override

	stop neutron-metadata-agent
	echo 'manual' > /etc/init/neutron-metadata-agent.override

        if [ $vpnaasinstall == "yes" ]
        then
                stop neutron-vpn-agent
		echo 'manual' > /etc/init/neutron-vpn-agent.override
        fi

	if [ $neutronmetering == "yes" ]
	then
		stop neutron-metering-agent
		echo 'manual' > /etc/init/neutron-metering-agent.override
	fi

	start neutron-plugin-openvswitch-agent
else
	start neutron-server

	start neutron-dhcp-agent

	start neutron-l3-agent

	start neutron-lbaas-agent

	start neutron-metadata-agent


        if [ $vpnaasinstall == "yes" ]
        then
                start neutron-vpn-agent
        fi

	if [ $neutronmetering == "yes" ]
	then
		start neutron-metering-agent
	fi

	start neutron-plugin-openvswitch-agent
fi

echo "Done"

#
# Probably you already noted we use a lot of sleeps and syncs. This is do it that way in order to ensure services
# stabilization, specially in not-so-high-end machines.
#

echo ""
echo "Sleeping 10 seconds"
sync
sleep 10
sync
echo ""
echo "Let's continue"
echo ""

#
# Here, we create Neutron Networks, but only if we configured our main config to do it.
#

if [ $neutron_in_compute_node == "no" ]
then
	if [ $network_create == "yes" ]
	then
		source $keystone_admin_rc_file

		for MyNet in $network_create_list
		do
			echo ""
			echo "Creating network $MyNet"
			neutron net-create $MyNet --shared --provider:network_type flat --provider:physical_network $MyNet
			echo ""
			echo "Network $MyNet created !"
			echo ""
		done
	fi
fi

#
# Another 10 seconds wait time.
#

echo ""
echo "Sleeping 10 seconds"
echo ""
sync
sleep 10
sync
/etc/init.d/iptables-persistent save

echo "Let's continue"

#
# Finally, we do a simple test in order to check if our Neutron Service was correctly
# installed. If it not, we fail and make a full stop in our installation script.
#

testneutron=`dpkg -l neutron-common 2>/dev/null|tail -n 1|grep -ci ^ii`
if [ $testneutron == "0" ]
then
	echo ""
	echo "Neutron Installation FAILED. Aborting !"
	echo ""
	exit 0
else
	date > /etc/openstack-control-script-config/neutron-installed
	date > /etc/openstack-control-script-config/neutron
	if [ $neutron_in_compute_node == "no" ]
	then
		date > /etc/openstack-control-script-config/neutron-full-installed
                if [ $vpnaasinstall == "yes" ]
                then
                        date > /etc/openstack-control-script-config/neutron-full-installed-vpnaas
                fi
		if [ $neutronmetering == "yes" ]
		then
			date > /etc/openstack-control-script-config/neutron-full-installed-metering
		fi
	fi
fi

echo ""
echo "Neutron Installed and Configured"
echo ""


