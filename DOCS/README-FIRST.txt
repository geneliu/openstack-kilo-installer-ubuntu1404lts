# Unattended Installer (Semi Automated) for OpenStack (KILO)
Reynaldo P. R. Martinez
E-Mail: TigerLinux@Gmail.com
Caracas, Venezuela.

## Introduction

This installer was made to automate the tasks of creating a virtualization infrastructure based on OpenStack. So far, There are two "flavors" for this installer: One for  Centos 7 and one for Ubuntu 14.04 LTS.

All two versions produce a fully production-usable OpenStack. You can use this installer to make a single-node all-in-one OpenStack server, or a more complex design with controller and compute nodes.

In summary, this installer can produce an OpenStack virtualization service completely usable in production environments, however, remember that the "bugs" factor don't depend solely on us. From time to time OpenStack packages can bring us some bugs too. We are using rpm/deb packages from Ubuntu and Redhat repositories and they can have their own bugs. 

## Using the Installer.

### First

* READ, READ, READ and after some rest, READ AGAIN!. *

Read everything you can from * OpenStack * if you want to venture into the virtualization in the cloud World. If you do not like reading, then support yourself on someone who can do the reading. Please do not try to use this Installer without having any knowledge at hand. View file `NOTES.txt` to understand a little more about the knowledge which you should have.

You can begin here: * http://docs.openstack.org *

The big world of * OpenStack * includes several technologies from the world of Open-source and the world of networks that must be understood thoroughly before even attempting any installation of OpenStack, whether you use this installation tool or any other. In short, if you do not have the knowledge, do not even try. Gain the knowledge first, then proceed.

Before using the installer, you must prepare your server of servers. Again, in the file `NOTES.txt` you will find important points that you should understand before start an installation using this tool. The installer will make some validations, should yield negative results, will abort the process.

### Second: Edit the installer main configuration file.

The installer has a central configuration file: `./configs/main-config.rc`. This file is well documented so * if you did your homework and studied * about * OpenStack *, you will know what to change there. There are very obvious things like passwords, IP addresses, modules to install and dns domains or domain names.

In the version by default, the configuration file has selections modules to install what is known as an "all-in-one" (an OpenStack monolithic service with controller-compute capabilites). You can just change the IP with the one assigned to your server (please DO NOT use * localhost * and DO NOT use a Dynamic DHCP assigned IP).

Additionally, there are some modules that are in default "no":

* Heat *
* Swift *
* Trove * 
* Sahara *
* SNMP *. 

We recommend to activate swift install option "only If you are really going to use it". * Swift * alone is almost as extensive as OpenStack. Use if you REALLY know what you're doing and if you are REALLY going to use it. 

The SNMP module installs monitoring variables useful if you want to monitor OpenStack with SNMP but does not install any monitoring application. The variables are described (if you install the support) in `/etc/snmp/snmpd.conf`.

NOTE: Files for ZABBIX agent in the "Goodies" directory are also included.

If you want to install an "all-in-one" only change passwords, IP addresses and mail domains and *dhcp/dnsmasq* info appearing in the configuration file.

After updating its configuration file, run at the root of directory script the following command:

```
# ./main-installer.sh install
```

The installer asks if you want to proceed (y/n).

If you run the installer with the additional parameter * auto *, it will run automatically without asking you confirmation. Example:

```
# ./main-installer.sh install auto
```

You can save all outputs produced by the installer using the tool `tee`. Example:

```bash
./main-installer.sh install | tee -a /var/log/my_log_de_install.log
```

## Controlling the installer behavior

As mentioned before, you can use this installer for more complex designs. Example:

* A single all-in-one monolithic server *
* A cloud with a controller-compute and several compute nodes *
* A cloud with a pure controller and several compute nodes *

### Controller node:

If your controller node will include a compute service (controller +
compute, or an all-in-one server), the following variable in the configuration file must be set to “no”:

```bash
nova_without_compute="no"
```

If you use ceilometer in the controller, and likewise the controller includes compute service, the following variable must also be set to "no":

```bash
ceilometer_without_compute="no"
```

However, if you are installing a "pure" controller (without compute service) set the following variables to "yes":

```bash
nova_without_compute="yes"
ceilometer_without_compute="yes"
```

### Compute nodes:

For the compute nodes, you must set to "yes" (this is mandatory) the installation variables for Nova and Neutron modules. The remaining modules (glance, cinder, horizon, trove, sahara and heat) must be set to "no". If you are using Ceilometer in the controller, you also must set it's installation variable to “yes” along with the ones for Nova and Neutron. In Addition, the following variables in sections of nova and neutron must be set to "yes":

