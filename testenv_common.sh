PREFIX=$WORKSPACE/jenkins-deployment-$BUILD_NUMBER
OVIRT_CONTRIB=/usr/share/ovirttestenv/
TEMPLATE_REPO=$WORKSPACE/testenv-template-repositories/ci-repo.json

testenv_run () {
	set -e
	chmod g+x $WORKSPACE

	# Checkout the correct refs for vdsm and engine:
	if [ ! -z $VDSM_HEAD ]
	then
	    cd $WORKSPACE/vdsm
	    git fetch origin $VDSM_HEAD && git checkout FETCH_HEAD
	    VDSM_PATH=$WORKSPACE/vdsm
	fi

	if [ ! -z $ENGINE_HEAD ]
	then
	    cd $WORKSPACE/ovirt-engine
	    git fetch origin $ENGINE_HEAD && git checkout FETCH_HEAD
	    ENGINE_PATH=$WORKSPACE/ovirt-engine
	fi

	# Create $PREFIX for current run
	testenvcli init \
	    $PREFIX	\
	    $VIRT_CONFIG \
	    --template-repo=$TEMPLATE_REPO
	echo '[INIT_OK] Initialized successfully, need cleanup later'

	# Build RPMs
	cd $PREFIX
	testenvcli ovirt reposetup \
	    --engine-dir=$ENGINE_PATH \
	    --vdsm-dir=$VDSM_PATH

	# Start VMs
	testenvcli start

	# Install RPMs
	testenvcli ovirt deploy \
	    $DEPLOY_SCRIPTS \
	    $OVIRT_CONTRIB/setup_scripts

	testenvcli ovirt engine-setup \
	    --config=$ANSWER_FILE

	# Start testing
	testenvcli ovirt runtest $OVIRT_CONTRIB/test_scenarios/bootstrap.py
	testenvcli ovirt runtest $OVIRT_CONTRIB/test_scenarios/create_clean_snapshot.py
	testenvcli ovirt runtest $OVIRT_CONTRIB/test_scenarios/basic_sanity.py
}
