#!/bin/bash
# vim:set sw=2 sts=2:

olddir=$PWD
tmpdir=`mktemp -d`
cp -a upload.sh $tmpdir
cd $tmpdir

function cleanup() {
  echo "DONE"
  cd $olddir
  echo "rm -rf $tmpdir"
  #rm -rf $tmpdir
  exit
}

trap cleanup INT
trap cleanup TERM

while :; do
  curl -s -L -o sslproxies.html https://www.sslproxies.org/
  sed -e 's/<tr>/\n/g' sslproxies.html | egrep '^<td>' > tablelist
  awk -F '</td><td>' '{print $1 ":" $2}' tablelist | sed -e 's/<td>//' > list
cat > proxies.html << _HTML_
<DOCTYPE html>
<html>
<head>
<title>SSL Proxies</title>
</head>
<body>
<pre>
_HTML_
echo -n "Last Update:" >> proxies.html
date '+%F %T' >> proxies.html
echo "========" >> proxies.html
cat list >> proxies.html
cat >> proxies.html << _HTML_
</pre>
</body>
</html>
_HTML_
  ./upload.sh proxies.html
  sleep 600
done
