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
	echo "Keystone Proccess not completed. Aborting !"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/nova-installed ]
then
	echo ""
	echo "This module was already completed. Exiting !"
	echo ""
	exit 0
fi

#
# We install nova packages depending of our selections in the main config file. Some packages are
# for compute nodes, other are for nova servers, all-in-one or controllers.
#

echo ""
echo "Installing NOVA Packages"

#
# We do some preseeding here. Anyway, we are installing non-interactive mode
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
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/local_ip string $neutronhost" >> /tmp/neutron-seed.txt
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
echo "neutron-common neutron/plugin-select select OpenVSwitch" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/local_ip string $neutronhost" >> /tmp/neutron-seed.txt

debconf-set-selections /tmp/neutron-seed.txt

echo "nova-common nova/admin-password password $keystoneadminpass" > /tmp/nova-seed.txt
echo "nova-common nova/configure_db boolean false" >> /tmp/nova-seed.txt
echo "nova-consoleproxy nova-consoleproxy/daemon_type select spicehtml5" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit-host string 127.0.0.1" >> /tmp/nova-seed.txt
echo "nova-api nova/register-endpoint boolean false" >> /tmp/nova-seed.txt
echo "nova-common nova/my-ip string $novahost" >> /tmp/nova-seed.txt
echo "nova-common nova/start_services boolean false" >> /tmp/nova-seed.txt
echo "nova-common nova/admin-user string $keystoneadminuser" >> /tmp/nova-seed.txt
echo "nova-api nova/region-name string $endpointsregion" >> /tmp/nova-seed.txt
echo "nova-common nova/admin-tenant-name string $keystoneadmintenant" >> /tmp/nova-seed.txt
echo "nova-api nova/endpoint-ip string $novahost" >> /tmp/nova-seed.txt
echo "nova-api nova/keystone-ip string $keystonehost" >> /tmp/nova-seed.txt
echo "nova-common nova/active-api multiselect ec2, osapi_compute, metadata" >> /tmp/nova-seed.txt
echo "nova-common nova/auth-host string $keystonehost" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit_host string $messagebrokerhost" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit_password password $brokerpass" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit_userid string $brokeruser" >> /tmp/nova-seed.txt
echo "nova-common nova/neutron_url string http://$neutronhost:9696" >> /tmp/nova-seed.txt
echo "nova-common nova/neutron_admin_password password $neutronpass" >> /tmp/nova-seed.txt

debconf-set-selections /tmp/nova-seed.txt

export DEBIAN_FRONTEND=noninteractive

#
# Here we verify if this server supports KVM or not
#
kvm_possible=`grep -E 'svm|vmx' /proc/cpuinfo|uniq|wc -l`

if [ $kvm_possible == "0" ]
then
	nova_kvm_or_qemu="nova-compute-qemu"
else
	nova_kvm_or_qemu="nova-compute-kvm"
fi

#
# Depending on our selection about the console flavor, we install either novnc or spicehtml5
#

case $consoleflavor in
"spice")
	consolepackage="nova-spiceproxy"
	consolesvc="nova-spiceproxy"
	;;
"vnc")
	consolepackage="nova-novncproxy"
	consolesvc="nova-novncproxy"
	;;
esac

#
# We proceed to install the packages, non interactivelly
#
# The package selection is different if we are installer a controller or a compute node
#

if [ $nova_in_compute_node = "no" ]
then
	DEBIAN_FRONTEND=noninteractive aptitude -y install $nova_kvm_or_qemu \
		nova-api \
		nova-cert \
		nova-common \
		nova-compute \
		nova-conductor \
		nova-console \
		nova-consoleauth \
		nova-doc \
		nova-scheduler \
		nova-volume \
		$consolepackage \
		python-novaclient \
		liblapack3gf \
		python-gtk-vnc \
		novnc
else
	DEBIAN_FRONTEND=noninteractive aptitude -y install $nova_kvm_or_qemu
fi

echo "Done"
echo ""

