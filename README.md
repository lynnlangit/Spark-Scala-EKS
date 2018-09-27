# Scala Spark Simple Docker Example

This example shows:

* A simple Spark/Scala ML example docker container
* Can run locally
* Can run on AWS EKS (Kubernetes) or Sagemaker

## Updated Example Code

Derived from: [SGD Linear Regression Example with Apache Spark](https://www.bmc.com/blogs/sgd-linear-regression-example-apache-spark/)
by Walker Rowe published May 23, 2017.

This example shows a basic linear regression example and has been modified to run as an app rather than in the
interactive shell. Update, new example: [Linear Regression](https://spark.apache.org/docs/2.1.0/ml-classification-regression.html#linear-regression) from Spark Documentation. The new example has been updated to add serialization/deserialization and a split between training and test data.

Further reference [Predicting Breast Cancer Using Apache Spark Machine Learning Logistic Regression](https://mapr.com/blog/predicting-breast-cancer-using-apache-spark-machine-learning-logistic-regression/) by Carol McDonald published October 17, 2016.

## How to Run Locally

This is an sbt project.  Assuming we have a working scala and sbt, then execute `sbt run` from the project root.  In
addition to the log4j output from spark, you should also see a few lines of output from our example:

```text
18/04/17 15:15:56 INFO TaskSetManager: Finished task 0.0 in stage 14.0 (TID 17) in 21 ms on localhost (executor driver) (1/1)
18/04/17 15:15:56 INFO TaskSchedulerImpl: Removed TaskSet 14.0, whose tasks have all completed, from pool
18/04/17 15:15:56 INFO DAGScheduler: ResultStage 14 (show at Main.scala:55) finished in 0.022 s
18/04/17 15:15:56 INFO DAGScheduler: Job 12 finished: show at Main.scala:55, took 0.026455 s
18/04/17 15:15:56 INFO CodeGenerator: Code generated in 8.628902 ms
+-------------------+--------------------+-------------------+
|              label|            features|         prediction|
+-------------------+--------------------+-------------------+
|-28.571478869743427|(10,[0,1,2,3,4,5,...|-1.5332357772511678|
|-26.736207182601724|(10,[0,1,2,3,4,5,...|-3.1990639907463776|
|-22.949825936196074|(10,[0,1,2,3,4,5,...|  2.068559275392233|
|-20.212077258958672|(10,[0,1,2,3,4,5,...| 0.5963989456221626|
|-17.026492264209548|(10,[0,1,2,3,4,5,...|-0.7387387189956682|
|-15.348871155379253|(10,[0,1,2,3,4,5,...|  -1.98575929759793|
|-13.039928064104615|(10,[0,1,2,3,4,5,...| 0.5942050121612523|
| -12.92222310337042|(10,[0,1,2,3,4,5,...|  2.203905559769596|
|-12.773226999251197|(10,[0,1,2,3,4,5,...| -2.736222698097398|
|-12.558575788856189|(10,[0,1,2,3,4,5,...|0.10007973294293643|
|-12.479280211451497|(10,[0,1,2,3,4,5,...|-0.9022515201372355|
| -12.46765638103286|(10,[0,1,2,3,4,5,...|-1.4621820914334354|
|-11.904986902675114|(10,[0,1,2,3,4,5,...|-0.3122307364002444|
| -11.87816749996684|(10,[0,1,2,3,4,5,...| 0.1338819458914437|
| -11.43180236554046|(10,[0,1,2,3,4,5,...| 0.5248457739492374|
|-11.328415936777782|(10,[0,1,2,3,4,5,...| 0.1542916456260936|
|-11.039347808253828|(10,[0,1,2,3,4,5,...|-1.3518353509995789|
|-10.600130341909033|(10,[0,1,2,3,4,5,...| 0.4030016168294734|
|-10.293714040655924|(10,[0,1,2,3,4,5,...| -1.364529194363915|
| -9.892155927826222|(10,[0,1,2,3,4,5,...| -1.068980736429676|
+-------------------+--------------------+-------------------+
only showing top 20 rows

18/04/17 15:15:56 INFO SparkUI: Stopped Spark web UI at http://192.168.86.21:4040
18/04/17 15:15:56 INFO MapOutputTrackerMasterEndpoint: MapOutputTrackerMasterEndpoint stopped!
18/04/17 15:15:56 INFO MemoryStore: MemoryStore cleared
18/04/17 15:15:56 INFO BlockManager: BlockManager stopped
18/04/17 15:15:56 INFO BlockManagerMaster: BlockManagerMaster stopped
18/04/17 15:15:56 INFO OutputCommitCoordinator$OutputCommitCoordinatorEndpoint: OutputCommitCoordinator stopped!
18/04/17 15:15:56 INFO SparkContext: Successfully stopped SparkContext
```

## Run in Docker container

Assuming we have a working local Docker installation execute `sbt docker:publishLocal` to create the Docker image.

Once the command completes, execute `docker images` to view the docker image.  See output similar to the following:

```bash
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
sagemaker-spark     0.1                 29dc8b3b2dc8        20 seconds ago      379MB
openjdk             jre-alpine          b1bd879ca9b3        2 months ago        82MB
```

Now start a container to run the image by executing `docker run --rm sagemaker-spark:0.1`.  You should see output very
similar to the output from the local run.

> Note: You may see an error related to insuficient memory, like the one shown below.  In which case try increasing your
docker engine's memory allocation to 4GB.

```bash
18/04/05 18:40:29 ERROR SparkContext: Error initializing SparkContext.
java.lang.IllegalArgumentException: System memory 466092032 must be at least 471859200. Please increase heap size using the --driver-memory option or spark.driver.memory in Spark configuration.
      at org.apache.spark.memory.UnifiedMemoryManager$.getMaxMemory(UnifiedMemoryManager.scala:216)
      at org.apache.spark.memory.UnifiedMemoryManager$.apply(UnifiedMemoryManager.scala:198)
      at org.apache.spark.SparkEnv$.create(SparkEnv.scala:330)
      at org.apache.spark.SparkEnv$.createDriverEnv(SparkEnv.scala:174)
      at org.apache.spark.SparkContext.createSparkEnv(SparkContext.scala:257)
      at org.apache.spark.SparkContext.<init>(SparkContext.scala:432)
      at FullModel.Main$.main(Main.scala:17)
      at FullModel.Main.main(Main.scala)

```

## Setup Scala Project including Docker

Reference: [Lightweight docker containers for Scala apps](https://medium.com/jeroen-rosenberg/lightweight-docker-containers-for-scala-apps-11b99cf1a666)
by Jeroen Rosenberg published August 14, 2017

1. Create an `object Main` with a `main` function.  Applications that extend `scala.App` will not work correctly<sup>[1](https://spark.apache.org/docs/latest/quick-start.html#self-contained-applications)</sup>.
1. Add the example code.
1. Since the example code does not demonstrate how to establish a `SparkContext` add the following:
    ```scala
    // Startup
    val conf = new SparkConf()
      .setMaster("local[2]")
      .setAppName("SGD")
      .set("spark.executor.memory", "1g")
    val sc = new SparkContext(conf)
    ```
1. Make sure to cleanup the context by adding the following to the example at the end:
    ```scala
    // Shut down
    sc.stop()
    ```
1. Update `build.sbt` to run locally
    1. Scala version must be no greather than `2.11.x`<sup>[2](https://spark.apache.org/docs/latest/)</sup>
    1. Spark version should be `2.1.0` and should look like the following:
        ```scala
        libraryDependencies ++= {
          val sparkVer = "2.1.0"
          Seq(
            "org.apache.spark" %% "spark-core" % sparkVer,
            "org.apache.spark" %% "spark-mllib" % sparkVer
          )
        }
        ```
    1. Update `project/build.properties`, set the `sbt.version` to `0.13.17`<sup>[3](https://medium.com/@mrpowers/creating-a-spark-project-with-sbt-intellij-sbt-spark-package-and-friends-cc9108751c28)</sup>
1. Add docker support
    1. Add `project/plugins.sbt` file with the following contents
        ```scala
        addSbtPlugin("com.typesafe.sbt" % "sbt-native-packager" % "1.2.1")
        ```
    1. Update `build.sbt`
        1. Add the following to the bottom of the file:
            ```scala
            enablePlugins(JavaAppPackaging)
            enablePlugins(DockerPlugin)
            enablePlugins(AshScriptPlugin)

            mainClass in Compile := Some("FullModel.Main")

            dockerBaseImage := "openjdk:jre-alpine"

            mappings in Universal += file("lpsa.data") -> "lpsa.data"
            ```
        1. The SBT commands enable plugins that
            1. Allow our app to be packaged as a jar(s) with an executable shell script
        to run it.
            1. Publish a docker image with the packaged app.
            1. Use `ash` as the shell instead of `bash` (needed for `alpine` based images)
        1. Next we declare the `mainClass` so that the generated app script knows which class to execute.
        1. Then we instruct the Docker plugin to use a smaller `alpine` based image rather than the default `Debian`
        based image.
        1. Finally we provide a file mapping which instructs the packaging system to include our data file in the staging
        directory that is later used to construct the image.<sup>[4](https://stackoverflow.com/a/29042110/36737)</sup>
