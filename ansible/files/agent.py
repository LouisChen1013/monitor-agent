import time
import psutil
import logging
from logging.handlers import RotatingFileHandler
from aggregator import collect_metrics
from logger import write_log

INTERVAL = 10
LOG_PATH = "/opt/monitor/agent.log"
LOG_MAX_BYTES = 5000000
LOG_BACKUP_COUNT = 10


def configure_logging():
    """Configure agent logging."""
    handler = RotatingFileHandler(
        LOG_PATH, maxBytes=LOG_MAX_BYTES, backupCount=LOG_BACKUP_COUNT
    )

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S",
        handlers=[handler],
    )


def main():
    """Run the monitoring agent."""
    configure_logging()
    psutil.cpu_percent(interval=None)  # warm-up

    print("start agent")
    while True:
        start = time.time()

        write_log(collect_metrics())

        elapsed = time.time() - start
        sleep_time = max(0, INTERVAL - elapsed)
        time.sleep(sleep_time)


if __name__ == "__main__":
    main()