stop nova-api > /dev/null 2>&1
stop nova-api > /dev/null 2>&1
stop nova-cert > /dev/null 2>&1
stop nova-cert > /dev/null 2>&1
stop nova-scheduler > /dev/null 2>&1
stop nova-scheduler > /dev/null 2>&1
stop nova-conductor > /dev/null 2>&1
stop nova-conductor > /dev/null 2>&1
stop nova-console > /dev/null 2>&1
stop nova-console > /dev/null 2>&1
stop nova-consoleauth > /dev/null 2>&1
stop nova-consoleauth > /dev/null 2>&1
stop $consolesvc > /dev/null 2>&1
stop $consolesvc > /dev/null 2>&1
stop nova-compute > /dev/null 2>&1
stop nova-compute > /dev/null 2>&1

source $keystone_admin_rc_file

rm -f /tmp/nova-seed.txt
rm -f /tmp/neutron-seed.txt
rm -f /tmp/cinder-seed.txt
rm -f /tmp/glance-seed.txt
rm -f /tmp/keystone-seed.txt

echo ""
echo "Applying IPTABLES rules"

#
# We apply IPTABLES rules
#

iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 6080 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 6081 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 6082 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 5900:5999 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 8773,8774,8775 -j ACCEPT
/etc/init.d/iptables-persistent save
echo ""
echo "Done"
echo ""

#
# Using python based "ini" configuration tools, we begin to configure nova services
#

echo "Configuring NOVA"

#
# Keystone NOVA Configuration
#

#if [ $nova_in_compute_node == "no" ]
#then
#	crudini --set /etc/nova/api-paste.ini filter:authtoken paste.filter_factory "keystonemiddleware.auth_token:filter_factory"
#	crudini --set /etc/nova/api-paste.ini filter:authtoken auth_protocol http
#	crudini --set /etc/nova/api-paste.ini filter:authtoken auth_host $keystonehost
#	crudini --set /etc/nova/api-paste.ini filter:authtoken admin_tenant_name $keystoneservicestenant
#	crudini --set /etc/nova/api-paste.ini filter:authtoken auth_port 35357
#	crudini --set /etc/nova/api-paste.ini filter:authtoken admin_password $novapass
#	crudini --set /etc/nova/api-paste.ini filter:authtoken admin_user $novauser
#	crudini --set /etc/nova/api-paste.ini filter:authtoken auth_uri http://$keystonehost:5000/v2.0
#	crudini --set /etc/nova/api-paste.ini filter:authtoken identity_uri http://$keystonehost:35357
#fi
 
# crudini --set /etc/nova/nova.conf keystone_authtoken auth_host $keystonehost
# crudini --set /etc/nova/nova.conf keystone_authtoken auth_port 35357
# crudini --set /etc/nova/nova.conf keystone_authtoken auth_protocol http
# crudini --set /etc/nova/nova.conf keystone_authtoken admin_tenant_name $keystoneservicestenant
# crudini --set /etc/nova/nova.conf keystone_authtoken admin_user $novauser
# crudini --set /etc/nova/nova.conf keystone_authtoken admin_password $novapass
# crudini --set /etc/nova/nova.conf keystone_authtoken signing_dir /tmp/keystone-signing-nova
# crudini --set /etc/nova/nova.conf keystone_authtoken auth_uri http://$keystonehost:5000/v2.0
# crudini --set /etc/nova/nova.conf keystone_authtoken identity_uri http://$keystonehost:35357

crudini --set /etc/nova/nova.conf keystone_authtoken auth_uri http://$keystonehost:5000
crudini --set /etc/nova/nova.conf keystone_authtoken auth_url http://$keystonehost:35357
crudini --set /etc/nova/nova.conf keystone_authtoken auth_plugin password
crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_id default
crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_id default
crudini --set /etc/nova/nova.conf keystone_authtoken project_name $keystoneservicestenant
crudini --set /etc/nova/nova.conf keystone_authtoken username $novauser
crudini --set /etc/nova/nova.conf keystone_authtoken password $novapass

