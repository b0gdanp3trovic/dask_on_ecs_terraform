import boto3

if __name__ == "__main__":
    client_asg = boto3.client('autoscaling')