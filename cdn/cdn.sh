#!/usr/bin/env bash

set -o errexit \
    -o nounset \
    -o pipefail

PAAS_ORG="gds-registers"
PAAS_SPACE="registers"
SERVICE="cdn-test"
DOMAIN="test.openregister.org"

registers() {
  curl -s 'https://register-reg.london.cloudapps.digital/records.csv' | grep -v information-sharing-agreement | awk -F, 'NR>1 {print $5}'
}

list=$(registers | awk -v domain="$DOMAIN" '{ print $1"."domain }'| paste -sd,)

cf target -o "$PAAS_ORG" -s "$PAAS_SPACE" || cf login -a api.london.cloud.service.gov.uk --sso -o "$PAAS_ORG" -s "$PAAS_SPACE"

echo "Creating $SERVICE cdn-route service if it doesn't exist"
cf service "$SERVICE" >/dev/null || cf create-service cdn-route cdn-route "$SERVICE" -c "{\"domain\": \"$list\"}"

challenges=$(cf service "$SERVICE" | grep "$DOMAIN" | awk '/^name:/ {print $2, $4}' | tr -d , | awk '{print "\""$1"\":\""$2"\","}')
cname=$(cf service cdn-test | grep -Eo '\w+\.cloudfront\.net')
routes=$(registers | awk -v domain="$DOMAIN" '{ print "\""$1"."domain"\"," }')

tmpf=$(mktemp "acme.XXXXXX.tfvars")

echo "tfvars output to $tmpf"

cat > "$tmpf" <<EOF
challenges = {
$challenges
}
cname = "$cname"
routes = [
$routes
]
EOF

echo "Terraform time!"
terraform init -backend-config="key=$DOMAIN"
terraform apply -var-file="$tmpf" -var=domain="$DOMAIN"