# crudini --set /etc/nova/nova.conf DEFAULT notification_driver nova.openstack.common.notifier.rpc_notifier

#
# Ceilometer NOVA configuration
#

if [ $ceilometerinstall == "yes" ]
then
	crudini --set /etc/nova/nova.conf DEFAULT notification_driver messagingv2
	#crudini --set /etc/nova/nova.conf DEFAULT notification_driver ceilometer.compute.nova_notifier
	#case $brokerflavor in
	#"qpid")
	#	sed -r -i 's/ceilometer.compute.nova_notifier/ceilometer.compute.nova_notifier\nnotification_driver\ =\ nova.openstack.common.notifier.rpc_notifier/' /etc/nova/nova.conf
	#	;;
	#"rabbitmq")
	#	sed -r -i 's/ceilometer.compute.nova_notifier/ceilometer.compute.nova_notifier\nnotification_driver\ =\ nova.openstack.common.notifier.rpc_notifier/' /etc/nova/nova.conf
	#	;;
	#esac
	crudini --set /etc/nova/nova.conf DEFAULT instance_usage_audit True
	crudini --set /etc/nova/nova.conf DEFAULT instance_usage_audit_period hour
	crudini --set /etc/nova/nova.conf DEFAULT notify_on_state_change vm_and_task_state
fi

#
# NOVA Main Config
#

crudini --set /etc/nova/nova.conf DEFAULT use_forwarded_for False
crudini --set /etc/nova/nova.conf DEFAULT instance_usage_audit_period hour
crudini --set /etc/nova/nova.conf DEFAULT logdir /var/log/nova
crudini --set /etc/nova/nova.conf DEFAULT state_path /var/lib/nova
# crudini --set /etc/nova/nova.conf DEFAULT lock_path /var/lib/nova/tmp
crudini --set /etc/nova/nova.conf DEFAULT volumes_dir /etc/nova/volumes
crudini --set /etc/nova/nova.conf DEFAULT dhcpbridge /usr/bin/nova-dhcpbridge
crudini --set /etc/nova/nova.conf DEFAULT dhcpbridge_flagfile /etc/nova/nova.conf
crudini --set /etc/nova/nova.conf DEFAULT force_dhcp_release True
crudini --set /etc/nova/nova.conf DEFAULT injected_network_template /usr/share/nova/interfaces.template
crudini --set /etc/nova/nova.conf libvirt inject_partition -1
crudini --set /etc/nova/nova.conf DEFAULT network_manager nova.network.manager.FlatDHCPManager
crudini --set /etc/nova/nova.conf DEFAULT iscsi_helper tgtadm
crudini --set /etc/nova/nova.conf DEFAULT vif_plugging_timeout 10
crudini --set /etc/nova/nova.conf DEFAULT vif_plugging_is_fatal False
crudini --set /etc/nova/nova.conf DEFAULT control_exchange nova
crudini --set /etc/nova/nova.conf DEFAULT host `hostname`

#
# Database configuration based on the flavor selected on our config
#

case $dbflavor in
"mysql")
	crudini --set /etc/nova/nova.conf database connection mysql://$novadbuser:$novadbpass@$dbbackendhost:$mysqldbport/$novadbname
	;;
"postgres")
	crudini --set /etc/nova/nova.conf database connection postgresql://$novadbuser:$novadbpass@$dbbackendhost:$psqldbport/$novadbname
	;;
esac

crudini --set /etc/nova/nova.conf database retry_interval 10
crudini --set /etc/nova/nova.conf database idle_timeout 3600
crudini --set /etc/nova/nova.conf database min_pool_size 1
crudini --set /etc/nova/nova.conf database max_pool_size 10
crudini --set /etc/nova/nova.conf database max_retries 100
crudini --set /etc/nova/nova.conf database pool_timeout 10

#
# More main config
#

osapiworkers=`grep processor.\*: /proc/cpuinfo |wc -l`

