echo "Starting acqusitions in development mode with Docker Compose..."

if [ ! -f .env.development]; then
  echo "Error: .env.development file not found. Please create it based on .env.example."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Error: Docker is not running. Please start Docker and try again."
  exit 1
fi

mkdir -p .neon_local

if ! grep -q ".neon_local/" .gitignore 2>/dev/null; then
    echo ".neon_local/" >> .gitignore
    echo "Added .neon_local/ to .gitignore"
fi

echo "Starting Neon Local and application containers..."

echo "Applying latest schema with Drizzle"
npm run db:migrate

echo "Waiting for database to be ready"
docker compose exec neon-local psql -U neon -d neondb -c 'SELECT 1'

docker compose -f docker-compose.dev.yml up --build

echo "Development environment is up and running!"
echo "Access the application at http://localhost:5173"
echo "Database: postgres://neon:npg@localhost:5432/neondb"

