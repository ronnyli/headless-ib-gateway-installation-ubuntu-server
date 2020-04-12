####################
## WARNING! WARNING!
####################
# This is a work-in-progress file for properly configuring a server
# DO NOT RUN YET

# Step 1: Everything from the README
echo DISPLAY=:1 >> ~/.bashrc
echo DISPLAY=:1 >> ~/.profile 
echo DISPLAY=:1 >> /etc/environment  # This one needs to be done as root
source ~/.bashrc
source ~/.profile

# Step 2: Install Python
sudo apt update
sudo apt install -y python3 python3-dev python3-venv gcc  # gcc is for bt dependency
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py

# Step 3: virtualenv
mkdir venv
python3 -m venv venv/leverhead
source venv/leverhead/bin/activate
pip install -U pip

# Step 4: Clone leverhead
# git clone
cd leverhead
pip install -r requirements.txt

# Step 5: Run cron
# 50 19 * * 1-5 /usr/bin/env bash -c 'source /home/support/venv/leverheads/bin/activate && python /home/support/leverhead/LETF_strategy_vol_hedging.py' >> /home/support/leverhead/log/cron_output 2>&1


