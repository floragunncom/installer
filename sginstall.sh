#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Search Guard 5 Installer Version 0.1"


OPTIND=1

demo=0
verbose=0
update=0
commercial=0
kibana=0

function show_help() {
    echo "sginstall.sh [-h] [-v] [-u] [-d] [-s] [-c]"
    echo "  -h show help"
    echo "  -v verbose"
    echo "  -u update plugin if already installed, otherwise fail"
    echo "  -d install demo certificates and demo config"
    echo "  -s install latest snapshot instead of latest release"
    echo "  -c install also commercial modules (like ldap, dls/fls, ...)"
    echo "  -k install also kibana plugin (if kibana could be found)"
}

while getopts "h?vudsck" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    v)  verbose=1
        ;;
    u)  update=1
        ;;
    d)  demo=1
        ;;
    s)  snapshot=1
        ;;
    c)  commercial=1
        ;;
    k)  kibana=1
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

function dbg() {
	if [ "$verbose" == 1 ]; then
	    echo "$1"
	fi
}

function err() {
    echo "ERROR: $1"
    exit -1
}

SGI_status_50=supported
SGI_search_guard_5_50=11
SGI_dlic_search_guard_module_auditlog_50=5.0-4
SGI_dlic_search_guard_rest_api_50=5.0-3
SGI_dlic_search_guard_auth_http_kerberos_50=5.0-4
SGI_dlic_search_guard_authbackend_ldap_50=5.0-7
SGI_dlic_search_guard_module_dlsfls_50=5.0-6
SGI_dlic_search_guard_auth_http_jwt_50=5.0-4
SGI_tcnative_fork_50=1.1.33.Fork23

SGI_status_51=supported
SGI_search_guard_5_51=11
SGI_dlic_search_guard_module_auditlog_51=5.1-4
SGI_dlic_search_guard_rest_api_51=5.1-3
SGI_dlic_search_guard_auth_http_kerberos_51=5.0-4
SGI_dlic_search_guard_authbackend_ldap_51=5.0-7
SGI_dlic_search_guard_module_dlsfls_51=5.1-6
SGI_dlic_search_guard_auth_http_jwt_51=5.0-4
SGI_tcnative_fork_51=1.1.33.Fork23

SGI_status_52=supported
SGI_search_guard_5_52=11
SGI_dlic_search_guard_module_auditlog_52=5.2-4
SGI_dlic_search_guard_rest_api_52=5.2-3
SGI_dlic_search_guard_auth_http_kerberos_52=5.0-4
SGI_dlic_search_guard_authbackend_ldap_52=5.0-7
SGI_dlic_search_guard_module_dlsfls_52=5.2-6
SGI_dlic_search_guard_auth_http_jwt_52=5.0-4
SGI_tcnative_fork_52=1.1.33.Fork25

SGI_status_53=supported
SGI_search_guard_5_53=11
SGI_dlic_search_guard_module_auditlog_53=5.3-4
SGI_dlic_search_guard_rest_api_53=5.3-3
SGI_dlic_search_guard_auth_http_kerberos_53=5.0-4
SGI_dlic_search_guard_authbackend_ldap_53=5.0-7
SGI_dlic_search_guard_module_dlsfls_53=5.3-6
SGI_dlic_search_guard_auth_http_jwt_53=5.0-4
SGI_tcnative_fork_53=1.1.33.Fork25

BASE_DIR="$(pwd)"
ES_CONF_FILE="$BASE_DIR/config/elasticsearch.yml"
ES_BIN_DIR="$BASE_DIR/bin"
ES_PLUGINS_DIR="$BASE_DIR/plugins"
ES_LIB_PATH="$BASE_DIR/lib"
SUDO_CMD=""
ES_INSTALL_TYPE=".tar.gz"
    
#Check if its a rpm/deb install
if [ -f /usr/share/elasticsearch/bin/elasticsearch ]; then
    ES_CONF_FILE="/etc/elasticsearch/elasticsearch.yml"
    ES_BIN_DIR="/usr/share/elasticsearch/bin"
    ES_PLUGINS_DIR="/usr/share/elasticsearch/plugins"
    ES_LIB_PATH="/usr/share/elasticsearch/lib"
    SUDO_CMD="sudo"
    ES_INSTALL_TYPE="rpm/deb"
    echo "We might ask you for the root password during install"
fi

if $SUDO_CMD test -f "$ES_CONF_FILE"; then
    :
else
    err "Unable to determine elasticsearch config directory"
fi
    
if [ ! -d "$ES_BIN_DIR" ]; then
	err "Unable to determine elasticsearch bin directory"
