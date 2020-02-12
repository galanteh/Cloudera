
# Installing Cloudera Dataflow

In the setup_cdf.cfg you will find the trial versions of Cloudera Data Flow Stack.

## How to run it?

1) Copy the setup_cdf.sh and setup_cdf.cdf to the machine that will host Cloudera Manager
Sample:
    ```
     scp setup_cdf.* root@<your-machine>:/root
     ssh root@<your-machine>
     chmod 777 setup_cdf.sh
    ```

2) Run it in the server

    ```
     sudo setup_cdf.sh
    ```
# Installing SRM
## Configuration specs
### How to configure the SRM process?

#### Architecture
Please, check that we need to install an SRM Driver per Broker. SRM Service can be allocated with the CM host. 

![Architecture](https://github.com/galanteh/Cloudera/blob/master/cloudera_data_flow/install/images/SRM2.png?raw=true)

#### Configuration of Primary and Secondary
![enter image description here](https://github.com/galanteh/Cloudera/blob/master/cloudera_data_flow/install/images/SRM1.png?raw=true)

The options that we should care about are:

- clusters: We should use some alias of each cluster like primary and secondary. 
    ```
    primary, secondary
    ```
- streams.replication.manager.config: Here we define where is the list of brokers of each kafka 
    ```
    primary.bootstrap.servers=broker1:9092,broker2:9092,broker3:9092
    secondary.bootstrap.servers=broker4:9092,broker5:9092,broker6:9092
    primary->backup=true
    ```
- streams.replication.manager.driver.target.cluster: where do we need to write the collected information. In this example, secondary.


# Troubleshooting

## SMM 

### Kafka Cluster Name
The Kafka cluster name is case sensitive. If you get this error listed on /var/log/streams-messaging-manager/streams-messaging-manager-ui.err, then you will need to check the property of SMM called cm.metrics.service.name. 

![Error in the log about the cluster name](https://raw.githubusercontent.com/galanteh/Cloudera/master/cloudera_data_flow/install/images/Error_cluster_name.png)

![Error in CM about the Cluster name](https://raw.githubusercontent.com/galanteh/Cloudera/master/cloudera_data_flow/install/images/SMM_Error_cluster_name.png)

Please, refer to the documentation of SMM on how to extract the real Kafka Service name: [Obtain the Kafka service name
](https://docs.cloudera.com/csp/2.0.1/deployment/topics/csp-obtain-kafka-service-name.html) 





