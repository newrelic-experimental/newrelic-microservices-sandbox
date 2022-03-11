const Koa = require('koa');
const Router = require('@koa/router');
const proxy = require('koa-proxies')
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
const constructURL = require("construct-url");

const superheroes_protocol = process.env.SUPERHEROES_PROTOCOL || "http"
const superheroes_host = process.env.SUPERHEROES_HOST || "superheroes"

const app = new Koa();
const router = new Router();
const api = new Router();

api.get(
  '/superheroes(.*)',
  proxy("/", {
    target: `${superheroes_protocol}://${superheroes_host}/`,    
    rewrite: (path, ctx) => `${ctx.params[0] || ""}?${ctx.querystring}`,
    logs: (ctx, target) => {
      ctx.log.info('%s %s proxy to -> %s', ctx.req.method, ctx.req.oldPath, new URL(ctx.req.url, target))
    },
    events: {
      error (err, req, res) { console.log("yp") }
    }
  })
);

router.use('/api', api.routes());

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