crudini --set /etc/nova/nova.conf DEFAULT compute_driver libvirt.LibvirtDriver
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
crudini --set /etc/nova/nova.conf DEFAULT rootwrap_config /etc/nova/rootwrap.conf
crudini --set /etc/nova/nova.conf DEFAULT osapi_volume_listen 0.0.0.0
crudini --set /etc/nova/nova.conf DEFAULT auth_strategy keystone
crudini --set /etc/nova/nova.conf DEFAULT verbose False
# Deprecated
# crudini --set /etc/nova/nova.conf DEFAULT ec2_listen 0.0.0.0
crudini --set /etc/nova/nova.conf DEFAULT service_down_time 60
crudini --set /etc/nova/nova.conf DEFAULT image_service nova.image.glance.GlanceImageService
crudini --set /etc/nova/nova.conf libvirt use_virtio_for_bridges True
crudini --set /etc/nova/nova.conf DEFAULT osapi_compute_listen 0.0.0.0
crudini --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret $metadata_shared_secret
crudini --set /etc/nova/nova.conf DEFAULT metadata_listen 0.0.0.0
crudini --set /etc/nova/nova.conf DEFAULT osapi_compute_workers $osapiworkers
crudini --set /etc/nova/nova.conf libvirt vif_driver nova.virt.libvirt.vif.LibvirtGenericVIFDriver
crudini --set /etc/nova/nova.conf neutron region_name $endpointsregion
crudini --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.neutronv2.api.API
crudini --set /etc/nova/nova.conf DEFAULT debug False
crudini --set /etc/nova/nova.conf DEFAULT my_ip $nova_computehost
crudini --set /etc/nova/nova.conf neutron auth_strategy keystone
crudini --set /etc/nova/nova.conf neutron admin_password $neutronpass
crudini --set /etc/nova/nova.conf DEFAULT api_paste_config /etc/nova/api-paste.ini
crudini --set /etc/nova/nova.conf glance api_servers $glancehost:9292
crudini --set /etc/nova/nova.conf glance host $glancehost
crudini --set /etc/nova/nova.conf oslo_concurrency lock_path "/var/oslock/nova"
crudini --set /etc/nova/nova.conf neutron admin_tenant_name $keystoneservicestenant
crudini --set /etc/nova/nova.conf DEFAULT metadata_host $novahost
crudini --set /etc/nova/nova.conf DEFAULT security_group_api neutron
crudini --set /etc/nova/nova.conf neutron admin_auth_url "http://$keystonehost:35357/v2.0"
# crudini --set /etc/nova/nova.conf DEFAULT enabled_apis "ec2,osapi_compute,metadata"
crudini --set /etc/nova/nova.conf neutron admin_username $neutronuser
crudini --set /etc/nova/nova.conf service neutron_metadata_proxy True
crudini --set /etc/nova/nova.conf DEFAULT volume_api_class nova.volume.cinder.API
crudini --set /etc/nova/nova.conf neutron url "http://$neutronhost:9696"
crudini --set /etc/nova/nova.conf libvirt virt_type kvm
crudini --set /etc/nova/nova.conf DEFAULT instance_name_template $instance_name_template
crudini --set /etc/nova/nova.conf DEFAULT start_guests_on_host_boot $start_guests_on_host_boot
crudini --set /etc/nova/nova.conf DEFAULT resume_guests_state_on_host_boot $resume_guests_state_on_host_boot
crudini --set /etc/nova/nova.conf DEFAULT instance_name_template $instance_name_template
crudini --set /etc/nova/nova.conf DEFAULT allow_resize_to_same_host $allow_resize_to_same_host
crudini --set /etc/nova/nova.conf DEFAULT vnc_enabled True
crudini --set /etc/nova/nova.conf DEFAULT ram_allocation_ratio $ram_allocation_ratio
crudini --set /etc/nova/nova.conf DEFAULT cpu_allocation_ratio $cpu_allocation_ratio
crudini --set /etc/nova/nova.conf DEFAULT connection_type libvirt
crudini --set /etc/nova/nova.conf DEFAULT novncproxy_host 0.0.0.0
crudini --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address $novahost
crudini --set /etc/nova/nova.conf DEFAULT novncproxy_base_url "http://$vncserver_controller_address:6080/vnc_auto.html"
crudini --set /etc/nova/nova.conf DEFAULT scheduler_default_filters "RetryFilter,AvailabilityZoneFilter,RamFilter,ComputeFilter,ComputeCapabilitiesFilter,ImagePropertiesFilter,CoreFilter"
crudini --set /etc/nova/nova.conf DEFAULT novncproxy_port 6080
crudini --set /etc/nova/nova.conf DEFAULT vncserver_listen $novahost
crudini --set /etc/nova/nova.conf DEFAULT vnc_keymap $vnc_keymap
# crudini --set /etc/nova/nova.conf DEFAULT force_config_drive true
# crudini --set /etc/nova/nova.conf DEFAULT config_drive_format iso9660
# crudini --set /etc/nova/nova.conf DEFAULT config_drive_cdrom true
# crudini --set /etc/nova/nova.conf DEFAULT config_drive_inject_password True
# crudini --set /etc/nova/nova.conf DEFAULT mkisofs_cmd genisoimage
crudini --set /etc/nova/nova.conf DEFAULT dhcp_domain $dhcp_domain
crudini --set /etc/nova/nova.conf DEFAULT neutron_default_tenant_id default
 
