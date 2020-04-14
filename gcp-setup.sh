####################
## WARNING! WARNING!
####################
# This is a work-in-progress file for properly configuring a server
# DO NOT RUN YET

# Everything from the headless ib gateway README
PWD_OUTPUT_USER=$(pwd)
sudo su
cd ~
apt update
apt install -y unzip xvfb x11vnc
echo | Xvfb :1 -ac -screen 0 1024x768x24 &

# Make sure DISPLAY=:1 is a permanent environment variable
echo DISPLAY=:1 >> ~/.bashrc
echo DISPLAY=:1 >> ~/.profile 
echo DISPLAY=:1 >> /etc/environment
source ~/.bashrc
source ~/.profile

# in your root's home directory
cd ~
# download installation script
wget https://download2.interactivebrokers.com/installers/ibgateway/latest-standalone/ibgateway-latest-standalone-linux-x64.sh
# make it executable
chmod a+x ibgateway-latest-standalone-linux-x64.sh
# run it
echo | sh ibgateway-latest-standalone-linux-x64.sh -c

# Copy configuration files
mv $PWD_OUTPUT_USER/jts.ini $PWD/Jts/
mv $PWD_OUTPUT_USER/IBController.ini $PWD/ibcontroller.paper
mv $PWD_OUTPUT_USER/IBControllerGatewayStart.sh $PWD/ibcontroller.paper

# Start IB Gateway and send to TightVNC
# DISPLAY=:1 ~/ibcontroller.paper/IBControllerGatewayStart.sh

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
