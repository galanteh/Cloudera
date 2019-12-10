# Cloudera
Cloudera Scripts &amp; Utils

# Install Folder
## Cloudera Data Flow
We one script setup_cdf.sh with a configuration file called setup_cdf.cfg.

### Configuration file
We need to setup a configuration file, the following is a sample we we need to define variables that will define the installation of the CDF cluster with all the necessary parcels. 

```ini
CLOUDERA_REPO=<PAYWALL_URL>/cloudera-manager.repo

NIFI_CSD_JAR=<PAYWALL_URL>/NIFI-1.9.0.1.0.1.0-12.jar
NIFI_CA_CSD_JAR=<PAYWALL_URL>/NIFICA-1.9.0.1.0.1.0-12.jar
NIFI_REGISTRY_CSD_JAR=<PAYWALL_URL>/NIFIREGISTRY-0.3.0.1.0.1.0-12.jar
SMM_CSD_JAR=<PAYWALL_URL>/STREAMS_MESSAGING_MANAGER-2.1.0.jar
SRM_CSD_JAR=<PAYWALL_URL>/STREAMS_REPLICATION_MANAGER-1.0.0.jar
FLINK_CSD_JAR=<PAYWALL_URL>/FLINK-1.9.0-csa0.1.1-cdh6.3.0-1420238.jar

CFM_PARCEL=<PAYWALL_URL>/1.0.1.0/CFM-1.0.1.0-el7.parcel
CFM_PARCEL_SHA=<PAYWALL_URL>/1.0.1.0/CFM-1.0.1.0-el7.parcel.sha
SMM_PARCEL=<PAYWALL_URL>/STREAMS_MESSAGING_MANAGER-2.1.0.2.0.0.0-135-el7.parcel
SMM_PARCEL_SHA=<PAYWALL_URL>/STREAMS_MESSAGING_MANAGER-2.1.0.2.0.0.0-135-el7.parcel.sha
SRM_PARCEL=<PAYWALL_URL>/STREAMS_REPLICATION_MANAGER-1.0.0.2.0.0.0-135-el7.parcel
SRM_PARCEL_SHA=<PAYWALL_URL>/STREAMS_REPLICATION_MANAGER-1.0.0.2.0.0.0-135-el7.parcel.sha
FLINK_PARCEL=<PAYWALL_URL>/FLINK-1.9.0-csa0.1.1-cdh6.3.0-1512347-el7.parcel
FLINK_PARCEL_SHA=<PAYWALL_URL>/FLINK-1.9.0-csa0.1.1-cdh6.3.0-1512347-el7.parcel.sha
```



