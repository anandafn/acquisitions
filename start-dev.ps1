# Acquisitions API - Quick Start Script for Development (PowerShell)
# This script helps developers quickly start the development environment on Windows

Write-Host "🚀 Acquisitions API - Development Environment Setup" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is installed
try {
    docker --version | Out-Null
    Write-Host "✅ Docker is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed. Please install Docker Desktop first." -ForegroundColor Red
    Write-Host "   Visit: https://docs.docker.com/desktop/windows/install/" -ForegroundColor Yellow
    exit 1
}

# Check if Docker Compose is installed
try {
    docker-compose --version | Out-Null
    Write-Host "✅ Docker Compose is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose is not installed. Please install Docker Compose first." -ForegroundColor Red
    Write-Host "   Visit: https://docs.docker.com/compose/install/" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Check if .env file exists
if (-Not (Test-Path .env)) {
    Write-Host "📝 Creating .env file from .env.development..." -ForegroundColor Yellow
    Copy-Item .env.development .env
    Write-Host "✅ .env file created" -ForegroundColor Green
} else {
    Write-Host "ℹ️  .env file already exists" -ForegroundColor Blue
}

Write-Host ""

# Stop any running containers
Write-Host "🛑 Stopping any running containers..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml down 2>$null
Write-Host ""

# Build and start services
Write-Host "🏗️  Building and starting services..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml up -d --build

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "⏳ Waiting for services to be healthy..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    Write-Host ""
    Write-Host "✅ Services are running!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Service Status:" -ForegroundColor Cyan
    docker-compose -f docker-compose.dev.yml ps
    Write-Host ""
    Write-Host "🎉 Development environment is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔗 Access your application:" -ForegroundColor Cyan
    Write-Host "   - API: http://localhost:3000" -ForegroundColor White
    Write-Host "   - Database: postgres://postgres:postgres@localhost:5432/acquisitions" -ForegroundColor White
    Write-Host ""
    Write-Host "📝 Useful commands:" -ForegroundColor Cyan
    Write-Host "   - View logs: docker-compose -f docker-compose.dev.yml logs -f" -ForegroundColor White
    Write-Host "   - Stop services: docker-compose -f docker-compose.dev.yml down" -ForegroundColor White
    Write-Host "   - Run migrations: docker-compose -f docker-compose.dev.yml exec app npm run db:migrate" -ForegroundColor White
    Write-Host "   - Open Drizzle Studio: docker-compose -f docker-compose.dev.yml exec app npm run db:studio" -ForegroundColor White
    Write-Host ""
    Write-Host "📚 For more information, see DOCKER_SETUP.md" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "❌ Failed to start services. Check logs with:" -ForegroundColor Red
    Write-Host "   docker-compose -f docker-compose.dev.yml logs" -ForegroundColor Yellow
    exit 1
}
