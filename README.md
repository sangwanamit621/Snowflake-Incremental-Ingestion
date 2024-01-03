# Snowflake-Incremental-Ingestion
This project demonstrates a data pipeline using Snowflake, Google Cloud Storage (GCS), and Pub/Sub for loading data incrementally into Snowflake tables. The pipeline is triggered by new files arriving in a specified GCS bucket, notifying Snowflake through Pub/Sub, and subsequently updating tables in Snowflake.

## Overview

The project involves the following components:

1. **Database and Tables:**
    - A new Snowflake database (`snowpipe_project`) is created.
    - A table (`orders_data`) is created to store order information.

2. **Cloud Storage Integration:**
    - A storage integration (`gcs_bucket_access`) is created to securely access GCS.
    - An external stage (`snowflake_stage`) is defined to reference the GCS location where data will arrive.

3. **Pub/Sub Notification Integration:**
    - A notification integration (`pubsub_notification_alert`) is established for Pub/Sub.
    - It is configured to listen to a specific Pub/Sub subscription for file addition notifications.

4. **Additional Tables and Tasks:**
    - Another table (`completed_orders_data`) is created to store completed orders.
    - A task (`update_completed_orders_data_table`) is scheduled to run daily, loading completed orders into the new table.
    - A second task (`truncate_stage_table`) is created and chained to the first task, deleting records older than 7 days from `completed_orders_data`.


## Prerequisites

Before getting started, ensure you have the following:

  - Snowflake account and access credentials
  - Google Cloud Platform (GCP) account with GCS and Pub/Sub access


## Setup

1. **Create Snowflake Database:**
    ```sql
    use role accountadmin;
    create or replace database snowpipe_project;
    use snowpipe_project;
    ```

2. **Create Tables:**
    ```sql
    create or replace table orders_data (
        order_id int,
        product varchar(20),
        quantity int,
        order_status varchar(40),
        order_date date
    );

    create or replace table completed_orders_data (
        order_id int,
        product varchar(20),
        quantity int,
        order_status varchar(40),
        order_date date
    );
    ```

3. **Cloud Storage Integration:**
    ```sql
    create or replace storage integration gcs_bucket_access
        type = external_stage
        storage_provider = gcs
        enabled = true
        storage_allowed_locations = ('gcs://snowflake_621/');
    ```

4. **External Stage:**
    ```sql
    create or replace stage snowflake_stage
        url = 'gcs://snowflake_621/'
        storage_integration = gcs_bucket_access;
    ```

5. **Pub/Sub Notification Integration:**
    ```sql
    create or replace notification integration pubsub_notification_alert
        type = queue
        notification_provider = gcp_pubsub
        enabled = true
        gcp_pubsub_subscription_name = 'projects/gcp-learning-408910/subscriptions/file_add_notification-sub';
    ```

6. **Tasks:**
    ```sql
    create or replace task update_completed_orders_data_table
        warehouse = FIRST
        schedule = 'USING CRON 0 0 * * * UTC'
        as
        insert into completed_orders_data select * from orders_data where order_status='Completed' and order_id not in (select order_id from completed_orders_data);

    alter task update_completed_orders_data_table resume;

    create or replace task truncate_stage_table
        warehouse = FIRST
        after update_completed_orders_data_table
        as
        delete from completed_orders_data where order_date - current_date() < 7;
    ```

## Usage

1. **Run Snowflake Task:**
    - Execute the following SQL to start the tasks:
        ```sql
        alter task update_completed_orders_data_table resume;
        ```

2. **Monitor Execution:**
    - Monitor Snowflake and Google Cloud Console for task executions and file addition notifications.

3. **Customization:**
    - Adjust the task schedules, integration configurations, and other parameters as needed for your specific use case.


