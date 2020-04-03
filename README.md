# Interactive Brokers: Headless IB Gateway Installation using IBController on Ubuntu Server

This guide was written for anyone that would like to host an instance of the IB Gateway API on an external network. This will allow you to use libraries like [node-ib](https://github.com/pilwon/node-ib) and [ib-sdk](https://github.com/triploc/ib-sdk) in a production environment.

### Influencers
- https://filipmolcik.com/headless-ubuntu-server-for-ib-gatewaytws/
- https://dimon.ca/how-to-setup-ibcontroller-and-tws-on-headless-ubuntu-to-run-two-accounts/
- https://github.com/QuantConnect/Lean/blob/master/DockerfileLeanFoundation
- https://github.com/QuantConnect/Lean/blob/master/Brokerages/InteractiveBrokers/run-ib-controller.sh
- https://github.com/ib-controller/ib-controller/blob/master/userguide.md

## Create your server (GCP, AWS, whatever)
I used GCP to create a Ubuntu 18.04 instance w/ 1.7GB RAM and 10GB hard drive.

## Firewall
Make sure the following ports are accessible from the outside network:
- `5900`: `x11vnc` remote viewer
- `4002`: default IB Gateway API for paper account
- `4001`: IB Gateway API for live account

On GCP you can allow ports by finding the Firewall Rules for your instance.
1. Create a new rule
1. Make sure you allow Ingress traffic
1. For IP ranges use `0.0.0.0/0` to allow traffic from anywhere or you can be more specific
1. Make sure the `tcp` box is checked and add the port you want to allow.
1. Repeat for all the ports.

## SSH to your server
```shell
# once you've logged in, proceed as `sudo` user
sudo -i
# we'll start in root's home directory
cd ~
# Do everything through a screen so you can close the window without losing everything
screen
```
This is not exactly best Unix practice, but it'll do for now while we get everything up and running.

## Dependencies
```shell
# unzip is used to unzip compressed downloads
apt install unzip
# xvfb is an x11 (GUI) screen simulator
apt install xvfb
# x11vnc is a remote screen simulator viewing tool
apt install x11vnc
```
- `xvfb` will allow IB Gateway to launch because without an x11 container, it crashes.
- `x11vnc` is used to host/serve the simulated x11 GUI allowing you to interact with IB Gateway's user interface remotely.

## Setup the x11 screen simulator
```shell
Xvfb :1 -ac -screen 0 1024x768x24 &
# press enter
export DISPLAY=:1
x11vnc -ncache 10 -ncache_cr -display :1 -forever -shared -logappend /var/log/x11vnc.log -bg -noipv6
```
- You'll want to configure your server's firewall to allow ports `5900`, `4002`, and `4001` as previously mentioned.

## Install IB Gateway
```shell
# in your root's home directory
cd ~
# download installation script
wget https://download2.interactivebrokers.com/installers/ibgateway/latest-standalone/ibgateway-latest-standalone-linux-x64.sh
# make it executable
chmod a+x ibgateway-latest-standalone-linux-x64.sh
# run it
sh ibgateway-latest-standalone-linux-x64.sh -c
```
```shell
# when prompted:
Run IB Gateway?
Yes [y], No [n, Enter]
# choose No
```

## Install IBController
The [IBController](https://github.com/ib-controller/ib-controller) is used to automate the IB Gateway using telnet.
```shell
# still in your root's home directory
cd ~
# get the link to latest IBController from https://github.com/ib-controller/ib-controller/releases
wget https://github.com/ib-controller/ib-controller/releases/download/3.4.0/IBController-3.4.0.zip
unzip ./IBController-3.4.0.zip -d ./ibcontroller.paper
# make the scripts executable
chmod a+x ./ibcontroller.paper/*.sh ./ibcontroller.paper/*/*.sh
```

## Configuration
#### ~/Jts/jts.ini
On your local machine, look for your `jts.ini` file, which can typically be found at `~/Jts/jts.ini` (or `C:\Jts\jts.ini`, for Windows).
Copy the contents of the file to `~/JTS/jts.ini` on your remote server.

Here's an example of what the contents should look like.
```ini
[IBGateway]
WriteDebug=false
TrustedIPs=127.0.0.1
MainWindow.Height=550
RemoteHostOrderRouting=gdc1.ibllc.com
RemotePortOrderRouting=4000
ApiOnly=true
LocalServerPort=4000
MainWindow.Width=700

[Logon]
useRemoteSettings=false
UserNameToDirectory=Ij4tOygzbGV6,djgblkjyvm
Individual=1
tradingMode=p
colorPalletName=dark
Steps=5
Locale=en
SupportsSSL=gdc1.ibllc.com:4000,true,20170813,false
UseSSL=true
s3store=true

[ns]
darykq=1

[Communication]
Internal=false
LocalPort=0
Peer=gdc1.ibllc.com:4001
Region=us
```

#### `~/ibcontroller.paper/IBControllerGatewayStart.sh`
On your remote server, edit `~/ibcontroller.paper/IBControllerGatewayStart.sh` as indicated below.
You should ONLY modify the top part of the file.
```shell
TWS_MAJOR_VRSN=<YOUR TWS VERSION>
IBC_INI=~/ibcontroller.paper/IBController.ini
TRADING_MODE=
IBC_PATH=~/ibcontroller.paper
TWS_PATH=~/Jts
LOG_PATH=~/ibcontroller.paper/Logs
TWSUSERID=
TWSPASSWORD=
JAVA_PATH=
```

#### `~/ibcontroller.paper/IBController.ini`
This is the IBController configuration. More info can be found [here](https://github.com/ib-controller/ib-controller/blob/master/userguide.md).

On your remote server, edit `~/ibcontroller.paper/IBController.ini`. This file can be completely cleared and replaced with the contents below. (Don't forget to include your IB username and password)

Also note that `TradingMode` is currently set to `paper` but can be changed to `live`
```ini
LogToConsole=no
FIX=no
IbLoginId=<YOUR IB ACCOUNT USERNAME>
IbPassword=<YOUR IB ACCOUNT PASSWORD>
PasswordEncrypted=no
FIXLoginId=
FIXPassword=
FIXPasswordEncrypted=yes
TradingMode=paper
IbDir=
StoreSettingsOnServer=no
MinimizeMainWindow=no
ExistingSessionDetectedAction=manual
AcceptIncomingConnectionAction=accept
ShowAllTrades=no
ForceTwsApiPort=
ReadOnlyLogin=no
AcceptNonBrokerageAccountWarning=yes
IbAutoClosedown=no
ClosedownAt=Saturday 04:11
AllowBlindTrading=yes
DismissPasswordExpiryWarning=no
DismissNSEComplianceNotice=yes
SaveTwsSettingsAt=
IbControllerPort=7462
IbControlFrom=
IbBindAddress=127.0.0.1
CommandPrompt=
SuppressInfoMessages=yes
LogComponents=never
```

After modifying `IBController.ini` you should also copy it to `~/IBController/IBController.ini` because it looks like IBController checks that location too

## Start the IB Gateway
We'll use the simulated x11 (`DISPLAY=:1`) we created with `xvfb` to start the IBController script.
```shell
DISPLAY=:1 ~/ibcontroller.paper/IBControllerGatewayStart.sh
```

## Validate and debug
We use a remote desktop tool called `TightVNC` to see the remote server's screen and make sure IB Gateway is up and running.

First download TightVNC to your local machine: 
- [tvnjviewer-2.8.3-bin-gnugpl.zip](http://www.tightvnc.com/download/2.8.3/tvnjviewer-2.8.3-bin-gnugpl.zip).
- unzip tvnjiewer and launch the jar either using the shell command below or by opening with Java.
```shell
# launch the TightVNC app
java -jar tightvnc-jviewer.jar
```
- When asked for the remote host, enter the external IP of your remote server
(you can see this on the "VM Instances" page in your GCP console) followed by `:5900`.

After logging in to IB Gateway on the remote server, go into Settings and add your local machine's IP address as a Trusted IP.
(You can find your IP by Googling "What's my IP")

To connect to IB with `ib_insync`, simply replace the default host IP (`127.0.0.1`) with the external IP address of your instance.

## Trouble Shooting

### Missing Xfonts

You may get following error message (or similar) when you start the `IBController`,

```bash
xterm can not load font "-misc-fixed-medium-r-semicondensed ...
```

You need to install the fonts, here is the command for Ubuntu

```bash
sudo apt install xfonts-base
```

> You may need to find out the way for your Linux distribution

### Missing libXi.so

You may see the error message about missing `libXi.so.6` in the log file of `IBController`, just need to run

```bash
sudo apt install libxi-dev libxmu-dev
```

> You may need to find out the way for your Linux distribution



## Testing
Using the [ib-sdk](https://github.com/triploc/ib-sdk):
```javascript
const ibsdk = require('ib-sdk')
ibsdk.open({
	clientId: 0,
	host: '123.45.67.890',
	port: 4002,
}, function(error, session) {
	if (error) return console.error('ibsdk.open > error', error);
	let account = session.account()
	console.log('account', account)
})
```

