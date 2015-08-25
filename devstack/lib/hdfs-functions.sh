#!/bin/bash

# devstack/hdfs-functions.sh
# Functions to control the installation and configuration of the HDFS

# Installs the requested version of hdfs, controled by 'HADOOP_VERSION'
# Triggered from devstack/plugin.sh as part of devstack "install"
function install_hdfs {
    # install nessary packages
    install_package openssh-server

    # Set ssh with no password
    if [[ ! -e ~/.ssh/id_rsa.pub ]]; then
        ssh-keygen -q -N '' -t rsa -f  ~/.ssh/id_rsa
    fi
    cat  ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

    if [[ -e ~/.ssh/known_hosts ]]; then
        ssh-keygen -R 127.0.0.1
        ssh-keygen -R 0.0.0.0
    fi
    $HDFS_PLUGIN_LIB_DIR/autossh.sh "ssh-copy-id -i 127.0.0.1"
    $HDFS_PLUGIN_LIB_DIR/autossh.sh "ssh-copy-id -i 0.0.0.0"

    if [[ -z $JAVA_HOME ]]; then
        install_package openjdk-7-jre openjdk-7-jdk
        # Export JAVA_HOME
        sed -i '1 s/^/export JAVA_HOME=\/usr\/lib\/jvm\/java-7-openjdk-amd64\n/' ~/.bashrc
        source ~/.bashrc
    fi

    ### download hadoop
    if [[ ! -e $HDFS_PLUGIN_DIR/hadoop-$HADOOP_VERSION.tar.gz ]]; then
        wget -P $HDFS_PLUGIN_DIR/ http://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
    fi
    # untar the package
    tar -zxf $HDFS_PLUGIN_DIR/hadoop-$HADOOP_VERSION.tar.gz -C $HDFS_PLUGIN_DIR/
    mv $HDFS_PLUGIN_DIR/hadoop-$HADOOP_VERSION $HDFS_PLUGIN_DIR/hadoop
}

# configure_hdfs() - Set config files, create data dirs, etc
function configure_hdfs {
    # edit core-site.xml & hdfs-site.xml
    cp $HDFS_PLUGIN_LIB_DIR/template/* $HDFS_PLUGIN_HADOOP_DIR/etc/hadoop/

    path=${HDFS_PLUGIN_DIR//\//__slashplaceholder__}

    sed -i "s/__PLACEHOLDER__/$path/g" $HDFS_PLUGIN_HADOOP_DIR/etc/hadoop/hdfs-site.xml
    sed -i 's/__slashplaceholder__/\//g' $HDFS_PLUGIN_HADOOP_DIR/etc/hadoop/hdfs-site.xml

    # formate namenode
    $HDFS_PLUGIN_HADOOP_DIR/bin/hdfs namenode -format
}

# start_hdfs() - Start running processes
function start_hdfs {
    # start
    $HDFS_PLUGIN_HADOOP_DIR/sbin/start-dfs.sh

    # add hadoop/bin to PATH
    ori_path=$PATH:$HDFS_PLUGIN_HADOOP_DIR/bin
    no_slash_path=${ori_path//\//__slashplaceholder__}
    new_path=${no_slash_path//\:/__colonplaceholder__}
    sed -i "1 s/^/PATH=${new_path}\n/" ~/.bashrc
    sed -i 's/__slashplaceholder__/\//g'  ~/.bashrc
    sed -i 's/__colonplaceholder__/\:/g'  ~/.bashrc
    source ~/.bashrc
}

# test_hdfs() - Testing HDFS
function test_hdfs {
    cat ~/.bashrc
    echo $PATH
    source ~/.bashrc
    echo $PATH

    hdfs fsck /
}

# Stop running hdfs service
# Triggered from devstack/plugin.sh as part of devstack "unstack"
function stop_hdfs {
    if [[ -d $HDFS_PLUGIN_HADOOP_DIR ]]; then
        $HDFS_PLUGIN_HADOOP_DIR/sbin/stop-dfs.sh
        rm -rf $HDFS_PLUGIN_HADOOP_DIR
    fi

    line=`grep -rn "export PATH=.*hadoop/bin" ~/.bashrc | awk -F: '{print $1}'`
    if [[ -n $line ]]; then
        sed -i "${line}d" ~/.bashrc
    fi
}

# Cleanup hdfs
# Triggered from devstack/plugin.sh as part of devstack "clean"
function cleanup_hdfs {
    rm -f $HDFS_PLUGIN_DIR/hadoop-$HADOOP_VERSION.tar.gz
}
