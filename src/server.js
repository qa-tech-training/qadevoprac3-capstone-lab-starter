const express = require('express');
const client = require('prom-client');

const app = express();
const port = 3000;

const register = new client.Registry();

const requestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status'],
});

const responseTimeHistogram = new client.Histogram({
  name: 'http_response_time_seconds',
  help: 'Histogram of response times in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.1, 0.5, 1, 2, 5], // Define bucket ranges
});

register.registerMetric(requestCounter);
register.registerMetric(responseTimeHistogram);

client.collectDefaultMetrics({ register });

app.use((req, res, next) => {
  const end = responseTimeHistogram.startTimer();
  res.on('finish', () => {
    requestCounter.labels(req.method, req.path, res.statusCode).inc();
    end({ method: req.method, route: req.path, status: res.statusCode });
  });
  next();
});

app.get('/', (req, res) => {
  res.send('Hello from the server');
});

// Expose metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Start the server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});

