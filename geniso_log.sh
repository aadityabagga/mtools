#!/bin/bash
# geniso_log.sh: wrapper around geniso to log its output

# Set defaults
LOGDIR="$HOME/log"
ARCH=$(uname -m)
BRANCH=stable

# Source config
if [ -f "${HOME}/.config/mtools.conf" ]; then
	source "${HOME}/.config/mtools.conf"
fi

# Check for root
if [[ $EUID -ne 0 ]]; then
	echo "Must be run as root."
	exit 1
fi

# Get profile, arch and other options
while getopts "p:a:b:r:t:k:i:scxzvqh" opt
do
	case "$opt" in
	p) PROFILE="$OPTARG";;
	a) ARCH="$OPTARG";;
	b) BRANCH="$OPTARG";;
	q) QUERY=true;;
	*) ;;
	esac
done

# Set log name based on args passed
LOGNAME="geniso_${PROFILE}_${BRANCH}_${ARCH}_$(date +%F_%T).log"

if [[ ! $QUERY = true ]]; then
	# Create log dir if not present
	if [ ! -d "${LOGDIR}" ]; then
		echo "Creating ${LOGDIR}"
		mkdir -p "${LOGDIR}"
	fi

	# Call geniso with logging
	# http://stackoverflow.com/questions/692000/how-do-i-write-stderr-to-a-file-while-using-tee-with-a-pipe
	geniso "$@" > >(tee -i "${LOGDIR}/${LOGNAME}") 2> >(tee -i "${LOGDIR}/${LOGNAME}" >&2)
else
	geniso "$@"
fi
