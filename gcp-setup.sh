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
echo | Xvfb :1 -ac -screen 0 1024x768x24 &

# Make sure DISPLAY=:1 is a permanent environment variable
echo DISPLAY=:1 >> ~/.bashrc
echo DISPLAY=:1 >> ~/.profile 
echo DISPLAY=:1 >> /etc/environment
source ~/.bashrc
source ~/.profile

x11vnc -ncache 10 -ncache_cr -display :1 -forever -shared -logappend /var/log/x11vnc.log -bg -noipv6

# download installation script
wget https://download2.interactivebrokers.com/installers/ibgateway/latest-standalone/ibgateway-latest-standalone-linux-x64.sh
# make it executable
chmod a+x ibgateway-latest-standalone-linux-x64.sh
# run it
echo | sh ibgateway-latest-standalone-linux-x64.sh -c

# get the link to latest IBController from https://github.com/ib-controller/ib-controller/releases
wget https://github.com/ib-controller/ib-controller/releases/download/3.4.0/IBController-3.4.0.zip
unzip ./IBController-3.4.0.zip -d ./ibcontroller.paper

# Copy configuration files
mv $PWD_OUTPUT_USER/jts.ini /root/Jts/
mv $PWD_OUTPUT_USER/IBController.ini /root/ibcontroller.paper
mv $PWD_OUTPUT_USER/IBControllerGatewayStart.sh /root/ibcontroller.paper

# Start IB Gateway and send to TightVNC
cp -r /root/ibcontroller.paper /root/IBController  # seems like IBControllerGateway checks here too
chmod a+x /root/ibcontroller.paper/*.sh /root/ibcontroller.paper/*/*.sh
DISPLAY=:1 /root/ibcontroller.paper/IBControllerGatewayStart.sh

echo 'Done! You can now use TightVNC to connect to your IB Gateway server'