crudini --set /etc/nova/nova.conf neutron url "http://$neutronhost:9696"
crudini --set /etc/nova/nova.conf neutron auth_strategy keystone
crudini --set /etc/nova/nova.conf neutron admin_auth_url "http://$keystonehost:35357/v2.0"
crudini --set /etc/nova/nova.conf neutron admin_tenant_name $keystoneservicestenant
crudini --set /etc/nova/nova.conf neutron admin_username $neutronuser
crudini --set /etc/nova/nova.conf neutron admin_password $neutronpass
 
crudini --set /etc/nova/nova.conf DEFAULT linuxnet_ovs_integration_bridge $integration_bridge
crudini --set /etc/nova/nova.conf neutron ovs_bridge $integration_bridge
 
#
# Console configuration based on our console flavor selection
#

case $consoleflavor in
"vnc")
	crudini --set /etc/nova/nova.conf DEFAULT vnc_enabled True
	crudini --set /etc/nova/nova.conf DEFAULT novncproxy_host 0.0.0.0
	crudini --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address $nova_computehost
	crudini --set /etc/nova/nova.conf DEFAULT novncproxy_base_url "http://$vncserver_controller_address:6080/vnc_auto.html"
	crudini --set /etc/nova/nova.conf DEFAULT novncproxy_port 6080
	crudini --set /etc/nova/nova.conf DEFAULT vncserver_listen $nova_computehost
	crudini --set /etc/nova/nova.conf DEFAULT vnc_keymap $vnc_keymap
	crudini --del /etc/nova/nova.conf spice html5proxy_base_url > /dev/null 2>&1
	crudini --del /etc/nova/nova.conf spice server_listen > /dev/null 2>&1
	crudini --del /etc/nova/nova.conf spice server_proxyclient_address > /dev/null 2>&1
	crudini --del /etc/nova/nova.conf spice keymap > /dev/null 2>&1
	crudini --set /etc/nova/nova.conf spice agent_enabled False > /dev/null 2>&1
	crudini --set /etc/nova/nova.conf spice enabled False > /dev/null 2>&1
	;;
