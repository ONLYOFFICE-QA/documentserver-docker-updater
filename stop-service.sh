#!/usr/bin/env bash

docker exec -it DocumentServer bash -c "documentserver-prepare4shutdown.sh"
docker stop DocumentServer
docker system prune -af
docker volume prune -f
