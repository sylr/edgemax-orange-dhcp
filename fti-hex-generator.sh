#!/bin/bash

USERNAME=$1
AUTHSTRING=00:00:00:00:00:00:00:00:00:00:00:66:74:69:2f

if [[ $USERNAME = "fti/"* ]]; then
    echo "Don't provide the 'fti/' part"
    echo "But only the part after the '/'"
    exit 1
fi

for (( i=0; i<${#USERNAME}; i++ )); do
    HEXCHAR=$(echo -n ${USERNAME:$i:1} | od -An -txC | xargs)
    AUTHSTRING=${AUTHSTRING}:${HEXCHAR}
done

echo ${AUTHSTRING}
