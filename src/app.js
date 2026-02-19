import express from 'express';
import logger from '#config/logger.js';
import helmet from 'helmet';
import morgan from 'morgan';

const app = express();

app.use(helmet());

app.get('/', (req, res) => {
  logger.info('Hello, from acquisitions');
  res.status(200).send('Hello, from acquisitions');
});

export default app;
