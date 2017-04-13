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

ES_VERSION="$1"

if command_exists yum ; then

    if ! command_exists java ; then
        echo "Install Java (rpm)"
        sudo yum -y install java-1.8.0-openjdk > /dev/null 2>&1
    fi
    
    if ! command_exists wget ; then
        echo "Install wget (rpm)"
        sudo yum -y install wget > /dev/null 2>&1
    fi

    echo "Install Elasticsearch (rpm)"
    wget –quiet -nv "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION.rpm" -O "/tmp/elasticsearch-$ES_VERSION.rpm" > /dev/null 2>&1
    sudo rpm --install "/tmp/elasticsearch-$ES_VERSION.rpm" > /dev/null 2>&1
    rm -f "/tmp/elasticsearch-$ES_VERSION.rpm" > /dev/null 2>&1
else    
    if command_exists apt-get ; then
    
        if ! command_exists java ; then
            echo "Install Java (deb)"
            sudo apt-get -y install openjdk-8-jre > /dev/null 2>&1
        fi
        
        if ! command_exists wget ; then
            echo "Install wget (deb)"
            sudo apt-get -y install wget > /dev/null 2>&1
        fi
    
        echo "Install Elasticsearch (deb)"
    	wget –quiet -nv "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION.deb" -O "/tmp/elasticsearch-$ES_VERSION.deb" > /dev/null 2>&1
        sudo dpkg -i "/tmp/elasticsearch-$ES_VERSION.deb" > /dev/null 2>&1
        rm -f "/tmp/elasticsearch-$ES_VERSION.deb" > /dev/null 2>&1
        
    else
        echo "Install Elasticsearch (tar.gz) in current folder $(pwd)"
    	wget –quiet -nv "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION.tar.gz" -O "/tmp/elasticsearch-$ES_VERSION.tar.gz" > /dev/null 2>&1
    	tar -xzvf "/tmp/elasticsearch-$ES_VERSION.tar.gz" > /dev/null 2>&1
    	rm -f "/tmp/elasticsearch-$ES_VERSION.tar.gz" > /dev/null 2>&1
    	
    	if ! command_exists java ; then
            echo "Warning: No java found"
        fi
    fi
fi


echo "Done"