const newrelic = require('newrelic');
require('@newrelic/koa');
const Koa = require('koa');
const Router = require('@koa/router');
const pino = require('pino');
const logger = require('koa-pino-logger')({
  logger: pino(),
  serializers: {
    req: (req) => {
      const { headers, ...rest } = req;
      return rest;
    },
    res: (res) => {
      const { headers, ...rest } = res;
      return rest;
    },
  }
});

const proxy = require('./middleware/proxy');
const apiversion = require('./middleware/apiversion');
const auth = require('./middleware/auth');

const superheroes_protocol = process.env.SUPERHEROES_SERVICE_PROTOCOL || "http"
const superheroes_host = process.env.SUPERHEROES_SERVICE_HOST || "superheroes"
const superheroes_port = process.env.SUPERHEROES_SERVICE_PORT || "5000"

const customers_protocol = process.env.CUSTOMERS_SERVICE_PROTOCOL || "http"
const customers_host = process.env.CUSTOMERS_SERVICE_HOST || "customers"
const customers_port = process.env.CUSTOMERS_SERVICE_PORT || "5010"

const authEnabled = (process.env.AUTH_ENABLED === "true") || false

const app = new Koa();
const router = new Router();

router.get('/ping', (ctx, next) => {
  ctx.body = {
    message: "healthy"
  }
});

const authUrl = `${customers_protocol}://${customers_host}:${customers_port}/v2/customers/authorize`
router.all('/api/(.*)', auth(authEnabled, authUrl), proxy({
  '/api/(.*)/superheroes(.*)': `${superheroes_protocol}://${superheroes_host}:${superheroes_port}/$1/superheroes$2`,
  '/api/(.*)/customers(.*)': `${customers_protocol}://${customers_host}:${customers_port}/$1/customers$2`
}));

app
  .use(logger)
  .use(router.routes())
  .use(router.allowedMethods());

const port = process.env.HTTP_PORT || 3000

app.listen(port, () => {
  logger.logger.info(`app listening on port ${port}`);
})
