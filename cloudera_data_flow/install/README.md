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
