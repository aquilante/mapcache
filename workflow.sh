docker compose down
./start_build_env.sh
docker compose build
docker compose up -d
docker compose exec -ti wms bash