"spice")
	crudini --del /etc/nova/nova.conf DEFAULT novncproxy_host > /dev/null 2>&1
	crudini --del /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address > /dev/null 2>&1
	crudini --del /etc/nova/nova.conf DEFAULT novncproxy_base_url > /dev/null 2>&1
	crudini --del /etc/nova/nova.conf DEFAULT novncproxy_port > /dev/null 2>&1
	crudini --del /etc/nova/nova.conf DEFAULT vncserver_listen > /dev/null 2>&1
	crudini --del /etc/nova/nova.conf DEFAULT vnc_keymap > /dev/null 2>&1
	crudini --set /etc/nova/nova.conf DEFAULT vnc_enabled False > /dev/null 2>&1
	crudini --set /etc/nova/nova.conf DEFAULT novnc_enabled False > /dev/null 2>&1
	crudini --set /etc/nova/nova.conf spice html5proxy_base_url "http://$spiceserver_controller_address:6082/spice_auto.html"
	crudini --set /etc/nova/nova.conf spice server_listen 0.0.0.0
	crudini --set /etc/nova/nova.conf spice server_proxyclient_address $nova_computehost
	crudini --set /etc/nova/nova.conf spice enabled True
	crudini --set /etc/nova/nova.conf spice agent_enabled True
	crudini --set /etc/nova/nova.conf spice keymap en-us
	;;
esac

#
# Message Broker Configuration, based on selected flavor into our main config
#
 
case $brokerflavor in
"qpid")
	# crudini --set /etc/nova/nova.conf DEFAULT rpc_backend nova.openstack.common.rpc.impl_qpid
	crudini --set /etc/nova/nova.conf DEFAULT rpc_backend qpid
	crudini --set /etc/nova/nova.conf DEFAULT qpid_reconnect_interval_min 0
	crudini --set /etc/nova/nova.conf DEFAULT qpid_username $brokeruser
	crudini --set /etc/nova/nova.conf DEFAULT qpid_reconnect True
	crudini --set /etc/nova/nova.conf DEFAULT qpid_tcp_nodelay True
	crudini --set /etc/nova/nova.conf DEFAULT qpid_protocol tcp
	crudini --set /etc/nova/nova.conf DEFAULT qpid_hostname $messagebrokerhost
	crudini --set /etc/nova/nova.conf DEFAULT qpid_password $brokerpass
	crudini --set /etc/nova/nova.conf DEFAULT qpid_port 5672
	crudini --set /etc/nova/nova.conf DEFAULT qpid_heartbeat 60
	crudini --set /etc/nova/nova.conf oslo_messaging_qpid qpid_hostname $messagebrokerhost
	crudini --set /etc/nova/nova.conf oslo_messaging_qpid qpid_port 5672
	crudini --set /etc/nova/nova.conf oslo_messaging_qpid qpid_username $brokeruser
	crudini --set /etc/nova/nova.conf oslo_messaging_qpid qpid_password $brokerpass
	crudini --set /etc/nova/nova.conf oslo_messaging_qpid qpid_heartbeat 60
	crudini --set /etc/nova/nova.conf oslo_messaging_qpid qpid_protocol tcp
	crudini --set /etc/nova/nova.conf oslo_messaging_qpid qpid_tcp_nodelay True
	;;
 
"rabbitmq")
	# crudini --set /etc/nova/nova.conf DEFAULT rpc_backend nova.openstack.common.rpc.impl_kombu
	crudini --set /etc/nova/nova.conf DEFAULT rpc_backend rabbit
	crudini --set /etc/nova/nova.conf DEFAULT rabbit_host $messagebrokerhost
	crudini --set /etc/nova/nova.conf DEFAULT rabbit_userid $brokeruser
	crudini --set /etc/nova/nova.conf DEFAULT rabbit_password $brokerpass
	crudini --set /etc/nova/nova.conf DEFAULT rabbit_port 5672
	crudini --set /etc/nova/nova.conf DEFAULT rabbit_use_ssl false
	crudini --set /etc/nova/nova.conf DEFAULT rabbit_virtual_host $brokervhost
	crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host $messagebrokerhost
	crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password $brokerpass
	crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid $brokeruser
	crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_port 5672
	crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_use_ssl false
	crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_virtual_host $brokervhost
	crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_max_retries 0
	crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_retry_interval 1
	crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_ha_queues false
	;;
esac

sync
sleep 5
sync


sed -r -i 's/NOVA_ENABLE\=false/NOVA_ENABLE\=true/' /etc/default/nova-common > /dev/null 2>&1

