#!/usr/bin/env bash

set -euo pipefail

if [ ! -f spark-2.3.0-bin-hadoop2.7.tgz ]; then
    echo "Downloading Spark binaries..."
    curl -O http://apache.mirrors.hoobly.com/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz

    if [ -d spark-2.3.0-bin-hadoop2.7 ]; then
        echo "Cleanup old spark distribution."
        rm -rf spark-2.3.0-bin-hadoop2.7
    fi

    tar xvf spark-2.3.0-bin-hadoop2.7.tgz
fi

#cp -f Dockerfile spark-2.3.0-bin-hadoop2.7/kudbernetes/dockerfiles/spark/Dockerfile
# cd spark-2.3.0-bin-hadoop2.7
# docker build -t jamesrcounts/spark:2.3.0 -f kubernetes/dockerfiles/spark/Dockerfile .
# docker push jamesrcounts/spark:2.3.0