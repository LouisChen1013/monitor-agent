from collectors import (
    collect_cpu,
    collect_memory,
    collect_zombies,
    check_internal_network,
    check_external_network,
)


def collect_metrics():
    """Collect all metrics."""
    metrics = {
        "cpu": collect_cpu(),
        "memory": collect_memory(),
        "zombies": collect_zombies(),
        "network": {
            "internal": check_internal_network(),
            "external": check_external_network(),
        },
    }

    return metrics
