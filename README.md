# Interactive Brokers: Headless IB Gateway Installation using IBController on Ubuntu Server
This guide was written for anyone that would like to host an instance of the IB Gateway API on GCP. This will allow you to use libraries like [node-ib](https://github.com/pilwon/node-ib) and [ib-sdk](https://github.com/triploc/ib-sdk) in a production environment.

## Set up GCP
*Note: These instructions are for setting up a paper trading account.*
*Ask Ronny for instructions on how to set up live trading.*
*Also, if you have 2FA set up on your live account, you'll need the IBKR mobile app*
1. Create a [GCP account](https://cloud.google.com/)
1. Create a project called `leverheads`
	- ![GCP Console New Project](images/tutorial/gcp_console_new_project_click.gif)
1. Make sure you're allowed to create a GCP instance by going to the [VM Instances](https://console.cloud.google.com/compute/instances) page
	- You may see a message saying that you need to Enable Billing. Click the blue "Enable Billing" button to continue.
	- You may see a message saying that you need to Enable the Compute Engine API. Click the blue Enable API button to continue.
1. Open the Cloud Shell (top-right corner of the screen)
	- ![Cloud Shell](images/tutorial/activate_cloud_shell.png)
1. Download some necessary files by copy-pasting the below commands into the terminal
```
git clone https://github.com/ronnyli/headless-ib-gateway-installation-ubuntu-server.git
cd headless-ib-gateway-installation-ubuntu-server
```
6. Run the `gcloud_commands.sh` script by copy-pasting the below command into the terminal
	- `sh gcloud_commands.sh`
1. Provide your username and password when you're prompted:
	- ![User/Password Prompt](images/tutorial/user_pass_prompt.png)
1. You'll also be asked to name your GCP instance but you can simply press <kbd>Enter</kbd> to skip this step
1. When the script is done you'll see a link that looks like `http://127.0.0.1:8888/?token=alphanum3r1cstr1ng`. Copy and paste it into the URL address but replace `127.0.0.1` with the External IP address of your new GCP instance.
	1. You can find the External IP address on the [VM Instances](https://console.cloud.google.com/compute/instances) page ![External IP Address on GCP](images/tutorial/ib_gateway_external_ip_address.png)
1. You can run any Python code that needs to interact with IB in this JupyterLab setup.
	- For example, after installing `ib_insync` and `dataclasses`: ![Jupyterlab](images/tutorial/jupyterlab.png)
1. For security purposes, it is recommended that you edit your [Firewall Rules](https://console.cloud.google.com/networking/firewalls/list) to only allow access from your IP address.
	- The two rules that you want to edit are: `ingress-5900` and `ingress-8888`
	- Ask for help if necessary!
