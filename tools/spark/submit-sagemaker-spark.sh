#!/usr/bin/env bash

source ../../infrastructure/tf/out/env

MASTER=http://localhost:8001

./spark-2.3.0-bin-hadoop2.7/bin/spark-submit -v \
  --master k8s://${MASTER} \
  --deploy-mode cluster \
  --class FullModel.Main \
  --name SagemakerSpark \
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
  --conf spark.executor.instances=6 \
  --conf spark.kubernetes.container.image=jamesrcounts/sagemaker-spark:0.0.1 \
  --conf spark.linearregression.bucketName=${INPUT_BUCKET} \
  --jars http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.3/hadoop-aws-2.7.3.jar,http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar,http://central.maven.org/maven2/joda-time/joda-time/2.9.9/joda-time-2.9.9.jar \
  local:///opt/spark/jars/sagemaker-spark_2.11-0.1.jar