```bash
nova_in_compute_node="yes"
neutron_in_compute_node="yes"
```

And if you are using ceilometer also the following variable must be "yes" for compute nodes:

```bash
ceilometer_in_compute_node="yes"
```

You must place the IP's for the services running in the controller (neutron, keystone, glance and cinder) and the Ip's for the Database and message broker backends. This is valid for either a controller or a compute:

```bash
novahost="Controller IP Address"
glancehost="Controller IP Address"
cinderhost="Controller IP Address"
neutronhost="Controller IP Address"
keystonehost="Controller IP Address"
messagebrokerhost="Message Broker IP Address"
dbbackendhost="Database Server IP Address"
vncserver_controller_address | spiceserver_controller_address = "Controller IP Address"
```

If you use ceilometer, the same case applies:

```bash
ceilometerhost = "Controller IP Address"
```

For compute nodes, you must place the following variables with the IP in the compute node:

```bash
neutron_computehost = "Compute Host IP Address"
nova_computehost = "Compute Host IP Address "
```

### Database Backend

The installer has the ability to install and configure the database service, and also it will create all the databases. This is completely controllable by the configuration file through the following variables:

```bash
dbcreate = "yes"
dbinstall = "yes"
dbpopulate = "yes"
```

With these three options set to "yes", the database software is installed, will be configured and databases will be created using all the information contained in the configuration file.

> ** WARNING **: If you choose these options, you must ensure that there is
> NO database software previously installed or the process will fail.

By using our installation tool, you can choose to install and/or use between MySQL-based and PostgreSQL-based engines. In the specific case of Centos, we'll use MariaDB instead of MySQL.


If you prefer to “not install” any database software because you already have one installed somewhere else (a database farm), and also have the proper administrative access to the database engine, set the variables as follows:

```bash
dbcreate = "yes"
dbinstall = "no"
dbpopulate = "yes"
```

With this, the database software will not be installed, but it's up to you (or your * DBA *) to ensure you have full administrative access to create and modify databases in the selected backend.

If you do not want to install database software nor create databases (we assume that you already have previously created then in a farm or a separate server or even manually in the controller) set the three values "no":

```bash
dbcreate = "no"
dbinstall = "no"
dbpopulate = "no"
```

In any case, always remember to properly set the database-control variables inside the installer configuration file.


### RPC Messaging backend (Message Broker)

As part of the components to install and configure, the installer installs and configure the software for * AMQP * (the * Message Broker *). This step * IS * mandatory for a controller or * all-in-one * OpenStack server. If your server or servers have a message broker already installed, conflicts can occur that prevent the correct operation of the installation.

Again, the installer configuration file will control which AMPQ service to install and configure. You can choose from RabbitMQ and QPID. The installer will install and configure everything include the account and password that will be used by all OpenStack services to talk with the Message Broker Service.


### Console Manager (NOVNC / SPICEHTML5)

Through a configurable option in the installer configuration file (consoleflavor), you can choose between NoVNC and SpiceHTML5. If you want to eventually use SSL for the Dashboard, please leave the default (novnc) as it easier to configure with SSL.


### Trove

If you choose to install trove, this installation tool will install and configure all the software needed, but IT WILL NOT configure trove-ready images. That's part of your tasks as a Cloud Administrator.


### Scripts Help

This installer will place a OpenStack Services control script in the “/usr/local/bin” path:

```bash
openstack-control.sh OPTION
```

The script uses the following options:

1. **enable**: Enables the services to start at boot time.
2. **disable**: disable services start at boot time.
3. **start**: starts all services.
4. **stop**: stops all services.
5. **restart**: restart all services.
6. **status**: displays the status of all services.

NOTE: We used or best judgment to ensure the proper start/stop order in the openstack-control.sh script. That being said, you could benefit a lot by using this script to control you cloud instead of the order normally set by “init”, “systemctl” or “upstart”. A good choice can be to place the script inside rc.local file. Your choice.

The installer will place a script “openstack-log-cleaner.sh” in the path “/usr/local/bin” that have the ability to “clean” all OpenStack related logs.

This script is called during the final phase of installation to clean all logs before leaving the server installed and running for the very first time, but can also be used by you “Cloud Administrator” to clean all OpenStack related logs whenever you consider it necessary.

