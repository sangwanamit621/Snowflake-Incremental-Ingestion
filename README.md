# Snowflake-Incremental-Ingestion
This project demonstrates a data pipeline using Snowflake, Google Cloud Storage (GCS), and Pub/Sub for loading data incrementally into Snowflake tables. The pipeline is triggered by new files arriving in a specified GCS bucket, notifying Snowflake through Pub/Sub, and subsequently updating tables in Snowflake.