sync
sleep 5
sync

#
# If this server does not support KVM, we echo an WARNING to the console and configure
# nova for QEMU instead of KVM
#

if [ $kvm_possible == "0" ]
then
	echo ""
	echo "WARNING !!! - This server does not support KVM"
	echo "We will use QEMU virtualization instead of KVM"
	echo "Performance WILL BE POOR !!!"
	echo ""
	source $keystone_admin_rc_file
	crudini --set /etc/nova/nova.conf libvirt virt_type qemu
	echo ""
else
	crudini --set /etc/nova/nova.conf libvirt virt_type kvm
	crudini --set /etc/nova/nova.conf libvirt cpu_mode $libvirt_cpu_mode
fi

mkdir -p /var/oslock/nova
chown -R nova.nova /var/oslock/nova

sync
sleep 5
sync

rm -f /var/lib/nova/nova.sqlite

#
# We provision/update NOVA Database... only if we are not on a compute node
#

if [ $nova_in_compute_node = "no" ]
then
	su nova -s /bin/sh -c "nova-manage db sync"
fi

sync
sleep 5
sync

echo "Done"

echo "Starting NOVA"

#
# We start and enable proper services depending of our node type
#

if [ $nova_in_compute_node = "no" ]
then
	start nova-api
	start nova-cert
	start nova-scheduler
	start nova-conductor
	start nova-console
	start nova-consoleauth
	start $consolesvc

	if [ $nova_without_compute = "no" ]
	then
		start nova-compute
	else
		stop nova-compute
		echo 'manual' > /etc/init/nova-compute.override
	fi

	echo 'manual' > /etc/init/nova-xenvncproxy.override
else
	start nova-compute
fi

echo ""
echo "Done"

#
# 10 seconds sleep in order to allow some stabilization
#

echo ""
echo "Sleeping 10 seconds"
echo ""

sync
sleep 10
sync

#
# Nova do some changes to IPTABLES... We just ensure those changes are saved
#

/etc/init.d/iptables-persistent save

echo ""
echo "Let's continue"
echo ""

#
# Now, and depending on our selections, we configure our security groups
#

if [ $nova_in_compute_node = "no" ]
then
	if [ $vm_default_access == "yes" ]
	then
		echo ""
		echo "Creating VM's security access"
		echo "Ports: ssh and ICMP"
		echo ""
		source $keystone_admin_rc_file
		nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
		nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
		echo "Done"
		echo ""
	fi

	for vmport in $vm_extra_ports_tcp
	do
		echo ""
		echo "Creating access for port $vmport tcp"
		source $keystone_admin_rc_file
		nova secgroup-add-rule default tcp $vmport $vmport 0.0.0.0/0
	done

	for vmport in $vm_extra_ports_udp
	do
		echo ""
		echo "Creating access for port $vmport udp"
		source $keystone_admin_rc_file
		nova secgroup-add-rule default udp $vmport $vmport 0.0.0.0/0
	done
fi

#
# Finally, we do a little test to ensure our packages are installed. If we fail here, we
# stop the whole installer from this point.
#

testnova=`dpkg -l nova-common 2>/dev/null|tail -n 1|grep -ci ^ii`
if [ $testnova == "0" ]
then
	echo ""
	echo "NOVA Installation FAILED. Aborting !"
	echo ""
	exit 0
else
	date > /etc/openstack-control-script-config/nova-installed
	date > /etc/openstack-control-script-config/nova
	echo "$consolesvc" > /etc/openstack-control-script-config/nova-console-svc
	if [ $nova_in_compute_node = "no" ]
	then
		date > /etc/openstack-control-script-config/nova-full-installed
	fi
	if [ $nova_without_compute = "yes" ]
	then
		if [ $nova_in_compute_node = "no" ]
		then
			date > /etc/openstack-control-script-config/nova-without-compute
		fi
	fi
fi

echo ""
echo "Nova Installed and Configured"
echo ""


