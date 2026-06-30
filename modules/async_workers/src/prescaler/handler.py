import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ecs = boto3.client("ecs")


def handler(event, context):
    """Scale ECS service up before an expected newsletter traffic spike."""
    cluster = os.environ["ECS_CLUSTER_ARN"]
    service = os.environ["ECS_SERVICE_NAME"]
    count = int(os.environ["PRE_SCALE_COUNT"])

    ecs.update_service(cluster=cluster, service=service, desiredCount=count)
    logger.info("Pre-scaled %s to %d tasks", service, count)
