# A Terraform template to run Dask on AWS ECS

INSTRUCTIONS

Before this process, you should have AWS CLI installed and configured on your local computer. In short, when you download AWS CLI
you need to run "aws configure" and set your user credentials. For region, type "eu-central-1".


1. Install Terraform
2. From AWS Console, download your IAM credentials (AccessKeyId and AWSSecretKey) and save them as environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, so Terraform can read them and authenticate itself to control your infrastructure.
Find your credentials by clicking your username on upper right, then "My Security Credentials". Open "Access keys" and then "Create New Access Key".
3. Locate to this folder and run ```$ terraform init```
4. Run ```$ terraform apply``` (when asked for a region, type `eu-central-1`)
5. Terraform will output the DNS of the load balancer from which you access the Jupyter Notebook instance. It can take some time for the cluster to be configured and ready.


6. Configure worker in Jupyter

Connect to the scheduler

```
from dask.distributed import Client

client = Client('sc.ds:8786')
display(client)
```


***IMPORTANT***: When you connect to your client, it will display a warning if there are any version mismatches.
If that is the case sure to downgrade/upgrade your libraries in Jupyter so they match the versions installed
on Dask scheduler/workers.




7. Increase or decrease number of workers at will by running the `num_workers.py` script. Example usage:
`num_workers.py 4`






