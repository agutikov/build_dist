#!/bin/bash

# set -x

source $(dirname $(readlink -f $0))/../config.sh

description()
{
	echo "Example step."
}

execute()
{
	echo "PWD =\""$PWD"\""
}

__cmd_list=(
	description
	execute
)

source ${CLFS_SCRIPTS_DIR}/step_helper.sh