fi

if [ ! -d "$ES_PLUGINS_DIR" ]; then
	err "Unable to determine elasticsearch plugins directory"
fi

if [ ! -d "$ES_LIB_PATH" ]; then
	err "Unable to determine elasticsearch lib directory"
fi

ES_CONF_DIR=$(dirname "${ES_CONF_FILE}")
ES_VERSION=("$ES_LIB_PATH/elasticsearch-*.jar")
ES_VERSION=$(echo $ES_VERSION | sed 's/.*elasticsearch-\(.*\)\.jar/\1/')
ES_MINOR_VERSION=$(echo $ES_VERSION | sed 's/\(.*\)\.\(.*\)/\1/')
ES_MINOR_VERSION_COMPACT=${ES_MINOR_VERSION/./}
KIBANA_SG_PLUGIN_URL="https://github.com/floragunncom/search-guard-kibana-plugin/releases/download/v$ES_VERSION-beta3.1/searchguard-kibana-$ES_VERSION-beta3.1.zip"


if [ -f "/usr/share/kibana/bin/kibana" ] && [ "$kibana" == 1 ]; then
    $SUDO_CMD /usr/share/kibana/bin/kibana-plugin remove searchguard || true > /dev/null 2>&1
    $SUDO_CMD /usr/share/kibana/bin/kibana-plugin install $KIBANA_SG_PLUGIN_URL > /dev/null 2>&1
    echo "Kibana plugin installed"
fi


#TODO also install kibana plugin
#but we need locate kibana for this
#KIBANA_SG_PLUGIN_URL="https://github.com/floragunncom/search-guard-kibana-plugin/releases/download/v$ES_VERSION-beta3.1/searchguard-kibana-$ES_VERSION-beta3.1.zip"

#echo $ES_MINOR_VERSION
SG_TMP="SGI_status_${ES_MINOR_VERSION_COMPACT}"

SG_STATUS="${!SG_TMP}"

if [ "$SG_STATUS" != "supported" ];then
    err "Elasticsearch $ES_VERSION not supported by this installer (yet). Currently we support >= ES 5.0.0"
fi

if [ -d "$ES_PLUGINS_DIR/search-guard-5" ]; then
  
  if [ "$update" == 1 ]; then
     $SUDO_CMD "$ES_BIN_DIR/elasticsearch-plugin" remove search-guard-5  > /dev/null 2>&1
  else
     err "Search Guard plugin already installed. Quit."
  fi
fi

SG_TMP="SGI_search_guard_5_${ES_MINOR_VERSION_COMPACT}"
SG_VERSION="${!SG_TMP}"

#echo "ES_MINOR_VERSION_COMPACT: $ES_MINOR_VERSION_COMPACT"
#echo "SG_VERSION: $SG_VERSION"

$SUDO_CMD rm -f "$ES_PLUGINS_DIR/search-guard-5/dlic*.jar"

if [ "$snapshot" == 1 ];then 
    echo "Will install Search Guard $ES_MINOR_VERSION.x-HEAD-SNAPSHOT (do not use this in production)"
    $SUDO_CMD wget "http://oss.sonatype.org/service/local/artifact/maven/content?e=zip&r=snapshots&g=com.floragunn&a=search-guard-5&v=$ES_MINOR_VERSION.x-HEAD-SNAPSHOT" --content-disposition -O "/tmp/p_search-guard-5.zip"  > /dev/null 2>&1
else
    echo "Will install Search Guard $ES_VERSION-$SG_VERSION release"
    $SUDO_CMD wget "http://oss.sonatype.org/service/local/artifact/maven/content?e=zip&r=releases&g=com.floragunn&a=search-guard-5&v=$ES_VERSION-$SG_VERSION" --content-disposition -O "/tmp/p_search-guard-5.zip"  > /dev/null 2>&1
    
fi

$SUDO_CMD "$ES_BIN_DIR/elasticsearch-plugin" install -b "file:///tmp/p_search-guard-5.zip" > /dev/null 2>&1    

uuidgen | $SUDO_CMD tee "$ES_CONF_DIR/search_guard_install_token" > /dev/null

if [ "$ES_INSTALL_TYPE" == "rpm/deb" ]; then
    $SUDO_CMD chown elasticsearch:root "$ES_CONF_DIR/search_guard_install_token"
    $SUDO_CMD chmod 770 "$ES_CONF_DIR/search_guard_install_token"
else    
    $SUDO_CMD chmod 700 "$ES_CONF_DIR/search_guard_install_token"
fi

