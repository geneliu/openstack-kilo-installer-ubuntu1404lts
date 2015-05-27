#!/bin/bash
#
# Unattended installer for OpenStack. - Ubuntu Server 14.04lts
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
#
# Service control script
#

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

if [ ! -d /etc/openstack-control-script-config ]
then
	echo ""
	echo "Control file not found: /etc/openstack-control-script-config"
	echo "Aborting !"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/nova-console-svc ]
then
	consolesvc=`/bin/cat /etc/openstack-control-script-config/nova-console-svc`
fi

#
# From KILO, Keystone uses apache2 wsgi
#

keystone_svc_start='apache2'

swift_svc_start='
	swift-account
	swift-account-auditor
	swift-account-reaper
	swift-account-replicator
	swift-container
	swift-container-auditor
	swift-container-replicator
	swift-container-updater
	swift-object
	swift-object-auditor
	swift-object-replicator
	swift-object-updater
	swift-proxy
'

glance_svc_start='
	glance-registry
	glance-api
'

cinder_svc_start='
	cinder-api
	cinder-scheduler
	cinder-volume
'

if [ -f /etc/openstack-control-script-config/neutron-full-installed ]
then
	if [ -f /etc/openstack-control-script-config/neutron-full-installed-metering ]
	then
		metering="neutron-metering-agent"
	else
		metering=""
	fi
        if [ -f /etc/openstack-control-script-config/neutron-full-installed-vpnaas ]
        then
		neutron_svc_start="
                        neutron-server
                        neutron-plugin-openvswitch-agent
                        neutron-l3-agent
                        neutron-lbaas-agent
                        neutron-metadata-agent
                        neutron-dhcp-agent
                        neutron-vpn-agent
			$metering
		"
	else
		neutron_svc_start="
                        neutron-server
                        neutron-plugin-openvswitch-agent
                        neutron-l3-agent
                        neutron-lbaas-agent
                        neutron-metadata-agent
                        neutron-dhcp-agent
			$metering
		"
	fi
else
	neutron_svc_start='
		neutron-plugin-openvswitch-agent
	'
fi

if [ -f /etc/openstack-control-script-config/nova-full-installed ]
then
	if [ -f /etc/openstack-control-script-config/nova-without-compute ]
	then
		nova_svc_start="
			nova-api
			nova-cert
			nova-scheduler
			nova-conductor
			nova-console
			nova-consoleauth
			$consolesvc
		"
	else
		nova_svc_start="
			nova-api
			nova-cert
			nova-scheduler
			nova-conductor
			nova-console
			nova-consoleauth
			$consolesvc
			nova-compute
		"
	fi
else
	nova_svc_start='
		nova-compute
	'
fi

if [ -f /etc/openstack-control-script-config/ceilometer-installed-alarms ]
then
	alarm1="ceilometer-alarm-notifier"
	alarm2="ceilometer-alarm-evaluator"
	alarm3="ceilometer-agent-notification"
else
	alarm1=""
	alarm2=""
	alarm3=""
fi
 
if [ -f /etc/openstack-control-script-config/ceilometer-full-installed ]
then
	if [ -f /etc/openstack-control-script-config/ceilometer-without-compute ]
	then
		ceilometer_svc_start="
			ceilometer-agent-central
			ceilometer-api
			ceilometer-collector
			$alarm1
			$alarm2
			$alarm3
		"
	else
		ceilometer_svc_start="
			ceilometer-agent-compute
			ceilometer-agent-central
			ceilometer-api
			ceilometer-collector
			$alarm1
			$alarm2
			$alarm3
		"
fi
else
	ceilometer_svc_start="
		ceilometer-agent-compute
	"
fi

heat_svc_start='
	heat-api
	heat-api-cfn
	heat-engine
'

trove_svc_start='
        trove-api
        trove-taskmanager
	trove-conductor
'

sahara_svc_start='
        sahara
'


service_status_stop=`echo $service_status_start_enable_disable|tac -s' '`

