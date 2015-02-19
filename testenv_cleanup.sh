#!/bin/bash
source $WORKSPACE/testenv-ovirt-jenkins/testenv_common.sh

cd $PREFIX
testenvcli cleanup
