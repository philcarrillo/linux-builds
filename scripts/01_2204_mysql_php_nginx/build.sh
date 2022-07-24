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

# nginx
# check if nginx is in /etc/apt/sources.list
numrecs=`grep nginx /etc/apt/sources.list | wc -l`
if [[ $numrecs < 1 ]]; then
  # Need to install nginx
  echo "... installing nginx"

  key="ABF5BD827BD9BF62"

  echo >> /etc/apt/sources.list
  echo "# -- nginx ---">> /etc/apt/sources.list
  echo "deb https://nginx.org/packages/ubuntu/ jammy nginx" >> /etc/apt/sources.list
  echo "deb-src https://nginx.org/packages/ubuntu/ jammy nginx" >> /etc/apt/sources.list

  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $key
  apt update
  apt install -y nginx

  systemctl start nginx
fi

# Create groups, if necessary
numrecs=`cut -f 1 -d ':' /etc/group | grep www-data | wc -l`
if [[ $numrecs < 1 ]]; then
  addgroup www-data
fi

# Make sure the /var/www directory exists
if [[ ! -d /var/www ]]; then
  echo "creating /var/www directory"
  cd /var
  mkdir www
fi
