#!/bin/bash
celery -A plasticome.config.celery worker -l info --pool=processes --autoscale=10,3 --concurrency=2 &
dockerd --tls=false --host=tcp://0.0.0.0:2375 --host=unix:///var/run/docker.sock &
cd /app && flask run -h backend
# celery -A plasticome.config.celery worker -l info
