#!/bin/bash

# Name:    naviho.sh
# Date:    2014-09-17 20:07:17+1000
# Author:  Dave Hellewell 
# Contact: CONTACT
# Licence: GPL V.2 

# Desc: NameVirtualHost
#       Set or query the name, size and ? of the virtual host
#       set in the generic preseed config file.

# TODO: rewrite and put logic in the loop to eliminate all the
#       conditional down the bottom of the script

DIR="/home/dsh/localsys/systems/debian"
CFILE="$DIR/generic-std.cfg"
OFILE="$DIR/current.cfg"
POOL="vmpool"
CAP=unset
HOST=unset


usage() {
cat <<EOF
Usage: $(basename $0) [-h] | -n name -s size
EOF
}

if [[ $# -eq 0 ]]
then
    echo $(awk '/netcfg\/hostname string/ {print $4}' $CFILE)
    exit 0
fi

while getopts hn:s:b: opt 
do
    case $opt in
	h)
	    usage
	    exit 0
	    ;;
	n)
	    HOST=$OPTARG
	    ;;
	s)
	    SIZE=$OPTARG
	    ;;
	b)
	    BTYPE=$OPTARG
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

if [[ "$BTYPE" = [Dd]"ev" ]]
then
    CFILE="$DIR/generic-dev.cfg"
elif [[ "$BTYPE" = [Dd]"esktop" ]]
then
    CFILE="$DIR/generic-xfce.cfg"
fi

if [[ "$SIZE" = Large ]] || [[ "$SIZE" = large ]]
then
    CAP="40G"
    SIZE=large
elif [[ "$SIZE" = Medium ]] || [[ "$SIZE" = medium ]]
then
    CAP="25G"
    SIZE=medium
else
    CAP="12G"
    SIZE=small
fi 
echo $SIZE
sed -e "s/MYHOST/$HOST/" -e "s/MYSIZE/$SIZE/" $CFILE > $OFILE

echo "about to build: " $OFILE

virsh vol-create-as $POOL ${HOST}.qcow2 $CAP --format qcow2



# echo ${0##*/}
# NB this is a shell parameter expamsion that ammounts to:
# the name of the script ($0) with preceeding match all string stripped away

