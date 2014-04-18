#!/bin/bash


# set -x

source config.sh

echo
echo "All steps defined in config.sh:"
for step in ${steps[@]}
do
	echo "    "$step
done

echo
echo "All steps's scripts:"
for f in $(ls steps)
do
	echo "    "$f
done

echo
echo "Existing scripts for declared steps:"
for step in ${steps[@]}
do
	if [[ -f steps/${step}.sh ]]
	then
		echo "    "$step" ("$(${CLFS_SCRIPTS_DIR}/step_helper.sh $step get_substep_list)")"
	fi
done

mkdir -p ${CLFS_DISTFILES_DIR}
mkdir -p ${CLFS_WORK_DIR}
mkdir -p ${CLFS_SYSROOT_PREFIX}
mkdir -p ${CLFS_CROSSTOOLS_PREFIX}
mkdir -p ${CLFS_BUILD_DIR}
mkdir -p ${CLFS_TARGET_ROOTFS}

export FORCE_REBUILD=""

for arg in $@
do
	if [ "$arg" == "-f" -o "$arg" == "--force" ]
	then
		export FORCE_REBUILD="1"
	fi
done

echo
echo "Starting building step by step..."
echo

for step in ${steps[@]}
do
	if [[ -f steps/${step}.sh ]]
	then
		substeps=$(${CLFS_SCRIPTS_DIR}/step_helper.sh $step get_substep_list)

		mkdir -p ${CLFS_BUILD_DIR}/${step}/logs
		mkdir -p ${CLFS_BUILD_DIR}/${step}/flags

		for substep in $substeps
		do
			echo -n "    "$step"."$substep" : "

			if [ -f ${CLFS_BUILD_DIR}/${step}/flags/$substep.success -a ! "$FORCE_REBUILD" == "1" ]
			then
				echo "already done - skipping"
			else
				echo -n "started ... "

				rm -f ${CLFS_BUILD_DIR}/${step}/flags/$substep.failed
				rm -f ${CLFS_BUILD_DIR}/${step}/flags/$substep.success

				_PREV_PWD=$PWD
				cd ${CLFS_BUILD_DIR}/${step}

				${CLFS_SCRIPTS_DIR}/step_helper.sh $step $substep > ${CLFS_BUILD_DIR}/${step}/logs/$substep.txt 2>&1

				cd $_PREV_PWD

				if [[ $? == "0" ]]
				then
					echo "successfully finished"
					touch ${CLFS_BUILD_DIR}/${step}/flags/$substep.success
				else
					echo "failed"
					touch ${CLFS_BUILD_DIR}/${step}/flags/$substep.failed
					exit 1
				fi
			fi


		done
	fi
done





echo
