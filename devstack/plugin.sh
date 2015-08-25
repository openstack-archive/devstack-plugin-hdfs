#!/bin/bash

# devstack/plugin.sh
# Triggers hdfs specific functions to install and configure HDFS

# Dependencies:
#
# - ``functions`` file

# ``stack.sh`` calls the entry points in this order:
#
# - install_hdfs
# - configure_hdfs
# - start_hdfs
# - stop_hdfs
# - cleanup_hdfs

# Defaults
# --------

HDFS_PLUGIN_DIR=$(readlink -f $(dirname ${BASH_SOURCE[0]}))
HDFS_PLUGIN_LIB_DIR=$HDFS_PLUGIN_DIR/lib
HDFS_PLUGIN_HADOOP_DIR=$HDFS_PLUGIN_DIR/hadoop

HADOOP_VERSION=${HADOOP_VERSION:-"2.7.1"}

# Initializing gluster specific functions
source $HDFS_PLUGIN_LIB_DIR/hdfs-functions.sh

if [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
    echo_summary "Installing HDFS"
    install_hdfs
    echo_summary "Configuring HDFS"
    configure_hdfs
    echo_summary "Starting HDFS"
    start_hdfs
    echo_summary "Testing HDFS"
    test_hdfs
fi

if [[ "$1" == "unstack" ]]; then
    stop_hdfs
fi

if [[ "$1" == "clean" ]]; then
    cleanup_hdfs
fi

## Local variables:
## mode: shell-script
## End:
