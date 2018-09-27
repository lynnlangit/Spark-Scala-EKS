#!/usr/bin/env bash

set -euo pipefail

if [ -z ${1+x} ];
    then
        echo "You must pass a version";
        echo "Example: 0.0.1"
        exit -1
fi

docker build -t jamesrcounts/sagemaker-spark:latest .
docker tag jamesrcounts/sagemaker-spark:latest jamesrcounts/sagemaker-spark:$1
docker push jamesrcounts/sagemaker-spark:latest
docker push jamesrcounts/sagemaker-spark:$1