keystone_svc_stop='apache2'
swift_svc_stop=`echo $swift_svc_start|tac -s' '`
glance_svc_stop=`echo $glance_svc_start|tac -s' '`
cinder_svc_stop=`echo $cinder_svc_start|tac -s' '`
neutron_svc_stop=`echo $neutron_svc_start|tac -s' '`
nova_svc_stop=`echo $nova_svc_start|tac -s' '`
ceilometer_svc_stop=`echo $ceilometer_svc_start|tac -s' '`
heat_svc_stop=`echo $heat_svc_start|tac -s' '`
trove_svc_stop=`echo $trove_svc_start|tac -s' '`
sahara_svc_stop=`echo $sahara_svc_start|tac -s' '`

case $1 in

start)

	echo ""
	echo "Starting OpenStack Services"
	echo ""

	if [ -f /etc/openstack-control-script-config/keystone ]
	then
		for i in $keystone_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/swift ]
	then
		for i in $swift_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/glance ]
	then
		for i in $glance_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/cinder ]
	then
		for i in $cinder_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/neutron ]
	then
		for i in $neutron_svc_start
		do
			service $i start
			#sleep 1
		done
		if [ -f /etc/openstack-control-script-config/neutron-full-installed ]
		then
			sleep 2
			service neutron-l3-agent restart
			service neutron-dhcp-agent restart
		fi
	fi

	if [ -f /etc/openstack-control-script-config/nova ]
	then
		for i in $nova_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/ceilometer ]
	then
		for i in $ceilometer_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

        if [ -f /etc/openstack-control-script-config/heat ]
        then
                for i in $heat_svc_start
                do
                        service $i start
                        #sleep 1
                done
        fi

        if [ -f /etc/openstack-control-script-config/trove ]
        then
                for i in $trove_svc_start
                do
                        service $i start
                        #sleep 1
                done
        fi

        if [ -f /etc/openstack-control-script-config/sahara ]
        then
                for i in $sahara_svc_start
                do
                        service $i start
                        #sleep 1
                done
        fi

	echo ""

	;;

stop)

	echo ""
	echo "Stopping OpenStack Services"
	echo ""

        if [ -f /etc/openstack-control-script-config/sahara ]
        then
                for i in $sahara_svc_stop
                do
                        service $i stop
                        #sleep 1
                done
        fi

        if [ -f /etc/openstack-control-script-config/trove ]
        then
                for i in $trove_svc_stop
                do
                        service $i stop
                        #sleep 1
                done
        fi

        if [ -f /etc/openstack-control-script-config/heat ]
        then
                for i in $heat_svc_stop
                do
                        service $i stop
                        #sleep 1
                done
        fi

	if [ -f /etc/openstack-control-script-config/ceilometer ]
	then
		for i in $ceilometer_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/nova ]
	then
		for i in $nova_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/neutron ]
	then
		for i in $neutron_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/cinder ]
	then
		for i in $cinder_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/glance ]
	then
		for i in $glance_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/swift ]
	then
		for i in $swift_svc_stop
		do
			service $i stop
			#sleep 1
		done
		killall -9 -u swift
	fi

	if [ -f /etc/openstack-control-script-config/keystone ]
	then
		for i in $keystone_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	rm -rf /tmp/keystone-signing-*
	rm -rf /tmp/cd_gen_*	

	echo ""

	;;

status)

	echo ""
	echo "Verifying OpenStack Services Status"
	echo ""


	if [ -f /etc/openstack-control-script-config/keystone ]
	then
		for i in $keystone_svc_start
		do
			service $i status
		done
	fi

	if [ -f /etc/openstack-control-script-config/swift ]
	then
		for i in $swift_svc_start
		do
			service $i status
		done
	fi

	if [ -f /etc/openstack-control-script-config/glance ]
	then
		for i in $glance_svc_start
		do
			service $i status
		done
	fi

	if [ -f /etc/openstack-control-script-config/cinder ]
	then
		for i in $cinder_svc_start
		do
			service $i status
		done
	fi

	if [ -f /etc/openstack-control-script-config/neutron ]
	then
		for i in $neutron_svc_start
		do
			service $i status
		done
	fi

	if [ -f /etc/openstack-control-script-config/nova ]
	then
		for i in $nova_svc_start
		do
			service $i status
		done
	fi

	if [ -f /etc/openstack-control-script-config/ceilometer ]
	then
		for i in $ceilometer_svc_start
		do
			service $i status
		done
	fi

        if [ -f /etc/openstack-control-script-config/heat ]
        then
                for i in $heat_svc_start
                do
                        service $i status
                done
        fi

        if [ -f /etc/openstack-control-script-config/trove ]
        then
                for i in $trove_svc_start
                do
                        service $i status
                done
        fi

        if [ -f /etc/openstack-control-script-config/sahara ]
        then
                for i in $sahara_svc_start
                do
                        service $i status
                done
        fi

	echo ""
	;;

