# ``image-downloader``

The script in this directory implements the following spec (and a tiny bit more):

> Write a script that takes this plaintext file as an argument and downloads all
> images, storing them on the local hard disk. Approach the problem as you would
> any task in a normal day’s work. Imagine this code will be used in important
> live systems, modified later on by other developers, and so on.
>
> In a deployment scenario this script needs to be deployed to multiple Debian
> machines, scheduled to run every five minutes. The downloaded images should be
> served via http on each server. Provide an example deployment or instructions
> with your solution.

## Manual Usage:

```bash
$ python imageloader/loader.py /path/to/url.list
# Or after running setup.py:
$ python3 -m imageloader /path/to/url.list
$ ls images/by-name
...
# Serve it via HTTP:
$ cd images/by-name && python3 -m http.server --bind 0.0.0.0 8000
```

# Deployment:

The above spec leaves room for interpretation in the following points:

- Number of Debian machines.
- Which init system is used (Jessie already uses systemd, Wheezy only has a preview of it).
- Version of installed Python (above script needs at least Python >= 3.2, which
  works with Debian Jessie and Wheezy)
- Typical size of the images each and total.

To tackle these unknown variables I provided two deployment strategies. In any
case, the script was written to use the standard library only (empty
requirements.txt therefore) in order to avoid dependencies. More "real" world
software should of course use libraries where it makes sense (especially Python
Requests).

If the total size of the images is very large, it might make sense to do the
downloading on one central instance and serve the files to each other server
via tools like sshfs (to avoid storage waste).

## Strategy One: Handwork

For a small number of machines the following bash session should lead to a working setup:

```bash
$ git clone https://github.com/sahib/misc.git && cd misc
$ sudo python3 setup.py install
$ sudo systemctl daemon-reload
# You can view the timer with systemctl list-timers:
$ sudo systemctl start image-loader.timer
# Downloading might take a bit to the nearest 5m interval:
$ mkdir -p /tmp/images/by-name
$ cd /tmp/images/by-name && python3 -m http.server
```

The HTTP server might also be converted into an systemd unit, if desired or
necessary.  This approach assumes that a python version greater than 3.2 and
systemd is installed.  For a larger number of homogeneous (i.e. about the same
software versions) machines, tools like Ansible (\*) provide a way to execute above
script on each machine at once (which is probably desirable).

(\*) I haven't yet experience with Ansible though.

Later, the tool might also be distributed via PyPI rather than using GitHub.
In this case, the first 3 commands above would become:

```bash
sudo pip install simple-image-loader
```

## Strategy Two: Use Docker

This might be a little overkill for a quite small tool, but it should work if
resolving the dependencies turn out to be a problem:

```bash
# Assuming docker is installed and running:
$ git clone git clone github.com/sahib/misc && cd misc
$ docker build . -t sahib:image-loader
# Forward container port 8000 to host port 8000
$ docker run -i -t --net=host sahib:image-loader
```

This assumes that docker is installed on the Debian servers.
