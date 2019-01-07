#!/bin/bash

set -euo pipefail

if [ $# -ne 1 ]
  then
    echo "Usage: $0 <create|update>"
    exit 1
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

REGION=eu-west-1
PROFILE=default

case $1 in
  create | update)
    ACTION=$1
    ;;
  *)
    echo "Usage: $0 <create|update>"
   exit 1
    ;;
esac

aws cloudformation $ACTION-stack \
  --region $REGION \
  --profile $PROFILE \
  --stack-name ecs-bootstrap-demo-app-infrastructure \
  --template-body file://$DIR/../cfn-templates/ecs-bootstrap-demo-app-infrastructure.yaml

aws cloudformation wait stack-$ACTION-complete \
  --region $REGION \
  --profile $PROFILE \
  --stack-name ecs-bootstrap-demo-app-infrastructure
