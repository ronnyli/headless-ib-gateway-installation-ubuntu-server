####################
## This script is meant to be run on a GCP instance
####################

#####
# Step 1: Set up IB Gateway server
#####
# Install dependencies
PWD_OUTPUT_USER=$(pwd)
cd /root/
apt update && apt install -y unzip xvfb x11vnc
echo | Xvfb :10 -ac -screen 0 1024x768x24 &

# Make sure DISPLAY=:10 is a permanent environment variable
echo DISPLAY=:10 >> ~/.bashrc
echo DISPLAY=:10 >> ~/.profile
echo DISPLAY=:10 >> /etc/environment
source ~/.bashrc
source ~/.profile

x11vnc -ncache 10 -ncache_cr -display :10 -forever -shared -logappend /var/log/x11vnc.log -bg -noipv6

# download installation script
wget https://download2.interactivebrokers.com/installers/ibgateway/latest-standalone/ibgateway-latest-standalone-linux-x64.sh
# make it executable
chmod a+x ibgateway-latest-standalone-linux-x64.sh
# run it
echo | sh ibgateway-latest-standalone-linux-x64.sh -c

# get the link to latest IBC from https://github.com/IbcAlpha/IBC/releases
wget https://github.com/IbcAlpha/IBC/releases/download/3.8.2/IBCLinux-3.8.2.zip
unzip ./IBCLinux-3.8.2.zip -d /opt/ibc

# Copy configuration files
mv $PWD_OUTPUT_USER/jts.ini /root/Jts/
mkdir /root/ibc
mv $PWD_OUTPUT_USER/config.ini /root/ibc
mv $PWD_OUTPUT_USER/gatewaystart.sh /opt/ibc/

chmod o+x /opt/ibc/*.sh /opt/ibc/*/*.sh

# Run IB Gateway (then kill it) in order to create user settings directory
TWS_MAJOR_VRSN=978
IBC_INI=/root/ibc/config.ini
gw_flag=-g
IBC_PATH=/opt/ibc
TWS_PATH=/root/Jts
TWS_SETTINGS_PATH=
LOG_PATH=/root/ibc/logs

timeout --preserve-status -k 60s 60s \
  xvfb-run -a "${IBC_PATH}/scripts/ibcstart.sh" \
    "${TWS_MAJOR_VRSN}" ${gw_flag} \
    "--tws-path=${TWS_PATH}" \
    "--tws-settings-path=${TWS_SETTINGS_PATH}" \
    "--ibc-path=${IBC_PATH}" \
    "--ibc-ini=${IBC_INI}" &
XVFB_PID=$!

sleep 1m
kill $XVFB_PID

# Find the user settings directory (this is unique to each user)
JTS_USER_DIR=$(ls -d $TWS_PATH/*/ | egrep -v 'ibgateway|jars')
echo 'JTS_USER_DIR='
echo $JTS_USER_DIR
# Add our custom settings
mv $PWD_OUTPUT_USER/ibg.xml $JTS_USER_DIR

# Start IB Gateway and send to TightVNC
DISPLAY=:10 /opt/ibc/gatewaystart.sh

# Restart IB Gateway if it shuts off
crontab /opt/ibc/crontab.txt

echo 'Done! You can now use TightVNC to connect to your IB Gateway server'
