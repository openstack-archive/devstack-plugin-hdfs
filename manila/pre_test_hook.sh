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

# This script is executed inside pre_test_hook function in devstack gate.

localconf=$BASE/new/devstack/local.conf

echo "[[local|localrc]]" >> $localconf
echo "DEVSTACK_GATE_TEMPEST_ALLOW_TENANT_ISOLATION=1" >> $localconf
echo "API_RATE_LIMIT=False" >> $localconf
echo "TEMPEST_SERVICES+=,manila" >> $localconf

echo "MANILA_USE_DOWNGRADE_MIGRATIONS=True" >> $localconf

# NOTE(vponomaryov): enable following only for 'scenario' tests if such added.
echo "MANILA_SERVICE_IMAGE_ENABLED=False" >> $localconf

# Enabling isolated metadata in Neutron is required because
# Tempest creates isolated networks and created vm's in scenario tests don't
# have access to Nova Metadata service. This leads to unavailability of
# created vm's in scenario tests.
echo 'ENABLE_ISOLATED_METADATA=True' >> $localconf

if [[ -f $BASE/new/manila/contrib/ci/common.sh ]]; then
    # M+ branch
    source $BASE/new/manila/contrib/ci/common.sh
fi

# Print current Tempest status
git status
