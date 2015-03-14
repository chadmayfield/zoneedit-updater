== Crap TODO ==


Check if script is already running (see example below)
Get downloaded file (page from lwp) size stat()
Create additional debug statements
Create logfile function (check size, rotate, gzip old)
Add user defined log file size in log file function
Beautify HTTP Reponse codes, right now they are ambigious
Check for new Return codes periodically
Improve IP validation regexp... just in case


# INFO: http://zoneedit.com/doc/dynamic.html?
# INFO: http://zoneedit.com/doc/dynamic/
# http://www.zoneedit.com/doc/dynamic/ReturnCodes.txt



```
use Fcntl qw(:flock);
print "start of program\n";
unless (flock(DATA, LOCK_EX|LOCK_NB)) {
    print "$0 is already running. Exiting.\n";
    exit(1);
}
print "sleeping 15...\n";
sleep(15);
print "end of program\n";
```





Rough numbers;

Request Size from checkip.dyndns.com: 103 bytes
Every 2 minutes:
> 2 / 60: 30
> 30 x 24 hr: 720 requests a day
> 720 req x 103 bytes = 74160 bytes
> 74160 bytes / 1024 = 72.421875 Kiobytes/Bandwidth per day

Size of log message when no update necessary: 243 bytes
> 720 x 243 = 174960 bytes
  1. 4960 bytes / 1024 = 170.859375KB
  1. 0.859375 KB x 30 days = 5125.78125 / 1024 = 5.005645752 MB/month
