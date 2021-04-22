# A Terraform template to run Dask on AWS ECS

INSTRUCTIONS

Before this process, you should have AWS CLI installed and configured on your local computer. In short, when you download AWS CLI
you need to run "aws configure" and set your user credentials and region "eu-central-1".


1. Install Terraform
2. Locate to this folder and run ```$ terraform init```
3. From AWS Console, download your IAM credentials (AccessKeyId and AWSSecretKey) and save them as environment variables, so terraform can read them 
4. Run ```$ terraform apply``` (when asked for a region, type `eu-central-1`)
5. Terraform will output the DNS of the load balancer from which you access the Jupyter Notebook instance
6. Make sure that all of the cluster components are created and active. Then, run the `enable_protection.py` script.
With this script, you enable scale-in protection (they will not be destroyed during a scale-in action, which is when you reduce the number of workers) only for the EC2 instances hosting Jupyter Notebook and Dask Scheduler, because we need them up and running non stop. Other EC2 instances are the ones that host Dask Workers, and since we want
to be able change their number, we don't protect them from scale-in actions.


7. Get Jupyter login token 

```$ aws logs describe-log-streams --log-group-name /ecs/jupyter --query "logStreams[*].logStreamName"```

This command will display a name of a log stream, since Jupyter outputs the token in stdout. Get your log stream name and then get the token

```$ aws logs filter-log-events --log-group-name /ecs/jupyter --log-stream-names {your_log_stream_name} --query "events[*].message" --filter-pattern "token"```

8. Configure worker in Jupyter

Connect to the scheduler

```
from dask.distributed import Client
client = Client('sc.ds:8786')
```


***IMPORTANT***: We need to have the same version of Pandas in all components throughout the cluster, otherwise it causes problems with serialization/deserialization. Be sure to downgrade Pandas to 1.0.1 in your Jupyter Notebook to make working with Dataframes possible.
`pip install pandas=='1.0.1'`




9. Increase or decrease number of workers at will by running the `num_workers.py` script. Example usage:
`num_workers.py 4`

This will set the number of workers to 4.


