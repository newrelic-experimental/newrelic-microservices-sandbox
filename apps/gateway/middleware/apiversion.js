const newrelic = require('newrelic');
module.exports = function apiVersion(ctx, next) {
  
  ctx.log.info("using version", ctx.params.version);
  newrelic.addCustomAttribute("apiVersion", ctx.params.version);
  
  return next();

}