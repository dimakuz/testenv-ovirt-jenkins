#!/bin/bash -x
source $WORKSPACE/testenv-ovirt-jenkins/testenv_common.sh

VIRT_CONFIG=$OVIRT_CONTRIB/config/virt/centos6.json
ANSWER_FILE=$OVIRT_CONTRIB/config/answer-files/el6_master.conf

testenv_run
