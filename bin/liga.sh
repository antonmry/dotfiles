#!/usr/bin/env bash

set -euo pipefail

PROJECT_ID="proxy-laliga"
ZONE="europe-west1-b"
NAME="socks-bastion"
FIREWALL_RULE="allow-ssh-ingress-from-iap"

ACTION="${1:-}"

start() {
  gcloud config set project "$PROJECT_ID"

  if ! gcloud compute instances describe "$NAME" --zone="$ZONE" >/dev/null 2>&1; then
    gcloud compute instances create "$NAME" \
      --zone="$ZONE" \
      --machine-type=e2-micro \
      --image-family=debian-12 \
      --image-project=debian-cloud
  fi

  if ! gcloud compute firewall-rules describe "$FIREWALL_RULE" >/dev/null 2>&1; then
    gcloud compute firewall-rules create "$FIREWALL_RULE" \
      --direction=INGRESS \
      --action=allow \
      --rules=tcp:22 \
      --source-ranges=35.235.240.0/20
  fi

  echo "Waiting for $NAME to be RUNNING..."
  until gcloud compute instances describe "$NAME" --zone="$ZONE" --format='get(status)' 2>/dev/null | grep -q "^RUNNING$"; do
    sleep 5
  done

  echo "Waiting for SSH to become available via IAP..."
  until gcloud compute ssh "$NAME" --zone "$ZONE" --tunnel-through-iap --command="true" 2>/dev/null; do
    sleep 10
  done

  gcloud compute ssh "$NAME" --zone "$ZONE" --tunnel-through-iap -- -N -D 1080
}

stop() {
  gcloud config set project "$PROJECT_ID"

  gcloud compute instances delete "$NAME" --zone="$ZONE" --quiet || true
  gcloud compute firewall-rules delete "$FIREWALL_RULE" --quiet || true
}

case "$ACTION" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  *)
    trap stop EXIT
    start
    ;;
esac
