# Quick Start Guide - Neon Local Development

## Prerequisites

1. Docker Desktop installed and running
2. Neon account with API credentials

## Setup Steps

### 1. Get Neon Credentials

Visit [Neon Console](https://console.neon.tech) and get:

- **API Key**: Settings → API Keys → Create new API key
- **Project ID**: Your project → Settings → General
- **Branch ID** (optional): Your project → Branches → Copy branch ID

### 2. Configure Environment

Edit `.env.development` and add your Neon credentials:

```bash
# Neon Local Configuration
NEON_API_KEY=your_api_key_here
NEON_PROJECT_ID=your_project_id_here
PARENT_BRANCH_ID=your_branch_id_here  # Optional: for ephemeral branches
DELETE_BRANCH=true  # Auto-delete branch when container stops
```

### 3. Start Development Environment

**Option A: Using Docker Compose (Recommended)**

```powershell
# Start services
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Stop services
docker-compose -f docker-compose.dev.yml down
```

**Option B: Using PowerShell Script**

```powershell
.\start-dev.ps1
```

### 4. Run Database Migrations

```powershell
# Inside Docker container
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Or locally (if Neon Local is running)
npm run db:migrate
```

### 5. Access Your Application

- **API**: http://localhost:3000
- **Health Check**: http://localhost:3000/health
- **Database**: `postgres://neon:npg@localhost:5432/neondb`

## How It Works

### Neon Local Architecture

```
┌─────────────────────┐
│   Your App          │
│   (localhost:3000)  │
└──────────┬──────────┘
           │
           ↓ (HTTP + SQL)
┌─────────────────────┐
│   Neon Local Proxy  │
│   (localhost:5432)  │
└──────────┬──────────┘
           │
           ↓ (Secure WebSocket)
┌─────────────────────┐
│   Neon Cloud        │
│   (neon.tech)       │
└─────────────────────┘
```

### Key Features

1. **Ephemeral Branches**:
   - Set `PARENT_BRANCH_ID` in `.env.development`
   - New branch created on `docker-compose up`
   - Branch deleted on `docker-compose down`

2. **Persistent Branches**:
   - Set `DELETE_BRANCH=false`
   - Branch persists across container restarts
   - Uses `.neon_local/` for metadata (auto-ignored by git)

3. **Git Integration**:
   - Automatically creates branch per git branch
   - Mount `.git/HEAD` for branch detection

## Troubleshooting

### Issue: "no such image: neondatabase/neon-proxy"

**Solution**: The correct image is `neondatabase/neon_local:latest` (with underscore). This is already configured.

### Issue: Connection refused

**Solution**:

```powershell
# Check if Neon Local is healthy
docker-compose -f docker-compose.dev.yml ps

# Restart Neon Local
docker-compose -f docker-compose.dev.yml restart neon-local

# Check logs
docker-compose -f docker-compose.dev.yml logs neon-local
```

### Issue: "Authentication failed"

**Solution**: Verify your Neon credentials in `.env.development`:

- API key format: `napi_*`
- Project ID format: `project-name-12345678`
- Branch ID format: `br-name-a1b2c3d4`

### Issue: Database connection from app fails

**Solution**:

```powershell
# If running app locally (npm run dev):
DATABASE_URL=postgres://neon:npg@localhost:5432/neondb

# If running app in Docker:
DATABASE_URL=postgres://neon:npg@neon-local:5432/neondb
```

## Development Workflows

### Local Development (Outside Docker)

```powershell
# 1. Start only Neon Local
docker-compose -f docker-compose.dev.yml up neon-local -d

# 2. Run app locally
npm run dev

# 3. Database is at localhost:5432
```

### Full Docker Development

```powershell
# 1. Start both services
docker-compose -f docker-compose.dev.yml up -d

# 2. App runs at localhost:3000
# 3. Hot reload enabled via volume mounts
```

### Running Migrations

```powershell
# Inside container
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Or locally
npm run db:migrate
```

### Accessing Database

```powershell
# Using psql
psql "postgres://neon:npg@localhost:5432/neondb"

# Using Drizzle Studio
docker-compose -f docker-compose.dev.yml exec app npm run db:studio
```

## Environment Variables Reference

| Variable           | Required | Description                                                  |
| ------------------ | -------- | ------------------------------------------------------------ |
| `NEON_API_KEY`     | ✅       | Your Neon API key from console                               |
| `NEON_PROJECT_ID`  | ✅       | Your Neon project ID                                         |
| `PARENT_BRANCH_ID` | ❌       | Parent branch for ephemeral branches                         |
| `BRANCH_ID`        | ❌       | Connect to existing branch (alternative to PARENT_BRANCH_ID) |
| `DELETE_BRANCH`    | ❌       | Auto-delete branch on stop (default: true)                   |
| `DATABASE_URL`     | ✅       | Connection string (auto-configured)                          |

## Next Steps

1. ✅ Configure `.env.development` with your Neon credentials
2. ✅ Start Docker services
3. ✅ Run migrations
4. ✅ Start coding!

For production deployment, see [DOCKER_SETUP.md](./DOCKER_SETUP.md)
