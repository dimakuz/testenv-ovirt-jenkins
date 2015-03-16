#!/bin/bash -x
source $WORKSPACE/testenv-ovirt-jenkins/testenv_common.sh

ENGINE_DIST=el7
VDSM_DIST=el7
REPOSYNC_YUM_CONFIG=$OVIRT_CONTRIB/config/repos/ovirt-master-snapshot-external.repo
REPOSYNC_DIR=$WORKSPACE/ovirt-repo
VIRT_CONFIG=$OVIRT_CONTRIB/config/virt/rhel7.json
DEPLOY_SCRIPTS=$OVIRT_CONTRIB/config/deploy/scripts.json
ANSWER_FILE=$OVIRT_CONTRIB/config/answer-files/el7_master.conf

testenv_run
