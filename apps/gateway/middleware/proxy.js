const HttpProxy = require('http-proxy');
const HttpProxyRules = require('http-proxy-rules');


module.exports = function createProxyMiddleware(proxyRules) {
  
  const rules = new HttpProxyRules({
    rules: proxyRules
  });
  
  var proxy = HttpProxy.createProxyServer({log: true});
  
  return (ctx, next) => {
    return new Promise((resolve, reject) => {
      const originalPath = ctx.path
      let target = rules.match(ctx.req);
      
      if (target) {
        if (ctx.state.apiVersion) {
          target = target.replace(':version', ctx.state.apiVersion);
        }
      
        ctx.log.info(`proxying ${originalPath} to ${target}`);
        
        ctx.res.on('close', () => {
          reject(new Error(`Http response closed while proxying ${originalPath}`));
        })
  
        ctx.res.on('finish', () => {
          resolve();
        })
  
  
        proxy.web(ctx.req, ctx.res, {
          target: target
        }, e => {
          const status = {
            ECONNREFUSED: 503,
            ETIMEOUT: 504
          }[e.code]
          ctx.status = status || 500
          ctx.body = { msg: e.message }
          resolve()
        });
      } else {
        ctx.status = 400;
        ctx.body = { msg: `No proxy rule matches path ${ctx.path}` };
        resolve()
      }
    });
  }
}