enable)

	echo ""
	echo "Enabling OpenStack Services"
	echo ""

	if [ -f /etc/openstack-control-script-config/keystone ]
	then
		for i in $keystone_svc_start
		do
			if [ -f /etc/init/$i.override ]
			then
				rm -f /etc/init/$i.override
			fi
		done
	fi

	if [ -f /etc/openstack-control-script-config/swift ]
	then
		for i in $swift_svc_start
		do
                        if [ -f /etc/init/$i.override ]
                        then
                                rm -f /etc/init/$i.override
                        fi
		done
	fi

	if [ -f /etc/openstack-control-script-config/glance ]
	then
		for i in $glance_svc_start
		do
                        if [ -f /etc/init/$i.override ]
                        then
                                rm -f /etc/init/$i.override
                        fi
		done
	fi

	if [ -f /etc/openstack-control-script-config/cinder ]
	then
		for i in $cinder_svc_start
		do
                        if [ -f /etc/init/$i.override ]
                        then
                                rm -f /etc/init/$i.override
                        fi
		done
	fi

	if [ -f /etc/openstack-control-script-config/neutron ]
	then
		for i in $neutron_svc_start
		do
                        if [ -f /etc/init/$i.override ]
                        then
                                rm -f /etc/init/$i.override
                        fi
		done
	fi

	if [ -f /etc/openstack-control-script-config/nova ]
	then
		for i in $nova_svc_start
		do
                        if [ -f /etc/init/$i.override ]
                        then
                                rm -f /etc/init/$i.override
                        fi
		done
	fi

	if [ -f /etc/openstack-control-script-config/ceilometer ]
	then
		for i in $ceilometer_svc_start
		do
                        if [ -f /etc/init/$i.override ]
                        then
                                rm -f /etc/init/$i.override
                        fi
		done
	fi

        if [ -f /etc/openstack-control-script-config/heat ]
        then
                for i in $heat_svc_start
                do
                        if [ -f /etc/init/$i.override ]
                        then
                                rm -f /etc/init/$i.override
                        fi
                done
        fi

        if [ -f /etc/openstack-control-script-config/trove ]
        then
                for i in $trove_svc_start
                do
                        if [ -f /etc/init/$i.override ]
                        then
                                rm -f /etc/init/$i.override
                        fi
                done
        fi

        if [ -f /etc/openstack-control-script-config/sahara ]
        then
                for i in $sahara_svc_start
                do
                        if [ -f /etc/init/$i.override ]
                        then
                                rm -f /etc/init/$i.override
                        fi
                done
        fi

	echo ""
	;;

