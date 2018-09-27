#!/usr/bin/env bash

if [ -z ${1+x} ];
    then
        echo "You must pass an input folder";
        echo "Example: local-run.sh ../../infrastructure/tf/out"
        exit -1
fi

INPUT_FOLDER=$1

source "${INPUT_FOLDER}/env"

export INPUT_BUCKET=${INPUT_BUCKET}
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

sbt run


