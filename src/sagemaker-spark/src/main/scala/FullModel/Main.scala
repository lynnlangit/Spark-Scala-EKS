package FullModel

import org.apache.spark.ml.regression.{LinearRegression, LinearRegressionModel}
import org.apache.spark.sql.{DataFrame, SaveMode, SparkSession}

object Main {
  def main(args: Array[String]) {
    // Startup
    val spark = SparkSession
      .builder
      .appName("LinearRegressionWithElasticNetExample")
//      .master("local[4]")
      .getOrCreate()

//    spark.conf.set("spark.executor.memory", "1g")

    val conf = spark.sparkContext.getConf
    val bucketNameOption: Option[String] = conf.getOption("spark.linearregression.bucketName")
    val bucketName = bucketNameOption match {
      case Some(name) =>
        name
      case None =>
        sys.env("INPUT_BUCKET")
    }


    // Load training data
    val inputUrn = s"s3a://${bucketName}/input/sample_linear_regression_data.txt"
    val allData: DataFrame = spark.read.format("libsvm")
      .load(inputUrn)

    allData.show

    val splitSeed = 5043
    val Array(trainingData, testData) = allData.randomSplit(Array(0.7, 0.3), splitSeed)

    val lr = new LinearRegression()
      .setMaxIter(10)
      .setRegParam(0.3)
      .setElasticNetParam(0.8)

    // Fit the model
    val lrModel0: LinearRegressionModel = lr.fit(trainingData)
    val modelPath = s"s3a://${bucketName}/output/model"


    // Summarize the model over the training set and print out some metrics
    val trainingSummary = lrModel0.summary
    println(s"numIterations: ${trainingSummary.totalIterations}")
    println(s"objectiveHistory: [${trainingSummary.objectiveHistory.mkString(",")}]")
    trainingSummary.residuals.show()
    println(s"RMSE: ${trainingSummary.rootMeanSquaredError}")
    println(s"r2: ${trainingSummary.r2}")

    // Serialize the model
    lrModel0.write.overwrite.save(modelPath)

    // Print the coefficients and intercept for linear regression
    println(s"Coefficients: ${lrModel0.coefficients} Intercept: ${lrModel0.intercept}")

    // run the  model on test features to get predictions
    val predictions: DataFrame = lrModel0.transform(testData)

    //predictions : [label, features, prediction]
    predictions
      .select("label", "prediction")
      .write
      .option("header", "true")
      .mode(SaveMode.Overwrite)
      .csv(s"s3a://${bucketName}/output/predictions")

    // Shut down
    spark.stop()
  }
}