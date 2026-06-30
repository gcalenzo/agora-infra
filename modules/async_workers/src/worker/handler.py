import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    """Process SQS messages from the task queue."""
    failures = []

    for record in event.get("Records", []):
        message_id = record["messageId"]
        try:
            body = json.loads(record["body"])
            logger.info("Processing task: %s", body)
        except Exception as exc:
            logger.error("Failed to process message %s: %s", message_id, exc)
            failures.append({"itemIdentifier": message_id})

    # Partial batch failure: only failed items go to DLQ
    return {"batchItemFailures": failures}
