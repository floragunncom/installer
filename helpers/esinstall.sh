#!/bin/bash
set -e

command_exists () {
    command -v "$1" >/dev/null 2>&1
}

ES_VERSION="$1"

if command_exists yum ; then

    sudo yum -y update > /dev/null 2>&1

    if ! command_exists java ; then
        echo "Install Java (rpm)"
        sudo yum -y install java-1.8.0-openjdk > /dev/null 2>&1
        echo "Java installed"
    fi
    
    if ! command_exists wget ; then
        echo "Install wget (rpm)"
        sudo yum -y install wget > /dev/null 2>&1
        echo "wget installed"
    fi

    echo "Install Elasticsearch (rpm)"
    wget –quiet -nv "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION.rpm" -O "/tmp/elasticsearch-$ES_VERSION.rpm" > /dev/null 2>&1
    sudo rpm --install "/tmp/elasticsearch-$ES_VERSION.rpm" > /dev/null 2>&1
    rm -f "/tmp/elasticsearch-$ES_VERSION.rpm" > /dev/null 2>&1
    echo "Elasticsearch installed"
else    
    if command_exists apt-get ; then
    
        sudo apt-get -y update > /dev/null 2>&1
    
        if ! command_exists java ; then
            echo "Install Java (deb)"
            sudo apt-get -y install openjdk-8-jre > /dev/null 2>&1
            echo "Java installed"
        fi
        
        if ! command_exists wget ; then
            echo "Install wget (deb)"
            sudo apt-get -y install wget > /dev/null 2>&1
            echo "wget installed"
        fi
    
        echo "Install Elasticsearch (deb)"
    	wget –quiet -nv "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION.deb" -O "/tmp/elasticsearch-$ES_VERSION.deb" > /dev/null 2>&1
        sudo dpkg -i "/tmp/elasticsearch-$ES_VERSION.deb" > /dev/null 2>&1
        rm -f "/tmp/elasticsearch-$ES_VERSION.deb" > /dev/null 2>&1
        echo "Elasticsearch installed"
        
    else
        echo "Install Elasticsearch (tar.gz) in current folder $(pwd)"
    	wget –quiet -nv "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$ES_VERSION.tar.gz" -O "/tmp/elasticsearch-$ES_VERSION.tar.gz" > /dev/null 2>&1
    	tar -xzvf "/tmp/elasticsearch-$ES_VERSION.tar.gz" > /dev/null 2>&1
    	rm -f "/tmp/elasticsearch-$ES_VERSION.tar.gz" > /dev/null 2>&1
    	
    	if ! command_exists java ; then
            echo "Warning: No java found"
        fi
        
        echo "Elasticsearch installed"
    fi
fi