#!/bin/bash
docker compose -f docker-compose.dev.yaml --env-file .env.local up --build -d