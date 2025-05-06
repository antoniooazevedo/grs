# WARNING
If any `database` containers spit out errors along the lines of 
```
Could not setup Async I/O: Resource temporarily unavailable. The required nr_events 1024 exceeds the capacity in /proc/sys/fs/aio-max-nr
```

run this command on the host machine:
```sh
sudo sysctl -w fs.aio-max-nr=1048576
```
