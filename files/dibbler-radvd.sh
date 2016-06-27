#!/bin/bash
# Orginal version by Zoc
# Modified to handle multiple interfaces

logfile=/tmp/dibbler.log
env > $logfile 2>&1
echo "------------------" >> $logfile

if [ "$SRV_MESSAGE" != "REPLY" ]; then
    exit 1
fi

INT_SUFFIX="eth0#40::1/64"
INT_SUFFIX="$INT_SUFFIX switch0.198#98::1/64"
INT_SUFFIX="$INT_SUFFIX switch0.199#99::1/64"

STATUS_FILE=/var/run/dibbler.lease
#STATUS_FILE=/tmp/dibbler.lease

if [ -f "$STATUS_FILE" ]; then
    source $STATUS_FILE
fi

TRIM_SIZE=$(perl -e '$bin=sprintf("%-128s", "1" x '${PREFIX1LEN}'); $bin =~ s/ /0/g; $bin =~ s/([0-1]{1,16})/sprintf("%0x", oct("0b$1"))/eg; print $bin' | sed -e 's/0//g' | wc -c)
PREFIX1=$(echo $PREFIX1 | perl -pe 's/([0-9a-f]+)/sprintf("%04s",$1)/ge,s/://g')
PREFIX1=${PREFIX1:0:$TRIM_SIZE}
PREFIX1=$(echo $PREFIX1 | perl -p -e 's/([0-9a-f]{4})/$1:/g')

if [ "$PREFIX1" != "$CURRENT_PREFIX1" ]; then
    INT_ADDRESSES=''
    echo "CURRENT_PREFIX1=$PREFIX1" > $STATUS_FILE

    for group in $INT_SUFFIX; do
        int=$(echo $group | cut -d '#' -f1)
        suffix=$(echo $group | cut -d '#' -f2)

        if [ "$CURRENT_PREFIX1" != "" ]; then
            ip addr delete "${CURRENT_PREFIX1}${suffix}" dev ${int}
        fi

        echo ip addr add "${PREFIX1}${suffix}" dev ${int} >> $logfile

        ip addr add "${PREFIX1}${suffix}" dev ${int} && \
            INT_ADDRESSES="$INT_ADDRESSES ${int}#${PREFIX1}${suffix}"
    done

    echo INT_ADDRESSES='"'${INT_ADDRESSES:1}'"' >> $STATUS_FILE

    service radvd restart >/dev/null 2>&1
fi
