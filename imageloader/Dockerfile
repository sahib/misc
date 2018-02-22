FROM python:3-onbuild
COPY ["imageloader/loader.py", "/usr/src/app/"]
COPY ["misc/example.urls", "/usr/src/app/example.urls"]
COPY ["docker-run.sh", "/usr/src/app/docker-run.sh"]
CMD  ["/bin/sh", "/usr/src/app/docker-run.sh"]
