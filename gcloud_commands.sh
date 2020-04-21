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

while [ "${IB_CREDENTIALS::1}" != "y" ]
do
    read -p "Type in your IB user name, then press Enter: " IB_USER_NAME
    read -s -p "Type in your IB password, then press Enter: " IB_PASSWORD
    echo
    read -p "Confirm that the IB username/password was entered correctly (type yes or no): " IB_CREDENTIALS
done

echo "IbLoginId=${IB_USER_NAME}" >> config/config.ini
echo "IbPassword=${IB_PASSWORD}" >> config/config.ini

read -p "GCP Instance Name (leave blank unless you have a reason to change it): " GCP_INSTANCE_NAME_USER_INPUT
GCP_INSTANCE_NAME=${GCP_INSTANCE_NAME_USER_INPUT:-ib-gateway}
read -p "GCP Zone (leave blank unless you have a reason to change it): " GCP_ZONE_USER_INPUT
GCP_ZONE=${GCP_ZONE_USER_INPUT:-northamerica-northeast1-a}

gcloud beta compute \
--project=$LEVERHEADS_PROJECT_ID instances create $GCP_INSTANCE_NAME \
--zone=$GCP_ZONE \
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
--boot-disk-device-name=$GCP_INSTANCE_NAME \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--reservation-affinity=any

sleep 1m

gcloud compute \
--project=$LEVERHEADS_PROJECT_ID firewall-rules create ingress-5900 \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:5900 \
--source-ranges=0.0.0.0/0

gcloud compute \
--project=$LEVERHEADS_PROJECT_ID firewall-rules create ingress-8888 \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:8888 \
--source-ranges=0.0.0.0/0

echo | gcloud compute scp --zone $GCP_ZONE --recurse config/ $GCP_INSTANCE_NAME:~
echo | gcloud compute scp --zone $GCP_ZONE gcp-setup.sh $GCP_INSTANCE_NAME:~


gcloud compute ssh \
--zone $GCP_ZONE \
$GCP_INSTANCE_NAME \
--command 'sudo sh gcp-setup.sh'