**IMPORTANT NOTE**: Again, We recommend using the openstack-control.sh script to initialize all OpenStack services!. Put all openstack services in "disable" state with "openstack-control.sh disable" and call the script with the "start" option from inside the /etc/rc.local file:

```bash
/usr/local/bin/openstack-control.sh start
```

This script must be included in every single OpenStack node (controller and compute nodes)


### STARTING VIRTUAL MACHINES AVOIDING I/O STORMS

If you suffer a total blackout and your cloud service goes completely down, and then try to start it including all virtual machines (instances), chances are that you will suffer a I/O storm. That can easily collapses all your servers or at least slow them down for a while.

We include a script called “openstack-vm-boot-start.sh” that you can use to start all your OpenStack VM's (instances) with a little timeout between each virtual machine. You need to include the name or UUID of the instances that you want to start automatically in the following file:

```bash
/etc/openstack-control-script-config/nova-start-vms.conf
```

Place the script in the rc.local file ONLY in the controller node.

NOTE: The names of the VMs must be obtained from "nova list" command.


### DNSMASQ

Neutron dhcp-agent uses **DNSMASQ** for IP assignation to the VM's (instances). We include a customized dnsmasq-control file with some samples that you can use to fine-tune your dhcp-agent:

```
/etc/dnsmasq-neutron.d/neutron-dnsmasq-extra.conf
```

There are commented examples in the file. Use these examples to pass options to
different instances of dnsmasq created for each subnet where you select the option to use * dhcp *.

Recommendation: Try to have a good **DNS** structure for your cloud.


### Installer modularization

While the main setup process "* main-installer.sh *" is responsible for calling each module of each installer component, these modules are really independent of one another, to the point that they can be called sequentially and manually by you. Is not the common case, but can be done. The normal order of execution for each module is as follows (assuming that all components will be installed):

* requeriments.sh
* messagebrokerinstall.sh
* databaseinstall.sh
* requeriments-extras.sh (only present for Ubuntu Server 14.04 LTS)
* keystoneinstall.sh
* swiftinstall.sh
* glanceinstall.sh
* cinderinstall.sh
* neutroninstall.sh
* novainstall.sh
* ceilometerinstall.sh
* heatinstall.sh
* troveinstall.sh
* saharainstall.sh
* snmpinstall.sh
* horizoninstall.sh
* postinstall.sh


Then again, we do not recommend to run those modules out of the main installer, unless of course you know exactly what are you doing.


### RECOMMENDATIONS FOR INSTALLATION IN CENTOS AND UBUNTU SERVER.

#### Centos 7:

1. Install Centos with the selection of packages for "Infrastructure Server". Make sure you have properly installed and configured both SSH and NTP. Ntpdate is also recommended. Again, a proper DNS infrastructure is very recommended.

2. Add the EPEL and RDO repositories (see "NOTES.txt").

3. Install and configure OpenVSWitch (again, see "NOTES.txt").

*WARNING*: OpenStack does not support MySQL lower than 5.5. See notes and take proper steps. If you use our installation tool in order to install database support, we will install MariaDB 5.5.x directly obtained from RDO repositories.

IMPORTANT NOTE: The installer disables Centos 7 SELINUX. We had found some bugs, specially when using PostgreSQL and with some scenarios with NOVA-API.

#### Ubuntu 14.04 LTS:

1. Install Ubuntu Server 14.04 LTS standard way and select as an additional package "OpenSSH Server". Install and configure the ntpd service. Also SSH. It is also recommended to use ntpdate.

2. Install and configure OpenVSWitch (see "NOTES.txt").

As you can see in all cases, NTP and SSH are very important. Fail to configure those services correctly, and prepare to have a live full of misery.


### Cinder:

If you are using CINDER with lvm-iscsi, be sure to have a free partition or disk to create a LVM called "cinder-volumes". Example (free disk /dev/sdc):

```bash
pvcreate /dev/sdc
vgcreate cinder-volumes /dev/sdc
```

Another example with an free /dev/sda3 partition:

```bash
pvcreate /dev/sda3
vgcreate cinder-volumes /dev/sda3
```

### Swift:

If you are going to use swift, remember to have the disk/partition to be used for swift mounted on a specific directory that also should be indicated in the Installer main confirutarion file (main-config.rc).

example:

Variable `swiftdevice ="d1"`

In the fstab "d1" must be mounted as follows:

```
/dev/sdc1 /srv/node/d1 ext4 acl,user_xattr 0 0
```

