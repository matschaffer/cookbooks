#! /usr/bin/python

from optparse import OptionParser
import time
import socket
NAGIOS_FAIL = 2
NAGIOS_WARN = 1
NAGIOS_UNKNOWN = 3
NAGIOS_OK = 0

def parse_options():
    required_options = ('host', 'critical', 'warning')
    parser = OptionParser(usage="usage: %prog -H host -c crit -w warn [other options]")
    parser.add_option("-H", "--host", help="The HOST to check",
            metavar="HOST", dest="host")
    parser.add_option("-w", "--warning", help="The WARNING response time threshold",
            metavar="WARNING", dest="warning", type=float)
    parser.add_option("-c", "--critical", help="The CRITICAL response time threshold",
            metavar="CRITICAL", dest="critical", type=float)
    parser.add_option("-p", "--port", help="Redis PORT on the host",
            metavar="PORT", dest="port", default=6379, type=int)
    parser.add_option("-C", "--critical-concurrent", help="The CRITICAL value of concurrent clients",
            metavar="CRITICAL", dest="crit_concurrent", type=int)
    parser.add_option("-W", "--warning-concurrent", help="The WARNING value of concurrent clients",
            metavar="WARNING", dest="warn_concurrent", type=int)
    (options, args) = parser.parse_args()
    for opt in required_options:
        if not getattr(options, opt):
            parser.error('Required argument %s missing' % opt)
    return options

def check_redis(options):
    timestamp = time.time()
    rd = redis(host=options.host, port=options.port, timeout=options.critical)
    stats = rd.stats()
    conn_time = time.time() - timestamp
    if conn_time > options.critical:
        die(NAGIOS_FAIL, "FAIL: Connection time was %f" % conn_time)
    if conn_time > options.warning:
        die(NAGIOS_WARN, "WARN: Connection time was %f" % conn_time)
    if options.crit_concurrent and int(stats["connected_clients"]) > options.crit_concurrent:
        die(NAGIOS_FAIL, "FAIL: Concurrent client connections: %s" % stats["connected_clients"])
    if options.warn_concurrent and int(stats["connected_clients"]) > options.warn_concurrent:
        die(NAGIOS_WARN, "WARN Concurrent client connections: %s" % stats["connected_clients"])

    status = "OK | connection_time:%f\n" % conn_time
    status += ("|" + "\n".join(map(lambda tup: "=".join(tup), stats.items() )))
    die(NAGIOS_OK, status)

def die(err_code, msg):
    print msg + "\n"
    exit(err_code)

def try_or_die(func):
    "A decorator function that will try the function and die on failure"
    def try_func(self, *arg):
        try:
            resp = func(self, *arg)
        except socket.timeout as timeout_err:
            die(NAGIOS_FAIL, "Timeout while trying to connect to %s at port %d" % (self.host, self.port))
        except (socket.herror, socket.gaierror) as host_error:
            die(NAGIOS_UNKNOWN, "Hostname error? %s" % host_error)
        except Exception as e:
            die(NAGIOS_UNKNOWN, "Unknown error occurred in %s: %s" % (func.__name__, e))
        return resp
    return try_func


class redis(object):
    def __init__(self, host, port, timeout=30):
        self.port = port
        self.host = host
        self.timeout = timeout
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.settimeout(timeout)
        self.connect_socket(host, port)
        if type(self.sock) == type(None):
            die(NAGIOS_FAIL, "Failed to connect")

    @try_or_die
    def connect_socket(self, host, port):
        self.sock.connect((host, port))

    @try_or_die
    def stats(self):
        self.sock.sendall("INFO\r\n")
        resp = self.sock.recv(4096)
        resp = resp.splitlines()
        del(resp[0])
        response = dict([line.split(':', 1) for line in resp if line.find(':') >= 0])
        return response

if __name__ == "__main__":
    options = parse_options()
    check_redis(options)
