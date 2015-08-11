#!/bin/bash

# devstack/hdfs-functions.sh
# Functions to control the installation and configuration of the HDFS

# Installs the requested version of hdfs, controled by 'HADOOP_VERSION'
# Triggered from devstack/plugin.sh as part of devstack "install"
function install_hdfs {
    # install nessary packages
    install_package openssh-server expect

    # Set ssh with no password
    if [[ ! -e $DEST/.ssh/id_rsa.pub ]]; then
        ssh-keygen -q -N '' -t rsa -f  $DEST/.ssh/id_rsa
    fi
    cat  $DEST/.ssh/id_rsa.pub >> $DEST/.ssh/authorized_keys

    if [[ -z $JAVA_HOME ]]; then
        install_package openjdk-7-jre openjdk-7-jdk
        # Export JAVA_HOME
        sed -i '1 s/^/export JAVA_HOME=\/usr\/lib\/jvm\/java-7-openjdk-amd64\/\n/' ~/.bashrc
        source ~/.bashrc
    fi

    ### download hadoop
    if [[ ! -e $HDFS_PLUGIN_DIR/hadoop-$HADOOP_VERSION.tar.gz ]]; then
        wget -P $HDFS_PLUGIN_DIR http://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
    fi
    # untar the package
    tar -zxvf $HDFS_PLUGIN_DIR/hadoop-$HADOOP_VERSION.tar.gz -C $HDFS_PLUGIN_DIR/
    mv $HDFS_PLUGIN_DIR/hadoop-$HADOOP_VERSION/ $HDFS_PLUGIN_DIR/hadoop

    # edit core-site.xml & hdfs-site.xml
    cp $HDFS_PLUGIN_LIB_DIR/template/* $HDFS_PLUGIN_HADOOP_DIR/etc/hadoop/

    path=${HDFS_PLUGIN_DIR//\//@}

    sed -i "s/__PLACEHOLDER__/$path/g" $HDFS_PLUGIN_HADOOP_DIR/etc/hadoop/hdfs-site.xml
    sed -i 's/@/\//g' $HDFS_PLUGIN_HADOOP_DIR/etc/hadoop/hdfs-site.xml

    # formate namenode
    $HDFS_PLUGIN_HADOOP_DIR/bin/hdfs namenode -format

    # start namenode and datanode
    $HDFS_PLUGIN_LIB_DIR/start_hdfs.sh $HDFS_PLUGIN_HADOOP_DIR/sbin/start-dfs.sh
}

# Stop running hdfs service
# Triggered from devstack/plugin.sh as part of devstack "unstack"
function stop_hdfs {
    $HDFS_PLUGIN_HADOOP_DIR/sbin/stop-dfs.sh
    rm -rf $HDFS_PLUGIN_HADOOP_DIR

}

# Cleanup hdfs
# Triggered from devstack/plugin.sh as part of devstack "clean"
function cleanup_hdfs {
    rm -f $HDFS_PLUGIN_DIR/hadoop-$HADOOP_VERSION.tar.gz
}
