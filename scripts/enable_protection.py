import boto3



if __name__ == "__main__":
    client_asg = boto3.client('autoscaling')
    client_ecs = boto3.client('ecs')
    services = ["service_scheduler", "service_jupyter"]
    jupyter_arn = client_ecs.list_tasks(cluster='dask-cluster', serviceName='service-jupyter')['taskArns'][0]
    scheduler_arn = client_ecs.list_tasks(cluster='dask-cluster', serviceName='service-scheduler')['taskArns'][0]

    jupyter_container_instance = client_ecs.describe_tasks(cluster='dask-cluster', tasks=[jupyter_arn])['tasks'][0]['containerInstanceArn']
    scheduler_container_instance = client_ecs.describe_tasks(cluster='dask-cluster', tasks=[scheduler_arn])['tasks'][0]['containerInstanceArn']

    jupyter_instance = client_ecs.describe_container_instances(cluster='dask-cluster', containerInstances=[jupyter_container_instance])['containerInstances'][0]['ec2InstanceId']
    scheduler_instance = client_ecs.describe_container_instances(cluster='dask-cluster', containerInstances=[scheduler_container_instance])['containerInstances'][0]['ec2InstanceId']

    client_asg.set_instance_protection(InstanceIds = [jupyter_instance, scheduler_instance], AutoScalingGroupName='dask_cluster_asg', ProtectedFromScaleIn=True)

    #print(client_ecs.describe_services(cluster='dask-cluster', services=['service-jupyter'])['services'][0]['deployments'])
