#!/bin/bash


if [[ -f ${CLFS_SCRIPTS_DIR}/steps/$1.sh ]]
then
	source ${CLFS_SCRIPTS_DIR}/steps/$1.sh
else
	echo $0 ": File not exist: \"${CLFS_SCRIPTS_DIR}/steps/$1.sh\""
	exit 1
fi

_cmd_list=${__cmd_list[*]}

# usage: if _array_contains "$array" $string; then
_array_contains()
{
	for v in $1
	do
		if [[ "$2" == "$v" ]]
		then
			return 0
		fi
	done
	return 1
}

if _array_contains "$_cmd_list" ${2/-/_}
then
	_cmd=${2/-/_}
	_args=( $* )
	$_cmd ${_args[@]:2}

elif [[ "$2" == "get_substep_list" ]]
then
	echo $_cmd_list
else
	echo
	echo $0 ": Unknown command \"$2\""
	exit 1
fi

