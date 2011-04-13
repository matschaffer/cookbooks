#! /usr/bin/python
from optparse import OptionParser
import time
import urllib2
NAGIOS_FAIL = 2
NAGIOS_WARN = 1
NAGIOS_UNKNOWN = 3
NAGIOS_OK = 0
nagios_status_desc = ["OK", "WARNING", "CRITICAL", "UNKNOWN"]

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
            metavar="PORT", dest="port", default=9000, type=int)
    (options, args) = parser.parse_args()
    for opt in required_options:
        if not getattr(options, opt):
            parser.error('Required argument %s missing' % opt)
    return options

def check_core(options):
    timestamp = time.time()
    core_obj = core(host=options.host, port=options.port, timeout=options.critical * 2)
    conn_time = time.time() - timestamp
    status_code = NAGIOS_OK
    if conn_time > options.critical:
        status_code = NAGIOS_FAIL
    elif conn_time > options.warning:
        status_code = NAGIOS_WARN
    status = "%s Connection time: %f" % (nagios_status_desc[status_code], conn_time)
    status += (" | " + core_obj.stats)
    die(status_code, status)

def die(err_code, msg):
    print msg.rstrip() + "\n"
    exit(err_code)

def try_or_die(func):
    "A decorator function that will try the function and die on failure"
    def try_func(self, *arg):
        try:
            resp = func(self, *arg)
        except urllib2.URLError as err:
            die(NAGIOS_FAIL, "Error connecting to server: %s" % err)
        except Exception as e:
            die(NAGIOS_UNKNOWN, "Unknown error occurred in %s: %s" % (func.__name__, e))
        return resp
    return try_func


class core(object):
    def __init__(self, host, port, timeout=30):
        self.port = port
        self.host = host
        self.timeout = timeout
        self.connect_url()

    @try_or_die
    def connect_url(self):
        self.url_obj = urllib2.urlopen('http://%s:%d/' % (self.host, self.port), None, self.timeout)
        self.parse_stats(self.url_obj.read())

    def parse_stats(self, stats_txt):
        self.stats = stats_txt.replace(":", "=")

if __name__ == "__main__":
    options = parse_options()
    check_core(options)
