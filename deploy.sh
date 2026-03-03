#!/bin/bash
cd ~/rac_company_profile

echo "🏗️ Pulling latest changes..."
git pull origin main

echo "📦 Rebuilding containers..."
docker compose up -d --build

echo "🎨 Collecting static files..."
docker compose exec -T web python manage.py collectstatic --noinput

echo "🗄️ Running migrations..."
docker compose exec -T web python manage.py migrate

echo "✅ Site is updated!"
