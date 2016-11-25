#!/bin/bash
CLI="/usr/sbin/asterisk -rx"
TMPFILE=$(mktemp /tmp/blacklist.XXXXXX)

curl -o ${TMPFILE} https://trick77.com/tools/latest_cc_blacklist.txt

if [ "$1" == "-d" ]; then
  echo "Removing all existing blacklist entries..."
  ${CLI}i "database deltree blacklist"
fi

echo "Importing blacklist data..."
cat ${TMPFILE} | while read line; do
  [[ ${line} = \#* ]] && continue
  NUMBER=${line%;*}
  DESC=${line#*;}
  echo "database put blacklist ${NUMBER} \"${DESC}\""
  ${CLI} "database put blacklist ${NUMBER} \"${DESC}\""
done

rm ${TMPFILE}
