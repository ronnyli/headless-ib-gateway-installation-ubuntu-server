####################
## This script is meant to be run on a GCP instance
####################

#####
# Step 1: Set up IB Gateway server
#####
# Install dependencies
cd config  # WARM RESTART
CONFIG_DIR=$(pwd)  # WARM RESTART
cd /root/  # WARM RESTART
apt-get update && apt-get install -y unzip xvfb x11vnc
echo | Xvfb :10 -ac -screen 0 1024x768x24 &  # WARM RESTART

# Make sure DISPLAY=:10 is a permanent environment variable
echo DISPLAY=:10 >> ~/.bashrc
echo DISPLAY=:10 >> ~/.profile
echo DISPLAY=:10 >> /etc/environment
source ~/.bashrc
source ~/.profile

x11vnc -ncache 10 -ncache_cr -display :10 -forever -shared -logappend /var/log/x11vnc.log -bg -noipv6  # WARM RESTART

# download installation script
wget https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh
# make it executable
chmod a+x ibgateway-stable-standalone-linux-x64.sh
# run it
echo | sh ibgateway-stable-standalone-linux-x64.sh -c

# get the link to latest IBC from https://github.com/IbcAlpha/IBC/releases
wget https://github.com/IbcAlpha/IBC/releases/download/3.8.2/IBCLinux-3.8.2.zip
unzip ./IBCLinux-3.8.2.zip -d /opt/ibc

# Copy configuration files
mv $CONFIG_DIR/jts.ini /root/Jts/
mkdir /root/ibc
mv $CONFIG_DIR/config.ini /root/ibc
mv $CONFIG_DIR/gatewaystart.sh /opt/ibc/

# Start IB Gateway and send to TightVNC
chmod o+x /opt/ibc/*.sh /opt/ibc/*/*.sh
DISPLAY=:10 /opt/ibc/gatewaystart.sh

# Restart IB Gateway if it shuts off
crontab /opt/ibc/crontab.txt  # WARM RESTART

# # Install Python
apt-get install -y python3 python3-dev python3-venv gcc  # gcc is for bt dependency
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py

pip install jupyterlab

jupyter lab --allow-root --no-browser --config=$CONFIG_DIR/jupyter_notebook_config.py --port=8888  # WARM RESTART

echo 'Done! You can now access IB through JupyterLab'
