PREFIX=$WORKSPACE/jenkins-deployment-$BUILD_NUMBER
OVIRT_CONTRIB=/usr/share/ovirttestenv/
TEMPLATES_CLONE_URL="ssh://templates@66.187.230.22/~templates/templates.git"

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

	# Clone templates
	if [ ! -d $WORKSPACE/templates ]
	then
	    /usr/share/testenv/sync_templates.py --create $TEMPLATES_CLONE_URL $WORKSPACE/templates
	else
	    /usr/share/testenv/sync_templates.py $WORKSPACE/templates
	fi

	# Create $PREFIX for current run
	testenvcli init \
	    $PREFIX	\
	    $VIRT_CONFIG \
	    --templates-dir=$WORKSPACE/templates
	echo '[INIT_OK] Initialized successfully, need cleanup later'

	# Build RPMs
	cd $PREFIX
	testenvcli ovirt reposetup \
	    --rpm-repo=$REPOSYNC_DIR \
	    --reposync-yum-config=$REPOSYNC_YUM_CONFIG \
	    --engine-dir=$ENGINE_PATH \
	    --engine-dist=$ENGINE_DIST \
	    --vdsm-dir=$VDSM_PATH \
	    --vdsm-dist=$VDSM_DIST

	# Start VMs
	testenvcli start

	# Install RPMs
	testenvcli ovirt deploy $DEPLOY_SCRIPTS \
	    $OVIRT_CONTRIB/setup_scripts

	# Start testing
	testenvcli ovirt runtest $OVIRT_CONTRIB/test_scenarios/bootstrap.py
	testenvcli ovirt snapshot --no-restore ovirt-clean
	testenvcli ovirt runtest $OVIRT_CONTRIB/test_scenarios/basic_sanity.py
}
