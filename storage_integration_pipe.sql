CREATE OR REPLACE STORAGE INTEGRATION helloworld_storage_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<myarn>:role/snowflake_role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://<mybucket>/');
  
  
  desc integration helloworld_storage_int;
 
 create or replace stage hello_world_stage
  url = 's3://<mybucket>/'
  storage_integration = helloworld_storage_int;
  
  list @hello_world_stage;
  
  create or replace pipe helloworld_db.public.hello_world_pipe 
  auto_ingest=true as
  copy into members
  from @hello_world_stage
  file_format = helloworld_db.public.hello_world_ff;
  
  ALTER PIPE HELLO_WORLD_PIPE SET PIPE_EXECUTION_PAUSED=FALSE;
  
  select SYSTEM$PIPE_FORCE_RESUME('HELLO_WORLD_PIPE');
  
  ALTER PIPE HELLO_WORLD_PIPE REFRESH;
  
  GRANT OWNERSHIP ON PIPE "HELLOWORLD_DB"."PUBLIC".hello_world_pipe to role "SNOWPIPE_ROLE";
  

-- Set the role as the default role for the user
alter user dummy set default_role = snowpipe_role;


show pipes;

select SYSTEM$PIPE_STATUS('HELLO_WORLD_PIPE' ); -- To see the status of the pipe
  
