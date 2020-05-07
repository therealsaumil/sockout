#!/bin/sh
#
# Utility to transform a binary into
# Linux commands to dump binary bytes into a file
# one line at a time
#
# by Saumil Shah

if [ "$1" = "" ]
then
   echo "Usage $0 <binary>"
   exit
fi

echo "rm -f $1"
cat "$1" | hexdump -Cv | tr -s ' ' | grep '|' | cut -d'|' -f1 | cut -d' ' -f2- | sed -e 's/ $//' -e 's/ /\\x/g' -e 's/^/printf \"%b\" "\\x/g' -e "s/$/\" >> $1/"
echo "chmod +x $1"
