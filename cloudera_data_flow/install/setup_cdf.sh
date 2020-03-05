#! /bin/bash
source setup_cdf.cfg

colblk='\033[0;30m' # Black - Regular
colred='\033[0;31m' # Red
colgrn='\033[0;32m' # Green
colylw='\033[0;33m' # Yellow
colpur='\033[0;35m' # Purple
colrst='\033[0m'    # Text Reset

verbosity=5

### verbosity levels
silent_lvl=0
crt_lvl=1
err_lvl=2
wrn_lvl=3
ntf_lvl=4
inf_lvl=5
dbg_lvl=6

## esilent prints output even in silent mode
function esilent () { verb_lvl=$silent_lvl elog "$@" ;}
function enotify () { verb_lvl=$ntf_lvl elog "$@" ;}
function eok ()    { verb_lvl=$ntf_lvl elog "SUCCESS - $@" ;}
function ewarn ()  { verb_lvl=$wrn_lvl elog "${colylw}WARNING${colrst} - $@" ;}
function einfo ()  { verb_lvl=$inf_lvl elog "${colwht}INFO${colrst} ---- $@" ;}
function edebug () { verb_lvl=$dbg_lvl elog "${colgrn}DEBUG${colrst} --- $@" ;}
function eerror () { verb_lvl=$err_lvl elog "${colred}ERROR${colrst} --- $@" ;}
function ecrit ()  { verb_lvl=$crt_lvl elog "${colpur}FATAL${colrst} --- $@" ;}
function edumpvar () { for var in $@ ; do edebug "$var=${!var}" ; done }
function elog() {
        if [ $verbosity -ge $verb_lvl ]; then
                datestring=`date +"%Y-%m-%d %H:%M:%S"`
                echo -e "$datestring - $@"
        fi
}


einfo "-- Configure and optimize the OS"
sudo echo never > /sys/kernel/mm/transparent_hugepage/enabled
sudo echo never > /sys/kernel/mm/transparent_hugepage/defrag
sudo echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.d/rc.local
sudo echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag" >> /etc/rc.d/rc.local
# add tuned optimization https://www.cloudera.com/documentation/enterprise/6/6.2/topics/cdh_admin_performance.html
sudo echo  "vm.swappiness = 1" >> /etc/sysctl.conf
sudo sysctl vm.swappiness=1
sudo timedatectl set-timezone UTC

einfo "-- Install Java OpenJDK8 and other tools"
sudo yum install -y java-1.8.0-openjdk-devel vim wget curl git bind-utils
sudo echo "server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4" >> /etc/chrony.conf
sudo systemctl restart chronyd

