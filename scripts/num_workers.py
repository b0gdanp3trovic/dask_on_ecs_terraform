import boto3
import sys 


if __name__ == "__main__":
    desired = int(sys.argv[1])
    client_asg = boto3.client('autoscaling')
    client_ecs = boto3.client('ecs')
    client_asg.set_desired_capacity(AutoScalingGroupName='dask_cluster_asg', DesiredCapacity=desired+2)
    client_ecs.update_service(cluster='dask-cluster', service='service-worker', desiredCount = desired)

    

