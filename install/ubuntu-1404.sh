#! /bin/bash

CONF_DIR=/etc/init
CONF_FILE=$CONF_DIR/mailsac.conf
LOG_FILE=/var/log/mailsac.log
LOGROTATE_FILE=/etc/logrotate.d/mailsac
LOGROTATE_CONFIG="$LOG_FILE {
    weekly
    rotate 26
    size 10M
    create
    su root
    compress
    delaycompress
    postrotate
        service mailsac restart > /dev/null
    endscript
}
"


# dependencies
apt-get update;
apt-get remove -y sendmail sendmail-bin postfix apache2;
apt-get purge -y postfix exim4 sendmail sendmail-bin;
apt-get install -y git curl nano build-essential python2.7 mongodb redis-server;
curl -sL https://deb.nodesource.com/setup_0.12 | -E bash -;
apt-get install -y nodejs;

# Clone and setup the application
cd /opt;
rm -rf mailsac;
git clone https://github.com/ruffrey/mailsac.git mailsac --depth 1;
cd mailsac;
npm i --production;

# Setup init scripts
rm -f $CONF_FILE;
cp -f install/mailsac.conf $CONF_DIR;
chmod +x $CONF_FILE;

# Setup log rotation
touch $LOG_FILE;
rm -f $LOGROTATE_FILE;
echo "$LOGROTATE_CONFIG" | tee --append "$LOGROTATE_FILE";

# Ensure proper syntax and load the conf
init-checkconf -d /etc/init/mailsac.conf;
service mailsac start;

echo \n\nSuccess - installed at /opt/mailsac;
echo Edit configuration at $CONF_FILE, then run \'service mailsac restart\';
echo Check startup logs at /var/log/upstart/mailsac.log;
echo Check mailsac logs at $LOG_FILE;
