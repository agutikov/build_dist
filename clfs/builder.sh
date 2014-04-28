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
		echo "    "$step" ("$(${CLFS_SCRIPTS_DIR}/helper.sh $step get_substep_list)")"
	fi
done

mkdir -p ${CLFS_DISTFILES_DIR}
mkdir -p ${CLFS_WORK_DIR}
mkdir -p ${CLFS_BUILD_DIR}
mkdir -p ${CLFS_TARGET_ROOTFS}
mkdir -p ${CLFS_CROSSTOOLS_PREFIX}
mkdir -p ${CLFS_SYSROOT_PREFIX}

export FORCE_REBUILD=""
export INTERACTIVE=""
export VERBOSE=""

for arg in $@
do
	if [ "$arg" == "-f" -o "$arg" == "--force" ]
	then
		export FORCE_REBUILD="1"
	elif [ "$arg" == "-i" -o "$arg" == "--interactive" ]
	then
		export INTERACTIVE="1"
	elif [ "$arg" == "-v" -o "$arg" == "--verbose" ]
	then
		export VERBOSE="1"
	fi
done

# $1 - question
# $2 - positive answer
# $3 - negative answer
function interactive_q()
{
	if [ "$INTERACTIVE" == "1" ]
	then
		RESP=""
		until [ "$RESP" == "$2" -o "$RESP" == "$3" -o "$RESP" == "exit" ]
		do
			echo $1
			read -p "> " RESP
		done

		if [ "$RESP" == "$2" ]
		then
			RESULT="1"
		elif [ "$RESP" == "exit" ]
		then
			echo "Stop building. Exit."
			exit 0
		elif [ "$RESP" == "$3" ]
		then
			RESULT=""
			echo
		fi
	fi
}

echo
echo "Starting building step by step..."
echo

for step in ${steps[@]}
do
	if [[ -f steps/${step}.sh ]]
	then

		RESULT="1"
		echo
		interactive_q "Starting step \"${step}\": 'c' - continue, 's' - skip, 'exit' - terminate" "c" "s"

		if [ ! "$RESULT" == "1" ]
		then
			echo "Skipping step \"${step}\"."
		else
			echo "Continue with step \"${step}\"..."

			substeps=$(${CLFS_SCRIPTS_DIR}/helper.sh $step get_substep_list)
			echo "    $step (${substeps[@]})"

			mkdir -p ${CLFS_BUILD_DIR}/${step}/logs
			mkdir -p ${CLFS_BUILD_DIR}/${step}/flags

			for substep in $substeps
			do
				RESULT="1"
				echo
				interactive_q "Starting substep \"$step.$substep\": 'c' - continue, 's' - skip, 'exit' - terminate" "c" "s"

				if [ ! "$RESULT" == "1" ]
				then
					echo "Skipping substep \"$step.$substep\"."
				else
					echo "Continue with substep \"$step.$substep\"..."

					BUILD_SUBSTEP=""

					if [ -f ${CLFS_BUILD_DIR}/${step}/flags/$substep.success -a ! "$FORCE_REBUILD" == "1" ]
					then
						RESULT=""
						echo
						echo "Substep is already done."
						interactive_q "What do you wish to do: 'f' - force rebuild, 's' - skip substep, 'exit' - terminate ?" "f" "s"

						if [ "$RESULT" == "1" ]
						then
							echo "Force rebuild substep \"$step.$substep\"."
							BUILD_SUBSTEP="1"
						else
							echo "Skipping substep \"$step.$substep\"."
						fi
					else
						BUILD_SUBSTEP="1"
					fi

					if [ "$BUILD_SUBSTEP" == "1" ]
					then
						echo -e "    \"$step.$substep\" started ... "

						rm -f ${CLFS_BUILD_DIR}/${step}/flags/$substep.failed
						rm -f ${CLFS_BUILD_DIR}/${step}/flags/$substep.success

						_PREV_PWD=$PWD

						export STEP_BUILD_DIR=${CLFS_BUILD_DIR}/${step}
						cd ${STEP_BUILD_DIR}

						if [ "$VERBOSE" == "1" ]
						then
							${CLFS_SCRIPTS_DIR}/helper.sh $step $substep 2>&1 | tee ${CLFS_BUILD_DIR}/${step}/logs/$substep.txt
						else
							echo -e "To see logs you can do in another terminal:\n tail -f work/build/${step}/logs/${substep}.txt \n"
							${CLFS_SCRIPTS_DIR}/helper.sh $step $substep > ${CLFS_BUILD_DIR}/${step}/logs/$substep.txt 2>&1
						fi

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
				fi
			done

		fi


	fi
done





echo
