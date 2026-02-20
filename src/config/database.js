import 'dotenv/config';

import { neon, neonConfig } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';

// Configure Neon for local development
if (process.env.NODE_ENV === 'development') {
  // Determine if running inside Docker or locally
  const isDocker = process.env.DATABASE_URL?.includes('neon-local');
  const host = isDocker ? 'neon-local' : 'localhost';

  // Neon Local configuration for serverless driver
  neonConfig.fetchEndpoint = `http://${host}:5432/sql`;
  neonConfig.useSecureWebSocket = false;
  neonConfig.poolQueryViaFetch = true;
}

const sql = neon(process.env.DATABASE_URL);

const db = drizzle(sql);

export { db, sql };
