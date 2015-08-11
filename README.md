# devstack-plugin-hdfs
The plugin would configure HDFS, and configure Manila to use it as its backend.

# Goals

* To install HDFS packages
* Configures Manila with HDFS backend

# How to use

* Add this repo as an external repository to localrc::

     [[local|localrc]]
     enable_plugin hdfs https://github.com/openstack/devstack-plugin-hdfs

* run "stack.sh"
