#!/bin/bash

set -euo pipefail

if [ $# -ne 0 ]
  then
    echo "Usage: $0"
    exit 1
fi

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

(cd $DIR/../../.. && sbt bootstrap-demo-aws-api-ecs/docker:publishLocal)

REGION=eu-west-1
PROFILE=default

eval $(
  aws ecr get-login \
    --region $REGION \
    --profile $PROFILE \
    --no-include-email
)

AWS_ACCOUNT_ID=$(
  aws sts get-caller-identity \
    --output text \
    --query \
      "Account"
)

docker tag \
  ecs-bootstrap-demo-app:1.0 \
  $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/ecs-bootstrap-demo-app:1.0

docker push \
  $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/ecs-bootstrap-demo-app:1.0

docker rmi \
  ecs-bootstrap-demo-app:1.0

docker rmi \
  $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/ecs-bootstrap-demo-app:1.0
