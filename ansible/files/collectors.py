import psutil
import socket

TOTAL_CPU = psutil.cpu_count()
INTERNAL_HOST = "www.graid.com"
INTERNAL_PORT = 80
EXTERNAL_HOST = "8.8.8.8"
EXTERNAL_PORT = 53
TIMEOUT = 3


def collect_cpu():
    """Collect CPU metrics."""
    total_cpu_usage = psutil.cpu_percent(interval=None, percpu=False)
    per_cpu_usage = psutil.cpu_percent(interval=None, percpu=True)

    return {
        "cpu_total": TOTAL_CPU,
        "total_cpu_usage": total_cpu_usage,
        "cpu_per_core": per_cpu_usage,
    }


def collect_memory():
    """Collect memory metrics."""
    mem_usage = psutil.virtual_memory().percent
    return {"mem_usage": mem_usage}


def collect_zombies():
    """Collect zombie process metrics."""
    zombie_list = []
    for proc in psutil.process_iter(attrs=["pid", "name", "status"]):
        try:
            if proc.status() == psutil.STATUS_ZOMBIE:
                zombie_list.append({"pid": proc.info["pid"], "name": proc.info["name"]})
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue

    return {"zombie_count": len(zombie_list), "zombie_list": zombie_list}


def check_tcp(host, port, timeout=3):
    """Check TCP connectivity."""
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(timeout)
    try:
        s.connect((host, port))
        return {"status": "SUCCESS", "error": None}
    except socket.gaierror:
        # DNS Error
        return {"status": "FAILED", "error": "DNS Resolution error"}

    except socket.timeout:
        # Timeout Error
        return {"status": "FAILED", "error": "TCP Connection timeout"}

    except ConnectionRefusedError:
        # Refused Error
        return {"status": "FAILED", "error": "Connection refused"}

    except OSError as e:
        # OS Error
        return {"status": "FAILED", "error": f"OS Error: {str(e)}"}

    finally:
        s.close()


def check_internal_network(host=INTERNAL_HOST, port=INTERNAL_PORT, timeout=TIMEOUT):
    """Check internal network connectivity."""
    return check_tcp(host, port, timeout)


def check_external_network(host=EXTERNAL_HOST, port=EXTERNAL_PORT, timeout=TIMEOUT):
    """Check external network connectivity."""
    return check_tcp(host, port, timeout)
