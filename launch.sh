#!/bin/bash

docker compose down
docker system prune
docker compose --profile ollama up --build
