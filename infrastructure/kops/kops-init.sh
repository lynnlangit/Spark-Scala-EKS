#!/usr/bin/env bash

# set -euo pipefail

if [ -z ${1+x} ];
    then
        echo "You must pass an input folder";
        echo "Example: kops-init.sh ./input"
        exit -1
fi

INPUT_FOLDER=$1
ENV_FILE=${INPUT_FOLDER}/env

source ${ENV_FILE}

export KOPS_STATE_STORE=${KOPS_STATE_STORE}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}

KOPS_NAME=${PROJECT}.k8s.local
KOPS_YAML="kops1.yaml"

echo "Creating kops cluster"
kops create cluster \
    --zones ${AWS_AVAILABILITY_ZONE} \
    --node-size t2.xlarge \
    --ssh-public-key ${INPUT_FOLDER}/id_rsa.pub \
    ${KOPS_NAME}

#kops create secret \
#    --name ${KOPS_NAME} \
#    sshpublickey admin \
#    -i ${INPUT_FOLDER}/id_rsa.pub

POLICY=$(cat <<EOF

  additionalPolicies:
    node: |
      [
        {
          "Effect": "Allow",
          "Action": ["s3:*"],
          "Resource": ["*"]
        }
      ]
EOF
)

YAML=`kops get cluster ${KOPS_NAME} -o yaml`

echo "${YAML}${POLICY}" > cluster.yaml

kops replace \
    -f cluster.yaml

kops update cluster \
    ${KOPS_NAME} \
    --yes

echo "Kube context is now:"
kubectl config current-context