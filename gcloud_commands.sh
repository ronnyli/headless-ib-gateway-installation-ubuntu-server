HEADLESS_SERVER_REPO_FOUND=$(ls ~ | grep headless-ib-gateway-installation-ubuntu-server | wc -l)
if [ $HEADLESS_SERVER_REPO_FOUND -eq 1 ]
then
    cd ~/headless-ib-gateway-installation-ubuntu-server
    git pull
else
    cd ~
    git clone https://github.com/ronnyli/headless-ib-gateway-installation-ubuntu-server.git
    cd ~/headless-ib-gateway-installation-ubuntu-server
fi
# EDIT config.ini with your username/password (search for <YOUR_INPUT_HERE>)

LEVERHEADS_PROJECT_FOUND=$(gcloud projects list --filter leverheads | wc -l)
if [ $LEVERHEADS_PROJECT_FOUND -gt 1 ]
then
    echo 'leverheads project already exists. Skipping...'
else
    echo 'ERROR: Need to create a leverheads project before continuing'
    echo 'see: https://github.com/ronnyli/headless-ib-gateway-installation-ubuntu-server for instructions'
    exit 1
fi
LEVERHEADS_PROJECT_ID=$(gcloud projects list --filter leverheads | tail -n 1 | cut -d ' ' -f1)

gcloud beta compute \
--project=$LEVERHEADS_PROJECT_ID instances create ib-gateway \
--zone=northamerica-northeast1-a \
--machine-type=g1-small \
--subnet=default \
--network-tier=PREMIUM \
--maintenance-policy=MIGRATE \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--tags=http-server,https-server \
--image=ubuntu-1804-bionic-v20200414 \
--image-project=ubuntu-os-cloud \
--boot-disk-size=10GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=ib-gateway \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--reservation-affinity=any

sleep 1m

gcloud compute \
--project=$LEVERHEADS_PROJECT_ID firewall-rules create ingress-4001 \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:4001 \
--source-ranges=0.0.0.0/0

gcloud compute \
--project=$LEVERHEADS_PROJECT_ID firewall-rules create ingress-4002 \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:4002 \
--source-ranges=0.0.0.0/0

gcloud compute \
--project=$LEVERHEADS_PROJECT_ID firewall-rules create ingress-5900 \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:5900 \
--source-ranges=0.0.0.0/0

gcloud compute \
--project=leverheads firewall-rules create ingress-8888 \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:8888 \
--source-ranges=0.0.0.0/0

echo | gcloud compute scp --zone northamerica-northeast1-a jts.ini ib-gateway:~
echo | gcloud compute scp --zone northamerica-northeast1-a gatewaystart.sh ib-gateway:~
echo | gcloud compute scp --zone northamerica-northeast1-a config.ini ib-gateway:~
echo | gcloud compute scp --zone northamerica-northeast1-a gcp-setup.sh ib-gateway:~
echo | gcloud compute scp --zone northamerica-northeast1-a jupyter_notebook_config.py ib-gateway:~


gcloud compute ssh \
--zone northamerica-northeast1-a \
ib-gateway \
--command 'sudo sh gcp-setup.sh'
