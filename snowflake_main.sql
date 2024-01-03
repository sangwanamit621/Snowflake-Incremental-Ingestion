-- use role
use role accountadmin;

-- create new database
create or replace database snowpipe_project;

use snowpipe_project;

-- create table
create or replace table orders_data(
    order_id int,
    product varchar(20),
    quantity int,
    order_status varchar(40),
    order_date date
);


-- create a cloud storage integration in snowflake i.e., creating config based secure access to bucket
create or replace storage integration gcs_bucket_access
    type = external_stage -- means integration for external service
    storage_provider = gcs -- s3 for aws and blob for azure
    enabled = true
    storage_allowed_locations = ('gcs://snowflake_621/');



-- create stage which will be reference to a specific external location where data will arrive
create or replace stage snowflake_stage
    url = 'gcs://snowflake_621/'
    storage_integration = gcs_bucket_access;



-- Then we will create another integration for pub-sub notification integration to read data from pubsub topic
create or replace notification integration pubsub_notification_alert
    type = queue
    notification_provider = gcp_pubsub
    enabled = true
    gcp_pubsub_subscription_name = 'projects/gcp-learning-408910/subscriptions/file_add_notification-sub';

 
-- create table where we will keep those orders whose order_status is complete
create or replace table completed_orders_data(
    order_id int,
    product varchar(20),
    quantity int,
    order_status varchar(40),
    order_date date
);


-- creating task which will run every day to load completed orders data in completed_orders_data table
create or replace task update_completed_orders_data_table
    warehouse = FIRST
    schedule = 'USING CRON 0 0 * * * UTC'
    as
    insert into completed_orders_data select * from orders_data where order_status='Completed' and order_id not in (select order_id from completed_orders_data) ;



-- When we create a new task it's got created with suspended status so we have to resume the task using alter command and change its status to resume
alter task update_completed_orders_data_table resume;


-- If we want to suspend this task again then we will change the status to suspend
-- alter task update_completed_orders_data_table suspend;

-- Creating other tasks and chaining them with above task to create depenedency and these tasks will run after execution of first task `update_completed_orders_data_table`
-- Here we dont have to explicitly resume the task as it will be triggered after execution of the dependent task
create or replace task truncate_stage_table
    warehouse = FIRST
    after update_completed_orders_data_table
    as
    truncate table orders_data; 


create or replace task delete_old_data
    warehouse = FIRST
    after update_completed_orders_data_table
    as
    delete from completed_orders_data where year(order_date)-year(current_date())>3;