disable)

	echo ""
        echo "Disabling OpenStack Services"
        echo ""

	if [ -f /etc/openstack-control-script-config/keystone ]
	then
		for i in $keystone_svc_start
		do
			echo 'manual' > /etc/init/$i.override
		done
	fi

	if [ -f /etc/openstack-control-script-config/swift ]
	then
		for i in $swift_svc_start
		do
			echo 'manual' > /etc/init/$i.override
		done
	fi

	if [ -f /etc/openstack-control-script-config/glance ]
	then
		for i in $glance_svc_start
		do
			echo 'manual' > /etc/init/$i.override
		done
	fi

	if [ -f /etc/openstack-control-script-config/cinder ]
	then
		for i in $cinder_svc_start
		do
			echo 'manual' > /etc/init/$i.override
		done
	fi

	if [ -f /etc/openstack-control-script-config/neutron ]
	then
		for i in $neutron_svc_start
		do
			echo 'manual' > /etc/init/$i.override
		done
	fi

	if [ -f /etc/openstack-control-script-config/nova ]
	then
		for i in $nova_svc_start
		do
			echo 'manual' > /etc/init/$i.override
		done
	fi

	if [ -f /etc/openstack-control-script-config/ceilometer ]
	then
		for i in $ceilometer_svc_start
		do
			echo 'manual' > /etc/init/$i.override
		done
	fi

        if [ -f /etc/openstack-control-script-config/heat ]
        then
                for i in $heat_svc_start
                do
			echo 'manual' > /etc/init/$i.override
                done
        fi

        if [ -f /etc/openstack-control-script-config/trove ]
        then
                for i in $trove_svc_start
                do
                        echo 'manual' > /etc/init/$i.override
                done
        fi

        if [ -f /etc/openstack-control-script-config/sahara ]
        then
                for i in $sahara_svc_start
                do
                        echo 'manual' > /etc/init/$i.override
                done
        fi

        echo ""
	;;

restart)

	echo ""
	echo "Re-Starting OpenStack Services"
	echo ""


        if [ -f /etc/openstack-control-script-config/sahara ]
        then
                for i in $sahara_svc_stop
                do
                        service $i stop
                        #sleep 1
                done
        fi

        if [ -f /etc/openstack-control-script-config/trove ]
        then
                for i in $trove_svc_stop
                do
                        service $i stop
                        #sleep 1
                done
        fi

        if [ -f /etc/openstack-control-script-config/heat ]
        then
                for i in $heat_svc_stop
                do
                        service $i stop
                        #sleep 1
                done
        fi

	if [ -f /etc/openstack-control-script-config/ceilometer ]
	then
		for i in $ceilometer_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/nova ]
	then
		for i in $nova_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/neutron ]
	then
		for i in $neutron_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/cinder ]
	then
		for i in $cinder_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/glance ]
	then
		for i in $glance_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/swift ]
	then
		for i in $swift_svc_stop
		do
			service $i stop
			#sleep 1
		done
		killall -9 -u swift
	fi

	if [ -f /etc/openstack-control-script-config/keystone ]
	then
		for i in $keystone_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	rm -rf /tmp/keystone-signing-*
	rm -rf /tmp/cd_gen_*

	if [ -f /etc/openstack-control-script-config/keystone ]
	then
		for i in $keystone_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/swift ]
	then
		for i in $swift_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/glance ]
	then
		for i in $glance_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/cinder ]
	then
		for i in $cinder_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/neutron ]
	then
		for i in $neutron_svc_start
		do
			service $i start
			#sleep 1
		done
                if [ -f /etc/openstack-control-script-config/neutron-full-installed ]
                then
                        sleep 2
                        service neutron-l3-agent restart
                        service neutron-dhcp-agent restart
                fi
	fi

	if [ -f /etc/openstack-control-script-config/nova ]
	then
		for i in $nova_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/ceilometer ]
	then
		for i in $ceilometer_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

        if [ -f /etc/openstack-control-script-config/heat ]
        then
                for i in $heat_svc_start
                do
                        service $i start
                        #sleep 1
                done
        fi

        if [ -f /etc/openstack-control-script-config/trove ]
        then
                for i in $trove_svc_start
                do
                        service $i start
                        #sleep 1
                done
        fi

        if [ -f /etc/openstack-control-script-config/sahara ]
        then
                for i in $sahara_svc_start
                do
                        service $i start
                        #sleep 1
                done
        fi

	echo ""

	;;

*)
	echo ""
	echo "Usage: $0 start, stop, status, restart, enable, o disable:"
	echo "start:    Starts all OpenStack Services"
	echo "stop:     Stops All OpenStack Services"
	echo "restart:  Re-Starts all OpenStack Services"
	echo "enable:   Enable all OpenStack Services"
	echo "disable:  Disable all OpenStack Services"
	echo "status:   Show the status of all OpenStack Services"
	echo ""
	;;

esac
