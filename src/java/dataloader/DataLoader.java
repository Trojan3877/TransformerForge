package dataloader;

import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;
import java.time.Instant;

/**
 * DataLoader
 * ───────────────────────────────────────────────────────────────────────────
 * Reads Delta Lake or Parquet files from S3 / ADLS, selects the text column,
 * cleans it, and writes sharded JSONL files that downstream Python
 * scripts (train.py) upload to SageMaker.
 *
 * Usage (spark-submit):
 *   spark-submit \
 *     --class dataloader.DataLoader \
 *     --packages io.delta:delta-spark_2.12:3.1.0 \
 *     target/transformerforge-dataloader.jar \
 *     s3://bucket/delta/events \
 *     s3://bucket/forge-jsonl/  \
 *     body_text
 */
public class DataLoader {

    public static void main(String[] args) {
        if (args.length < 3) {
            System.err.println("Required args: <input_path> <output_path> <text_column>");
            System.exit(1);
        }
        String inputPath  = args[0];
        String outputPath = args[1] + "/run-" + Instant.now().toString().replace(":", "-");
        String textCol    = args[2];

        SparkSession spark = SparkSession.builder()
                .appName("TransformerForge-DataLoader")
                .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
                .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
                .getOrCreate();

        // 1. Read Delta or Parquet
        Dataset<Row> df = spark.read().format("delta").load(inputPath);

        // 2. Basic cleaning: drop nulls, trim whitespace, length filter
        Dataset<Row> cleaned = df
                .na().drop(textCol)
                .withColumn(textCol, org.apache.spark.sql.functions.trim(df.col(textCol)))
                .filter(org.apache.spark.sql.functions.length(df.col(textCol)).gt(30));

        // 3. Write sharded JSONL (one record per line)
        cleaned.select(textCol)
               .repartition(64)
               .write()
               .mode("overwrite")
               .text(outputPath);   // produces part-0000*.txt

        System.out.printf("✅ Wrote %d rows to %s%n", cleaned.count(), outputPath);
        spark.stop();
    }
}
