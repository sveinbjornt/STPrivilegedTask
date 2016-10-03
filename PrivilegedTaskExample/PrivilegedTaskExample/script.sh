#!/bin/sh

echo "/usr/bin/whoami:"
whoami
echo ""
echo "Real User ID:"
echo $UID \($USER\)
echo ""
echo "Effective User ID:"
/usr/bin/id -u
echo ""
echo "Current working directory:"
echo "$PWD"

exit 5