####################
## WARNING! WARNING!
####################
# This is a work-in-progress file for properly configuring a server
# DO NOT RUN YET

# TODO: copy everything from the headless ib gateway README
echo DISPLAY=:1 >> ~/.bashrc
echo DISPLAY=:1 >> ~/.profile 
echo DISPLAY=:1 >> /etc/environment  # This one needs to be done as root
source ~/.bashrc
source ~/.profile

# Install Python
sudo apt update
sudo apt install -y python3 python3-dev python3-venv gcc  # gcc is for bt dependency
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py

# virtualenv
mkdir venv
python3 -m venv venv/leverhead
source venv/leverhead/bin/activate
pip install -U pip

# Clone leverhead
# git clone
cd leverhead
pip install -r requirements.txt

# Create keys needed for IB authentication
openssl dhparam -outform PEM 2048 -out dhparam.pem
openssl genrsa -out private_signature.pem 2048
openssl genrsa -out private_encryption.pem 2048
openssl rsa -in private_signature.pem -outform PEM -pubout -out public_signature.pem
openssl rsa -in private_encryption.pem -outform PEM -pubout -out public_encryption.pem

# Run cron
# TODO: need a cron that restarts IB Gateway every week
# 50 19 * * 1-5 /usr/bin/env bash -c 'source /home/support/venv/leverheads/bin/activate && python /home/support/leverhead/LETF_strategy_vol_hedging.py' >> /home/support/leverhead/log/cron_output 2>&1