einfo "-- Configure networking"
PUBLIC_IP=$(curl -s https://api.ipify.org/)
sudo hostnamectl set-hostname `hostname -f`
sudo echo "`hostname -I` `hostname`" >> /etc/hosts
sudo sed -i "s/HOSTNAME=.*/HOSTNAME=`hostname`/" /etc/sysconfig/network
sudo iptables-save > ~/firewall.rules
sudo systemctl disable firewalld
sudo systemctl stop firewalld
sudo sysctl -w vm.swappiness=1
sudo setenforce 0
sudo sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

einfo "-- Install CM and MariaDB repo"
sudo wget $CLOUDERA_REPO -P /etc/yum.repos.d/

## MariaDB 10.1
sudo bash -c "cat - >/etc/yum.repos.d/MariaDB.repo <<EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF"

sudo yum clean all
sudo rm -rf /var/cache/yum/
sudo yum repolist

sudo yum install -y cloudera-manager-daemons cloudera-manager-agent cloudera-manager-server
sudo yum install -y MariaDB-server MariaDB-client
sudo cat mariadb.config > /etc/my.cnf

einfo "--Enable and start MariaDB"
sudo systemctl enable mariadb
sudo systemctl start mariadb

einfo "-- Install JDBC connector"
sudo wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.46.tar.gz -P ~
sudo tar zxf ~/mysql-connector-java-5.1.46.tar.gz -C ~
sudo mkdir -p /usr/share/java/
sudo cp ~/mysql-connector-java-5.1.46/mysql-connector-java-5.1.46-bin.jar /usr/share/java/mysql-connector-java.jar

einfo "-- Create DBs required by CM"
sudo mysql -u root << EOF
CREATE DATABASE scm DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON scm.* TO 'scm'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE amon DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON amon.* TO 'amon'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE rman DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON rman.* TO 'rman'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE hue DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON hue.* TO 'hue'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE metastore DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON metastore.* TO 'hive'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE sentry DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON sentry.* TO 'sentry'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE nav DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON nav.* TO 'nav'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE navms DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON navms.* TO 'navms'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE oozie DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON oozie.* TO 'oozie'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE efm DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON efm.* TO 'efm'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE nifireg DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON nifireg.* TO 'nifireg'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE streamsmsgmgr DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON streamsmsgmgr.* TO 'streamsmsgmgr'@'%' IDENTIFIED BY 'cloudera';

CREATE DATABASE registry DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL ON registry.* TO 'registry'@'%' IDENTIFIED BY 'cloudera';

EOF

einfo "-- Secure MariaDB"
sudo mysql -u root << EOF
UPDATE mysql.user SET Password=PASSWORD('cloudera') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

einfo "-- Prepare CM database 'scm'"
sudo /opt/cloudera/cm/schema/scm_prepare_database.sh mysql scm scm cloudera

einfo " ======  Install CSDs ====== "
einfo "-- Install CFM CSDs"
sudo wget $NIFI_CSD_JAR -P /opt/cloudera/csd/
sudo wget $NIFI_CA_CSD_JAR -P /opt/cloudera/csd/
sudo wget $NIFI_REGISTRY_CSD_JAR -P /opt/cloudera/csd/

einfo "-- Install SCHEMA REGISTRY CSDs"
sudo wget $SCHEMAREG_CSD_JAR -P /opt/cloudera/csd/

einfo "-- Install SMM CSDs"
sudo wget $SMM_CSD_JAR -P /opt/cloudera/csd/

einfo "-- Install SMM CSDs"
sudo wget $SRM_CSD_JAR  -P /opt/cloudera/csd/

einfo "-- Install Flink CSDs"
sudo  wget $FLINK_CSD_JAR  -P /opt/cloudera/csd/

sudo chown cloudera-scm:cloudera-scm /opt/cloudera/csd/*
sudo chmod 644 /opt/cloudera/csd/*

einfo " ======  Install Parcels ====== "
einfo "-- Install CFM Parcels"
sudo wget $CFM_PARCEL -P  /opt/cloudera/parcel-repo
sudo wget $CFM_PARCEL_SHA -P  /opt/cloudera/parcel-repo

einfo "-- Install SCHEMA REGISTRY Parcels"
sudo wget $SCHEMAREG_PARCEL -P  /opt/cloudera/parcel-repo
sudo wget $SCHEMAREG_PARCEL_SHA -P  /opt/cloudera/parcel-repo

einfo "-- Install SMM Parcels"
sudo wget $SMM_PARCEL -P /opt/cloudera/parcel-repo
sudo wget $SMM_PARCEL_SHA -P  /opt/cloudera/parcel-repo

einfo "-- Install SRM Parcels"
sudo wget $SRM_PARCEL  -P /opt/cloudera/parcel-repo
sudo wget $SRM_PARCEL_SHA  -P /opt/cloudera/parcel-repo

einfo "-- Install Flink Parcels"
sudo wget $FLINK_PARCEL -P /opt/cloudera/parcel-repo
sudo wget $FLINK_PARCEL_SHA -P /opt/cloudera/parcel-repo

sudo chown cloudera-scm:cloudera-scm /opt/cloudera/parcel-repo/*
sudo chmod 644 /opt/cloudera/parcel-repo/*

einfo "-- Install SMM Prerequisites on the CM node"
sudo yum install -y gcc-c++ make
sudo curl -sL https://rpm.nodesource.com/setup_10.x | sudo -E bash -
sudo yum install nodejs -y
npm install forever -g

einfo "-- Install Python3.6"
sudo yum install -y epel-release
sudo yum install -y https://centos7.iuscommunity.org/ius-release.rpm
sudo yum install -y python36u python36u-libs python36u-devel python36u-pip
sudo yum install -y python36u-setuptools
sudo easy_install-3.6 pip
sudo python3.6 -m pip install --upgrade pip setuptools wheel
sudo python3.6 -m pip install cm_client

einfo "-- Start CM, it takes about 2 minutes to be ready"
sudo systemctl start cloudera-scm-server

einfo "-- Checking that CM is up & running"
while [ -z $(curl -s -X GET -u "admin:admin"  http://localhost:7180/api/version) ];
    do
    einfo " Waiting 10s for CM to come up..";
    sleep 10;
done

if [ ! -z $(curl -s -X GET -u "admin:admin"  http://localhost:7180/api/version) ]; then
    einfo "-- CM is successfully installed. Point your browser at http://$PUBLIC_IP:7180"
fi
