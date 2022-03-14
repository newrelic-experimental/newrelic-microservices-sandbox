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

const superheroes_protocol = process.env.SUPERHEROES_SERVICE_PROTOCOL || "http"
const superheroes_host = process.env.SUPERHEROES_SERVICE_HOST || "superheroes"
const superheroes_port = process.env.SUPERHEROES_SERVICE_PORT || "5000"

const app = new Koa();
const router = new Router();

router.get('/ping', (ctx, next) => {
  ctx.body = {
    message: "healthy"
  }
});


router.all('/api/(.*)', proxy({
  '/api/superheroes(.*)': `${superheroes_protocol}://${superheroes_host}:${superheroes_port}/v1/superheroes$1`
}));

app
  .use(logger)
  .use(router.routes())
  .use(router.allowedMethods());

const port = process.env.HTTP_PORT || 3000

app.listen(port, () => {
  logger.logger.info(`app listening on port ${port}`);
})
