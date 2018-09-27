#!/usr/bin/env bash

source ../../infrastructure/tf/out/env

MASTER=http://localhost:8001

./spark-2.3.0-bin-hadoop2.7/bin/spark-submit \
  --master k8s://${MASTER} \
  --deploy-mode cluster \
  --class SimpleApp \
  --name SimpleApp \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  --conf spark.executor.instances=16 \
  --conf spark.kubernetes.container.image=jamesrcounts/hello-kubernetes:latest \
  local:///opt/spark/jars/hello-kubernetes_2.11-0.1.jar