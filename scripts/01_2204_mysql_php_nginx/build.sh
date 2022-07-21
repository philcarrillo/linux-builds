#!/bin/bash

set -e

# options
version=0

# output usage message
usage() {
  echo "Set up new Linux Instance with latest php mysql and nginx."
  echo usage: `basename $0` [-c -d DATABASE -h -o OS_VERSION -ps -t TARGET ]
  cat <<EOF
  -c                Client-only database (typically for production-like servers).
  -d DATABASE       Specify database. Default "pg". Can be "mssql" or "pg".
  -h                This help.
  -j JEKYLL_VERSION Jekyll version to install.
  -n                Install Nginx and Certbot.
  -o OS_VERSION     Ubuntu major and minor version. Default: The installed version.
  -r RAILS_VERSION  Rails version to install.
  -s                Install for a server (no need to minimize size like for an appliance).
  -t TARGET         Deploy to a target type. Default "vagrant". Give "-t server" for server builds.
EOF
}



while getopts cd:hj:no:r:vt: x ; do
  case $x in
    c)  client=1;;
    d)  database=$OPTARG;;
    h)  usage; exit 0;;
    j)  jekyll_version=$OPTARG;;
    n)  nginx=1;;
    o)  os_version=$OPTARG;;
    r)  rails_version=$OPTARG;;
    v)  version=1;;
    t)  target=$OPTARG;;
    \?) echo Invalid option: -$OPTARG
        usage
        exit 1;;
  esac
done
shift $((OPTIND-1))

if [[ $version = 1 ]]; then
  # Get O/S info
  cat /etc/os-release
fi