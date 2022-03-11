const Koa = require('koa');
const Router = require('@koa/router');

const app = new Koa();
const router = new Router();
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

router.get('/ping', (ctx, next) => {
  ctx.body = {
    message: "healthy"
  }
});

app
  .use(logger)
  .use(router.routes())
  .use(router.allowedMethods());

const port = process.env.HTTP_PORT || 3000

app.listen(port, () => {
  logger.logger.info(`app listening on port ${port}`);
})
