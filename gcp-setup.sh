####################
## WARNING! WARNING!
####################
# This is a work-in-progress file for properly configuring a server
# DO NOT RUN YET

# Everything from the headless ib gateway README
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

echo 'export DISPLAY' >> /tmp/gcp-setup.log

x11vnc -ncache 10 -ncache_cr -display :1 -forever -shared -logappend /var/log/x11vnc.log -bg -noipv6

echo 'run x11vnc' >> /tmp/gcp-setup.log

# download installation script
wget https://download2.interactivebrokers.com/installers/ibgateway/latest-standalone/ibgateway-latest-standalone-linux-x64.sh
# make it executable
chmod a+x ibgateway-latest-standalone-linux-x64.sh
# run it
echo | sh ibgateway-latest-standalone-linux-x64.sh -c


echo 'install IB Gateway' >> /tmp/gcp-setup.log


# get the link to latest IBController from https://github.com/ib-controller/ib-controller/releases
wget https://github.com/ib-controller/ib-controller/releases/download/3.4.0/IBController-3.4.0.zip
unzip ./IBController-3.4.0.zip -d ./ibcontroller.paper


echo 'install IBController' >> /tmp/gcp-setup.log


# Copy configuration files
mv $PWD_OUTPUT_USER/jts.ini /root/Jts/
mv $PWD_OUTPUT_USER/IBController.ini /root/ibcontroller.paper
mv $PWD_OUTPUT_USER/IBControllerGatewayStart.sh /root/ibcontroller.paper


echo 'mv config files' >> /tmp/gcp-setup.log


# Start IB Gateway and send to TightVNC
cp -r /root/ibcontroller.paper /root/IBController  # seems like IBControllerGateway checks here too
chmod a+x /root/ibcontroller.paper/*.sh /root/ibcontroller.paper/*/*.sh
DISPLAY=:1 /root/ibcontroller.paper/IBControllerGatewayStart.sh


echo 'Run IBControllerGateway' >> /tmp/gcp-setup.log


exit
# # Install Python
# apt install -y python3 python3-dev python3-venv gcc  # gcc is for bt dependency
# wget https://bootstrap.pypa.io/get-pip.py
# sudo python3 get-pip.py

# # virtualenv
# mkdir venv
# python3 -m venv venv/leverhead
# source venv/leverhead/bin/activate
# pip install -U pip

# # Clone leverhead
# # git clone
# cd leverhead
# pip install -r requirements.txt

# # Create keys needed for IB authentication
# openssl dhparam -outform PEM 2048 -out dhparam.pem
# openssl genrsa -out private_signature.pem 2048
# openssl genrsa -out private_encryption.pem 2048
# openssl rsa -in private_signature.pem -outform PEM -pubout -out public_signature.pem
# openssl rsa -in private_encryption.pem -outform PEM -pubout -out public_encryption.pem

# # Run cron
# # TODO: need a cron that restarts IB Gateway every week
# # 50 19 * * 1-5 /usr/bin/env bash -c 'source /home/support/venv/leverheads/bin/activate && python /home/support/leverhead/LETF_strategy_vol_hedging.py' >> /home/support/leverhead/log/cron_output 2>&1
