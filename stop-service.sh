docker exec -it doc-linux bash -c "documentserver-prepare4shutdown.sh"
docker stop doc-linux
docker system prune -af
docker volume prune -f
