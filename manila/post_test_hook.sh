#!/bin/bash -xe
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# This script is executed inside post_test_hook function in devstack gate.
# First argument ($1) expects 'multibackend' as value for setting appropriate
# tempest conf opts, all other values will assume singlebackend installation.

sudo chown -R jenkins:stack $BASE/new/tempest
sudo chown -R jenkins:stack $BASE/data/tempest
sudo chmod -R o+rx $BASE/new/devstack/files

# Import devstack functions 'iniset'
source $BASE/new/devstack/functions

export BACKENDS_NAMES="HDFS1"
iniset $BASE/new/tempest/etc/tempest.conf share enable_protocols hdfs
iniset $BASE/new/tempest/etc/tempest.conf share storage_protocol HDFS
iniset $BASE/new/tempest/etc/tempest.conf share enable_user_rules_for_protocols hdfs

iniset $BASE/new/tempest/etc/tempest.conf share backend_names $BACKENDS_NAMES

# Set two retries for CI jobs
iniset $BASE/new/tempest/etc/tempest.conf share share_creation_retry_number 2

# Suppress errors in cleanup of resources
SUPPRESS_ERRORS=${SUPPRESS_ERRORS_IN_CLEANUP:-True}
iniset $BASE/new/tempest/etc/tempest.conf share suppress_errors_in_cleanup $SUPPRESS_ERRORS

# Enable multi_backend tests
RUN_MANILA_MULTI_BACKEND_TESTS=${RUN_MANILA_MULTI_BACKEND_TESTS:-True}
iniset $BASE/new/tempest/etc/tempest.conf share multi_backend $RUN_MANILA_MULTI_BACKEND_TESTS
iniset $BASE/new/tempest/etc/tempest.conf share backend_names $MANILA_ENABLED_BACKENDS

# Disable manage/unmanage tests
RUN_MANILA_MANAGE_TESTS=${RUN_MANILA_MANAGE_TESTS:-False}
iniset $BASE/new/tempest/etc/tempest.conf share run_manage_unmanage_tests $RUN_MANILA_MANAGE_TESTS

# Disable extend tests
if [ $ZUUL_BRANCH = "master" ]
then
    RUN_MANILA_EXTEND_TESTS=${RUN_MANILA_EXTEND_TESTS:-True}
else
    RUN_MANILA_EXTEND_TESTS=${RUN_MANILA_EXTEND_TESTS:-False}
fi
iniset $BASE/new/tempest/etc/tempest.conf share run_extend_tests $RUN_MANILA_EXTEND_TESTS

# Disable shrink tests
RUN_MANILA_SHRINK_TESTS=${RUN_MANILA_SHRINK_TESTS:-False}
iniset $BASE/new/tempest/etc/tempest.conf share run_shrink_tests $RUN_MANILA_SHRINK_TESTS

# Disable multi_tenancy tests
iniset $BASE/new/tempest/etc/tempest.conf share multitenancy_enabled False

# Enable snapshot tests
RUN_MANILA_SNAPSHOT_TESTS=${RUN_MANILA_SNAPSHOT_TESTS:-True}
iniset $BASE/new/tempest/etc/tempest.conf share run_snapshot_tests $RUN_MANILA_SNAPSHOT_TESTS

# Disable enable_ip_rules_for_protocols
iniset $BASE/new/tempest/etc/tempest.conf share enable_ip_rules_for_protocols

# Disable consistency_group_tests
RUN_MANILA_CONSISTENCY_GROUP_TESTS=${RUN_MANILA_CONSISTENCY_GROUP_TESTS:-False}
iniset $BASE/new/tempest/etc/tempest.conf share run_consistency_group_tests $RUN_MANILA_CONSISTENCY_GROUP_TESTS

# let us control if we die or not
set +o errexit
cd $BASE/new/tempest

export MANILA_TEMPEST_CONCURRENCY=${MANILA_TEMPEST_CONCURRENCY:-12}
export MANILA_TESTS=${MANILA_TESTS:-'manila_tempest_tests.tests.api*'}

# check if tempest plugin was installed corretly
echo 'import pkg_resources; print list(pkg_resources.iter_entry_points("tempest.test_plugins"))' | python

echo "Running tempest manila test suites"
sudo -H -u jenkins tox -eall-plugin $MANILA_TESTS -- --concurrency=$MANILA_TEMPEST_CONCURRENCY
