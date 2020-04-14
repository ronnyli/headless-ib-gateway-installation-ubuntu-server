git clone https://github.com/ronnyli/headless-ib-gateway-installation-ubuntu-server.git
cd headless-ib-gateway-installation-ubuntu-server
# EDIT IBController.ini with your username/password

gcloud create project leverheads

gcloud beta compute \
--project=leverheads instances create ib-gateway \
--zone=northamerica-northeast1-a \
--machine-type=g1-small \
--subnet=default \
--network-tier=PREMIUM \
--maintenance-policy=MIGRATE \
--service-account=599937284915-compute@developer.gserviceaccount.com \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
--tags=http-server,https-server \
--image=ubuntu-1804-bionic-v20200317 \
--image-project=ubuntu-os-cloud \
--boot-disk-size=10GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=ib-gateway \
--no-shielded-secure-boot \
--shielded-vtpm \
--shielded-integrity-monitoring \
--reservation-affinity=any

echo | gcloud compute scp --zone northamerica-northeast1-a jts.ini ib-gateway:~
echo | gcloud compute scp --zone northamerica-northeast1-a IBControllerGatewayStart.sh ib-gateway:~
echo | gcloud compute scp --zone northamerica-northeast1-a IBController.ini ib-gateway:~
echo | gcloud compute scp --zone northamerica-northeast1-a gcp-setup.sh ib-gateway:~

gcloud compute ssh \
--zone northamerica-northeast1-a \
ib-gateway \
--command 'sudo sh gcp-setup.sh'

gcloud compute \
--project=leverheads firewall-rules create default-allow-http \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:80 \
--source-ranges=0.0.0.0/0 \
--target-tags=http-server


gcloud compute \
--project=leverheads firewall-rules create default-allow-https \
--direction=INGRESS \
--priority=1000 \
--network=default \
--action=ALLOW \
--rules=tcp:443 \
--source-ranges=0.0.0.0/0 \
--target-tags=https-server
