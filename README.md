# Interactive Brokers: Headless IB Gateway Installation using IBController on Ubuntu Server

This guide was written for anyone that would like to host an instance of the IB Gateway API on GCP. This will allow you to use libraries like [node-ib](https://github.com/pilwon/node-ib) and [ib-sdk](https://github.com/triploc/ib-sdk) in a production environment.

### Influencers
- https://github.com/roblav96/headless-ib-gateway-installation-ubuntu-server
- https://filipmolcik.com/headless-ubuntu-server-for-ib-gatewaytws/
- https://dimon.ca/how-to-setup-ibcontroller-and-tws-on-headless-ubuntu-to-run-two-accounts/
- https://github.com/QuantConnect/Lean/blob/master/DockerfileLeanFoundation
- https://github.com/QuantConnect/Lean/blob/master/Brokerages/InteractiveBrokers/run-ib-controller.sh
- https://github.com/ib-controller/ib-controller/blob/master/userguide.md

## Instructions
Let me know if there's any way to improve these instructions
1. Create a [GCP account](https://cloud.google.com/)
1. Open the Cloud Shell (top-right corner of the screen)
	- ![Cloud Shell](images/tutorial/activate_cloud_shell.png)
1. Download some necessary files by copy-pasting the below commands into the terminal
	-
```
git clone https://github.com/ronnyli/headless-ib-gateway-installation-ubuntu-server.git
cd headless-ib-gateway-installation-ubuntu-server
```
1. Run the `gcloud_commands.sh` script by copy-pasting the below command into the terminal
	- `sh gcloud_commands.sh`
1. 