if [ "$commercial" == 1 ]; then
    SG_TMP="SGI_dlic_search_guard_auth_http_kerberos_${ES_MINOR_VERSION_COMPACT}"
	$SUDO_CMD wget "http://oss.sonatype.org/service/local/artifact/maven/content?c=jar-with-dependencies&r=releases&g=com.floragunn&a=dlic-search-guard-auth-http-kerberos&v=${!SG_TMP}" --content-disposition  -P "$ES_PLUGINS_DIR/search-guard-5" > /dev/null 2>&1
	dbg "Kerberos module ${!SG_TMP} installed"

	SG_TMP="SGI_dlic_search_guard_auth_http_jwt_${ES_MINOR_VERSION_COMPACT}"
	$SUDO_CMD wget "http://oss.sonatype.org/service/local/artifact/maven/content?c=jar-with-dependencies&r=releases&g=com.floragunn&a=dlic-search-guard-auth-http-jwt&v=${!SG_TMP}" --content-disposition   -P "$ES_PLUGINS_DIR/search-guard-5"  > /dev/null 2>&1
	dbg "JWT module ${!SG_TMP} installed"

	SG_TMP="SGI_dlic_search_guard_module_dlsfls_${ES_MINOR_VERSION_COMPACT}"
	$SUDO_CMD wget "http://oss.sonatype.org/service/local/artifact/maven/content?c=jar-with-dependencies&r=releases&g=com.floragunn&a=dlic-search-guard-module-dlsfls&v=${!SG_TMP}" --content-disposition   -P "$ES_PLUGINS_DIR/search-guard-5"  > /dev/null 2>&1
	dbg "DLS/FLS module ${!SG_TMP} installed"

	SG_TMP="SGI_dlic_search_guard_module_auditlog_${ES_MINOR_VERSION_COMPACT}"
	$SUDO_CMD wget "http://oss.sonatype.org/service/local/artifact/maven/content?c=jar-with-dependencies&r=releases&g=com.floragunn&a=dlic-search-guard-module-auditlog&v=${!SG_TMP}" --content-disposition   -P "$ES_PLUGINS_DIR/search-guard-5"  > /dev/null 2>&1
	dbg "Auditlog module ${!SG_TMP} installed"

	SG_TMP="SGI_dlic_search_guard_authbackend_ldap_${ES_MINOR_VERSION_COMPACT}"
	$SUDO_CMD wget "http://oss.sonatype.org/service/local/artifact/maven/content?c=jar-with-dependencies&r=releases&g=com.floragunn&a=dlic-search-guard-authbackend-ldap&v=${!SG_TMP}" --content-disposition   -P "$ES_PLUGINS_DIR/search-guard-5"  > /dev/null 2>&1
	dbg "LDAP module ${!SG_TMP} installed"

	SG_TMP="SGI_dlic_search_guard_rest_api_${ES_MINOR_VERSION_COMPACT}"
	$SUDO_CMD wget "http://oss.sonatype.org/service/local/artifact/maven/content?c=jar-with-dependencies&r=releases&g=com.floragunn&a=dlic-search-guard-rest-api&v=${!SG_TMP}" --content-disposition   -P "$ES_PLUGINS_DIR/search-guard-5"  > /dev/null 2>&1
	dbg "Management API module ${!SG_TMP} installed"
fi


NETTY_NATIVE_VERSION="SGI_tcnative_fork_${ES_MINOR_VERSION_COMPACT}"

if [ "$(uname)" == "Darwin" ]; then
  NETTY_NATIVE_CLASSIFIER=osx-x86_64
  KIBANA_CLASSIFIER=darwin-x86_64
else
  NETTY_NATIVE_CLASSIFIER=linux-x86_64
  KIBANA_CLASSIFIER=linux-x86_64
fi

$SUDO_CMD wget "https://search.maven.org/remotecontent?filepath=io/netty/netty-tcnative/${!NETTY_NATIVE_VERSION}/netty-tcnative-${!NETTY_NATIVE_VERSION}-$NETTY_NATIVE_CLASSIFIER.jar" --content-disposition -P "$ES_PLUGINS_DIR/search-guard-5" > /dev/null 2>&1

dbg "Openssl binding installed"

$SUDO_CMD rm -f "/tmp/p_search-guard-5.zip"

$SUDO_CMD chmod -R +x "$ES_PLUGINS_DIR/search-guard-5/tools/"

if [ "$demo" == 1 ]; then
    $SUDO_CMD "$ES_PLUGINS_DIR/search-guard-5/tools/install_demo_configuration.sh" -y
else
   echo "Search Guard successfully installed"
fi