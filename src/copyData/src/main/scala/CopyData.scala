package io.timpark

import org.apache.spark.sql.SparkSession

object CopyData {
  def main(args: Array[String]) {
    val spark = SparkSession
      .builder
      .appName("CopyData")
      .getOrCreate()

    val conf = spark.sparkContext.getConf
    val containerpath = conf.get("spark.copydata.containerpath")
    println(containerpath)

    spark.sparkContext.hadoopConfiguration.set(
      "fs.defaultFS",
      conf.get("spark.copydata.containerpath")
    )

    spark.sparkContext.hadoopConfiguration.set(
      "fs.azure.account.key." + conf.get("spark.copydata.storageaccount") + ".blob.core.windows.net",
      conf.get("spark.copydata.storageaccountkey")
    )

    val data = spark.read
      .format("com.databricks.spark.avro")
      .load(conf.get("spark.copydata.frompath"))

    data.write
      .mode("overwrite")
      .format("com.databricks.spark.avro")
      .save(conf.get("spark.copydata.topath"))

    spark.stop()
  }
}
