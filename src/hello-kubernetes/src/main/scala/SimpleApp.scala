import org.apache.log4j.{Level, LogManager}
import org.apache.spark.sql.SparkSession

object SimpleApp {

  def NUM_SAMPLES = 1000

  def main(args: Array[String]) {
    val spark = SparkSession.builder
      .appName("Simple Application")
//      .master("local[4]")
      .getOrCreate()

    val  count  = spark.sparkContext.parallelize(1 to NUM_SAMPLES).filter { _ =>
      val x = math.random
      val y = math.random
      x*x + y*y < 1
    }.count()

    val log = LogManager.getRootLogger
    log.setLevel(Level.INFO)
    log.info(s"Pi is roughly ${4.0 * count / NUM_SAMPLES}")

    spark.stop()
  }
}