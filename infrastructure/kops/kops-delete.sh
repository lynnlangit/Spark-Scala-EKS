#!/usr/bin/env bash

if [ -z ${1+x} ];
    then
        echo "You must pass an input folder";
        echo "Example: kops-delete.sh ./input"
        exit -1
fi

INPUT_FOLDER=$1
ENV_FILE=${INPUT_FOLDER}/env

source ${ENV_FILE}

export KOPS_STATE_STORE=${KOPS_STATE_STORE}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}

KOPS_NAME=${PROJECT}.k8s.local

kops delete cluster \
    --name ${KOPS_NAME} \
    --yes