In this example, we assume that there is an already formatted "/dev/sdc1" partition. You MUST use a file system capable of ACL and USER_XATTR. That being said, we recommend EXT4 or XFS or similar file systems.


### Architecture:

Whether you use Centos or Ubuntu, you must choose to use 64 bits (amd64 / x86_64). Do not try to install OpenStack in 32 bits.


### NTP Service:

We cannot stress enough so VITAL it is to have all the servers in the OpenStack cloud properly time synchronized. Read the documentation of OpenStack to know more about it.


### Recommendations for Virtualbox.

You can use this installer inside a VirtualBox VM if you want to use it to practice and learn OpenStack. The VirtualBox VM should have a "minimum"  of 1GB's of RAM but for better results try to ensure 2GB's of RAM for the VM.


### Hardware recommendations for a VirtualBox VM:

Hard disks: one for the operating system (16 GB minimum's), one for
Cinder-Volumes and another for swift. At least 8GB's for each disk (SWITF and cinder-volumes). 
Network: three interfaces:
Interface 1 in NAT mode for Internet Access.
Interface 2 in "only host adapter” mode, “PROMISC option: all". Suggestion: Use vboxnet0 with the network 192.168.56.0/24 (disable dhcp at virtualbox) and assign the IP 192.168.56.2 to the interface (the IP 192.168.56.1 will be on the real machine).
Interface 3 in "only host adapter” mode, “PROMISC option: all". Suggestion: Use vboxnet1 with the network 192.168.57.0/24 (disable dhcp at virtualbox). This will be assigned to the VM's network inside OpenStack in the eth2 interface and IP range 192.168.57.0/24 (the IP 192.168.57.1 will be in the real machine).

Make the O/S installation using the first disk only (the second and third ones will be used for cinder-volumes and swift). Add the openstack repositories (remember to see **NOTES.txt**), make the proper changes inside the installer configuration file, create the cinder volume as follows:


```bash
pvcreate /dev/sdb
vgcreate cinder-volumes /dev/sdb
```

If you are using swift, create the partition on the third disk (/dev/sdc1) and mount it according to the notes in this document.

Make the installation indicating that the bridge Mapping (within main-config.rc) is:

```bash
bridge_mappings = "public: br-eth2"
```

Change IP in the `main-config.rc` to the IP assigned to the VM inside the network 192.168.57.0/24.

Run the installer.

enjoy:-)

You can enter the web server via the interface 192.168.56.x for
run OpenStack management tasks. I created the subnet in the range
of eth2 (192.168.57.0/24) and may enter the VM's OpenStack from
real machine that will interface 192.168.57.1.

From outside VirtualBox you can enter to the Horizon web Interface by using the vboxnet0 assigned IP (192.168.56.2) and to the OpenStack VM instances running inside vboxnet1 network (192.168.57.0/24).


### Uninstalling

The main script also has a parameter used to completely uninstall OpenStack:

```
# ./main-installer.sh uninstall
```
or

```
# ./main-installer.sh uninstall auto
```

The first way to call the uninstall process asks you "y/n" for continue or abort, but if you called the script with the extra "auto" setting, it will run without asking anything from you and basically will erase all that it previously installed.

It is important to note that if the dbinstall="yes" option is used inside the installer configuration file, the uninstaller will remove not only the database engine but also all created databases.

If you want to NOT REMOVE the databases created before, modify the "main-config.rc" and set the dbinstall option to “no”. This will make the preserve the databases.

WARNING: If you are not careful, could end up removing databases and losing anything that you would like to backup. Consider yourself warned!.

This is very convenient for a reinstall. If for some reason your OpenStack installation needs to be rebuilt without touching your databses, uninstall using dbinstall = "no" and when you are going to reinstall, place all database options in "no" to preserve both the engine and all its created databases:

```
dbcreate = "no"
dbinstall = "no"
dbpopulate = "no"
```

If your system has multiple nodes (controller / compute) use the
`main-config.rc` originally used to install each node in order to uninstall it.


### Goodies

In the * Goodies * directory you will find some scripts (each with their respective readme). You can use with those scripts as you see fit with your OpenStack installation. View the scripts and their respective "readme files" to better understand how to use them!.


### Endnotes

This installer is originally configured to use Neutron FLAT existing networks but can be easily modified by you before or even after install in order to use GRE. As a matter of facts, the author of this tool had used it before to create large VLAN based OpenStack installations with multiple VLAN's.

### END.-
