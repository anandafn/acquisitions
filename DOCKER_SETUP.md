# Acquisitions API - Docker Setup

A Node.js/Express API with Drizzle ORM and Neon Database, fully containerized with Docker for both development and production environments.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Architecture Overview](#architecture-overview)
- [Development Setup (Neon Local)](#development-setup-neon-local)
- [Production Deployment (Neon Cloud)](#production-deployment-neon-cloud)
- [Environment Variables](#environment-variables)
- [Database Migrations](#database-migrations)
- [Troubleshooting](#troubleshooting)

## 🔧 Prerequisites

- **Docker** (v20.10+) and **Docker Compose** (v2.0+)
- **Node.js** (v20+) - only if running locally without Docker
- **Neon Cloud Account** - for production database ([Sign up here](https://console.neon.tech))

## 🏗️ Architecture Overview

### Development Environment

```
┌─────────────────┐      ┌──────────────────┐
│   Your App      │─────→│   Neon Local     │
│  (Port 3000)    │      │   PostgreSQL     │
│                 │      │   Proxy          │
└─────────────────┘      └──────────────────┘
        ↓
  Hot Reload Enabled
  Source Mounted
```

### Production Environment

```
┌─────────────────┐      ┌──────────────────┐
│   Your App      │─────→│   Neon Cloud     │
│  (Port 3000)    │      │   Serverless DB  │
│   Container     │      │   (neon.tech)    │
└─────────────────┘      └──────────────────┘
        ↓
  Optimized Image
  Non-root User
  Health Checks
```

## 🚀 Development Setup (Neon Local)

### Prerequisites for Development

1. **Neon Account**: Sign up at [console.neon.tech](https://console.neon.tech)
2. **Get Credentials**:
   - API Key: Settings → API Keys → Create new key
   - Project ID: Your project → Settings → General
   - Branch ID: Your project → Branches (optional)

### 1. Configure Neon Local

Edit `.env.development` and add your Neon credentials:

```bash
# Required: Neon API credentials
NEON_API_KEY=napi_xxxxxxxxxxxxxxxxxxxxx
NEON_PROJECT_ID=your-project-id
PARENT_BRANCH_ID=br-xxxxxxxxxx  # Optional: for ephemeral branches
DELETE_BRANCH=true               # Auto-delete branch on stop

# Database connection (auto-configured)
DATABASE_URL=postgres://neon:npg@localhost:5432/neondb
```

### 2. Start Development Environment

```powershell
# Build and start both Neon Local and the application
docker-compose -f docker-compose.dev.yml up --build

# Or run in detached mode
docker-compose -f docker-compose.dev.yml up -d

# Or use the convenience script
.\start-dev.ps1
```

This will:

- ✅ Start **Neon Local** proxy connecting to your Neon Cloud database
- ✅ Start your **application** with hot reload on port `3000`
- ✅ Create ephemeral database branch (if PARENT_BRANCH_ID set)
- ✅ Mount source code for instant updates

### 3. Run Database Migrations

```powershell
# Run migrations inside the container
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Or generate new migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:generate
```

### 4. Access the Application

- **API**: http://localhost:3000
- **Health Check**: http://localhost:3000/health
- **Database**: `postgres://neon:npg@localhost:5432/neondb`

### 5. View Logs

```bash
# Follow all logs
docker-compose -f docker-compose.dev.yml logs -f

# View only app logs
docker-compose -f docker-compose.dev.yml logs -f app

# View only Neon Local logs
docker-compose -f docker-compose.dev.yml logs -f neon-local
```

### 6. Stop Development Environment

```bash
# Stop and remove containers
docker-compose -f docker-compose.dev.yml down

# Stop and remove containers + volumes (clears database)
docker-compose -f docker-compose.dev.yml down -v
```

## 🌐 Production Deployment (Neon Cloud)

### 1. Create Neon Cloud Database

1. Go to [Neon Console](https://console.neon.tech)
2. Create a new project
3. Copy the connection string (looks like: `postgres://user:password@ep-xyz.neon.tech/dbname?sslmode=require`)

### 2. Configure Production Environment

```bash
# Create production environment file
cp .env.production .env.prod

# Edit .env.prod and add your Neon Cloud DATABASE_URL
nano .env.prod
```

**Required variables in `.env.prod`:**

```env
NODE_ENV=production
DATABASE_URL=postgres://user:password@ep-xyz.neon.tech/dbname?sslmode=require
JWT_SECRET=<generate-with-openssl-rand-base64-32>
JWT_EXPIRES_IN=7d
PORT=3000
```

### 3. Build Production Image

```bash
# Build the production image
docker build -t acquisitions-api:latest --target production .

# Or use docker-compose
docker-compose -f docker-compose.prod.yml build
```

### 4. Run Production Container

```bash
# Using docker-compose (recommended)
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d

# Or using docker run
docker run -d \
  --name acquisitions-api \
  --env-file .env.prod \
  -p 3000:3000 \
  acquisitions-api:latest
```

### 5. Run Production Migrations

```bash
# Run migrations against Neon Cloud
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
```

### 6. Health Check

```bash
# Check if the application is healthy
curl http://localhost:3000/health

# View container logs
docker-compose -f docker-compose.prod.yml logs -f app
```

## 🔐 Environment Variables

### Development (`.env.development`)

| Variable         | Default                                                    | Description                     |
| ---------------- | ---------------------------------------------------------- | ------------------------------- |
| `NODE_ENV`       | `development`                                              | Environment mode                |
| `PORT`           | `3000`                                                     | Application port                |
| `DATABASE_URL`   | `postgres://postgres:postgres@localhost:5432/acquisitions` | Neon Local connection           |
| `JWT_SECRET`     | `dev-secret-*`                                             | JWT signing secret (not secure) |
| `JWT_EXPIRES_IN` | `7d`                                                       | Token expiration                |
| `LOG_LEVEL`      | `debug`                                                    | Logging verbosity               |

### Production (`.env.production`)

| Variable         | Required | Description                                          |
| ---------------- | -------- | ---------------------------------------------------- |
| `NODE_ENV`       | ✅       | Must be `production`                                 |
| `PORT`           | ❌       | Application port (default: 3000)                     |
| `DATABASE_URL`   | ✅       | Neon Cloud connection string                         |
| `JWT_SECRET`     | ✅       | Strong random secret (use `openssl rand -base64 32`) |
| `JWT_EXPIRES_IN` | ❌       | Token expiration (default: 7d)                       |
| `LOG_LEVEL`      | ❌       | Logging level (default: info)                        |
| `CORS_ORIGIN`    | ❌       | Allowed CORS origins                                 |

## 🗄️ Database Migrations

### Development

```bash
# Generate migration from schema changes
docker-compose -f docker-compose.dev.yml exec app npm run db:generate

# Apply migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Open Drizzle Studio
docker-compose -f docker-compose.dev.yml exec app npm run db:studio
```

### Production

```bash
# Apply migrations to Neon Cloud
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
```

## 🐛 Troubleshooting

### Issue: Neon Local won't start

**Solution:**

```bash
# Check if port 5432 is already in use
netstat -tuln | grep 5432

# Kill process using port 5432
# On Windows:
netsh interface portproxy reset
# On Linux/Mac:
lsof -ti:5432 | xargs kill -9

# Restart services
docker-compose -f docker-compose.dev.yml restart
```

### Issue: Database connection refused

**Solution:**

```bash
# Check Neon Local health
docker-compose -f docker-compose.dev.yml ps
docker-compose -f docker-compose.dev.yml logs neon-local

# Wait for Neon Local to be healthy
docker-compose -f docker-compose.dev.yml up -d neon-local
# Wait 10-15 seconds
docker-compose -f docker-compose.dev.yml up app
```

### Issue: Hot reload not working

**Solution:**

```bash
# Ensure source is mounted correctly
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.dev.yml up --build

# Check volume mounts
docker inspect acquisitions-app-dev | grep -A 10 Mounts
```

### Issue: Production container crashes

**Solution:**

```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs app

# Verify environment variables
docker-compose -f docker-compose.prod.yml exec app env | grep DATABASE_URL

# Test database connection
docker-compose -f docker-compose.prod.yml exec app node -e "
  require('dotenv').config();
  console.log('DATABASE_URL:', process.env.DATABASE_URL ? '✓ Set' : '✗ Missing');
"
```

### Issue: Migrations fail

**Solution:**

```bash
# Check database connectivity
docker-compose -f docker-compose.dev.yml exec app npm run db:studio

# Reset database (development only!)
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.dev.yml up -d

# Re-run migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate
```

## 📚 Useful Commands

```bash
# Development
docker-compose -f docker-compose.dev.yml up -d      # Start services
docker-compose -f docker-compose.dev.yml down       # Stop services
docker-compose -f docker-compose.dev.yml logs -f    # View logs
docker-compose -f docker-compose.dev.yml ps         # List containers
docker-compose -f docker-compose.dev.yml restart    # Restart services

# Production
docker-compose -f docker-compose.prod.yml up -d     # Start services
docker-compose -f docker-compose.prod.yml down      # Stop services
docker-compose -f docker-compose.prod.yml logs -f   # View logs
docker-compose -f docker-compose.prod.yml ps        # List containers

# Clean up
docker system prune -a --volumes                    # Remove all unused Docker data
docker-compose -f docker-compose.dev.yml down -v    # Remove dev volumes
```

## 🔒 Security Best Practices

1. **Never commit `.env.production` with real secrets**
2. **Use strong random JWT secrets**: `openssl rand -base64 32`
3. **Enable SSL for Neon Cloud** (already in connection string)
4. **Use environment-specific secrets managers** (AWS Secrets Manager, HashiCorp Vault)
5. **Run containers as non-root user** (already configured in Dockerfile)
6. **Set resource limits** in production (already in docker-compose.prod.yml)
7. **Enable health checks** (already configured)

## 📖 Additional Resources

- [Neon Documentation](https://neon.tech/docs)
- [Neon Local Guide](https://neon.com/docs/local/neon-local)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Drizzle ORM](https://orm.drizzle.team/)

## 📝 License

[Your License Here]
