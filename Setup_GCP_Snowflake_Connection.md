# Establishing Connection and Access Between Snowflake and GCP Services (Cloud Storage and Pub/Sub)
To enable communication and access between Snowflake and GCP services, specifically Cloud Storage and Pub/Sub, follow the steps outlined below:

1. **Fetch Service Email for GCS Storage Integration:**
    - After creating a storage integration for GCS in Snowflake, retrieve the service email created by Snowflake for this storage integration.
  Execute the following query:
    ```sql
    DESCRIBE INTEGRATION gcs_bucket_access;
    ```
    - Copy the service email account from the resulting row containing information related to the storage integration.

2. **Find Service Account for Notification Integration:**
    - Similarly, locate the service account for the notification integration.

3. **Configure GCS Bucket Permissions:**
    - Navigate to the GCS Bucket and go to the Permissions section.
    - Click on the "Grant" section for access permissions.
    - Paste the Snowflake-created service email account in the "Principal" field.
    - Assign the "Storage Object Viewer" role to the service email account.

4. **Set up Pub/Sub and Create a New Topic:**
    - Create a new topic in Pub/Sub to publish notification messages when a new object is added to the GCS bucket.
    - Open the GCloud Shell and run the following command to publish notification messages to the topic:
    ```sql
    gsutil notification create -t TopicName -f json BucketPath
    ```
    **Example:**
   ```sql
    gsutil notification create -t file_add_notification -f json gs://snowflake_621/
    ```
5. **Configure Pub/Sub Permissions:**
   - Create a new role in IAM for Pub/Sub-related permissions, including "pub/sub subscriber" and "monitoring.timeSeries.list".
   - Inside the Pub/Sub topic, navigate to permissions.
   - Add the Snowflake service email account for the notification integration in the "Principal" field.
   - Assign the newly created role to the service email account for Pub/Sub-related permissions.

These steps provide a structured guide to establishing the necessary connections and permissions between Snowflake and GCP services.
