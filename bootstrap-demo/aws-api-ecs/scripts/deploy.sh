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

VPC_ID=$(
  aws ec2 describe-vpcs \
    --region $REGION \
    --profile $PROFILE \
    --filters \
      Name=isDefault,Values=true \
    --output text \
    --query \
      "Vpcs[0].VpcId"
)
SUBNETS=$(
  aws ec2 describe-subnets \
    --region $REGION \
    --profile $PROFILE \
    --filter \
      Name=vpcId,Values=$VPC_ID \
      Name=defaultForAz,Values=true \
    --output text \
    --query \
      "Subnets[].SubnetId | join(',', @)"
)

aws cloudformation $ACTION-stack \
  --region $REGION \
  --stack-name ecs-bootstrap-demo-app \
  --template-body file://$DIR/../cfn-templates/ecs-bootstrap-demo-app.yaml \
  --capabilities CAPABILITY_IAM \
  --parameters \
    ParameterKey=Subnets,ParameterValue=\"$SUBNETS\" \
    ParameterKey=VPC,ParameterValue=\"$VPC_ID\"

aws cloudformation wait stack-$ACTION-complete \
  --region $REGION \
  --stack-name ecs-bootstrap-demo-app
