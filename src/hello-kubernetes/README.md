This is a simple spark job that calculates PI

* `sbt package`
* submit to kubernetes

    ```bash
    YOUR_SPARK_HOME/bin/spark-submit \
      --master k8s:// https://api-kops1-k8s-local-u6p60a-84930116.us-west-1.elb.amazonaws.com
      --deploy-mode cluster \
      --class "SimpleApp" \
      --name SimpleApp \
      --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
      --conf spark.executor.instances=16 \
      --conf spark.kubernetes.container.image=jamesrcounts/simpleapp:latest \
      local:///opt/spark/jars/hello-kubernetes_2.11-0.1.jar
    ```