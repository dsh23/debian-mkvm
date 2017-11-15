#!/bin/bash

# Name:    mkvm.sh
# Date:    2014-09-20 14:24:29+1000
# Author:  Dave Hellewell 
# Contact: CONTACT
# Licence: GPL V.2 

# Desc: Make a new vm

# Args: '-n': name, '-s': size

HOST=unset
SIZE=small
BTYPE=standard
DISK="/home/dsh/localsys/systems/debian/scripts/naviho.sh"
POOL="vmpool"
RAM=2048

usage() {
cat <<EOF
Usage: $(basename $0) [-h] | -n name [-s size] [-b buildtype]

OPTIONS
---------------------------------

 -h              Help
 -n hoststring   Mandatory option, host name string must be present
 -s size         Optional size. May be: small, medium or large
                 Default = small
 -b buildtype    Optional build type. May be: dev, desktop or standard
                 Default = standard
EOF
}

if [[ $# -eq 0 ]]
then
    echo Cannot build without name and size parameters
    usage
    exit 0
fi

while getopts hn:s:b: opt 
do
    case $opt in
	n)
	    if [[ "$OPTARG" == "-"* ]]
	    then
		usage >&2
		exit 1
	    else 
		HOST=$OPTARG #TODO: Validate host charachters
	    fi
	    ;;
	s)
	    if [[ "$OPTARG" == "-"* ]]
	    then
		usage >&2
	    elif [[ "$OPTARG" == [Ll]"arge" || "$OPTARG" == [Mm]"edium" || "$OPTARG" == [Ss]"mall" ]]
	    then
		SIZE=$OPTARG
	    else usage >&2
		 exit 1
	    fi
	    ;;
	b)
	   if [[ "$OPTARG" == "-"* ]]
	    then
		usage >&2
	    elif [[ "$OPTARG" == [Dd]"ev" || "$OPTARG" == [Dd]"esktop" || "$OPTARG" == [Ss]"tandard" ]]
	    then
		BTYPE=$OPTARG
	    else usage >&2
		 exit 1
	    fi 
	   ;;		     
       \?)
	  usage >&2
	  exit 1
	  ;;
    esac
done

if [[ -z "$HOST" ]] || [[ -z "$SIZE" ]] || [[ -z "$BTYPE" ]]
then
    usage
fi

$DISK -n $HOST -s $SIZE -b $BTYPE

while [ ! -e "/srv/vm/$HOST.qcow2" ]
do
    sleep 2
done

echo "Creating host: " $HOST

virt-install --connect=qemu:///system \
--virt-type kvm \
-r $RAM \
--vcpus=2 \
-n $HOST \
--network=bridge:br0 \
--disk vol=$POOL/$HOST.qcow2,bus=virtio \
--graphics=spice \
--os-variant=debian9 \
--pxe

# NB. the preseed file that allocates the os deployment component of the VM
# is referenced in the internals of the pxe config. Preseed files are
# currently hosted at pythagoras:localsys/systems/debian. Serve these with:
#
#  $ python -m SimpleHTTPServer
#
# from this directory.
