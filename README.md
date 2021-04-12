# A Terraform template to run Dask on AWS ECS

INSTRUCTIONS

Before this process, you should have AWS CLI installed and configured on your local computer. In short, when you download AWS CLI
you need to run "aws configure" and set your user credentials and region "eu-central-1".


1. Install Terraform
2. Locate to this folder and run `terraform init`
3. From AWS Console, download your IAM credentials (AccessKeyId and AWSSecretKey) and save them as environment variables, so terraform can read them 
4. Run `terraform apply` (when asked for a region, type `eu-central-1`)
5. Terraform will output the DNS of the load balancer from which you access the Jupyter Notebook instance




5. Get Jupyter login token 

`aws logs describe-log-streams --log-group-name /ecs/jupyter --query "logStreams[*].logStreamName"`

This command will display a name of a log stream, since Jupyter outputs the token in stdout. Then get the token

`aws logs filter-log-events --log-group-name /ecs/jupyter --log-stream-names {your_log_stream_name} --query "events[*].message" --filter-pattern "token"`

6. Configure worker in Jupyter

`{from dask.distributed import Client
client = Client('sc.ds:8786')}`




6. Increase or decrease number of workers at will - note that if you want to set the desired capacity of worker service at some value, 
you need to set the desired capacity of the autoscaling group as worker desired capacity + 2, since it includes a jupyter and a scheduler instance 

Here we set the number of workers to 4.

aws autoscaling set-desired-capacity --auto-scaling-group-name dask_cluster_asg --desired-capacity 6
aws ecs update-service --cluster dask-cluster --service service-worker --desired-count 4