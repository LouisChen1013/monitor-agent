import json
import logging


def write_log(metrics):
    """Write metrics to the log."""
    logging.info(json.dumps(metrics))
