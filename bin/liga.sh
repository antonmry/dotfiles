PROJECT_ID="proxy-laliga"
ZONE="europe-west1-b"
NAME="socks-bastion"

gcloud config set project $PROJECT_ID

gcloud compute instances create "$NAME" \
  --zone="$ZONE" \
  --machine-type=e2-micro \
  --image-family=debian-12 \
  --image-project=debian-cloud

gcloud compute firewall-rules create allow-ssh-ingress-from-iap \
  --direction=INGRESS \
  --action=allow \
  --rules=tcp:22 \
  --source-ranges=35.235.240.0/20

gcloud compute ssh "$NAME" --zone "$ZONE" --tunnel-through-iap -- -N -D 1080

gcloud compute instances delete socks-bastion \
  --zone=europe-west1-b

gcloud compute firewall-rules delete allow-ssh-ingress-from-iap
