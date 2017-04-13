#!/bin/bash
lastErr() {
    local RC=$?
    history 1 |
         sed '
  s/^ *[0-9]\+ *\(\(["'\'']\)\([^\2]*\)\2\|\([^"'\'' ]*\)\) */cmd: \"\3\4\", args: \"/;
  s/$/", rc: '"$RC/"
}

trap "lastErr" ERR

command_exists () {
    command -v "$1" >/dev/null 2>&1
}

if command_exists systemctl ; then
	sudo /bin/systemctl daemon-reload
    sudo systemctl restart elasticsearch.service

else
    sudo -i service elasticsearch restart
fi


echo "Done"