const newrelic = require('newrelic');
module.exports = function createAuthMiddleware(authEnabled, authorizeUrl) {
  
  return async (ctx, next) => {
    
   if (!authEnabled || ctx.path == '/api/customers/token') {
     return next();
   } else {
     const { default: fetch } = await import('node-fetch');
     const body = {token: ctx.request.headers['x-superheroes-api-key']};
     const response = await fetch(authorizeUrl, {
       method: 'POST', 
       body: JSON.stringify(body), 
       headers: {'Content-Type': 'application/json'}
     });
     if (response.ok) {
       const customer = await response.json();
       newrelic.addCustomAttribute("customerId", customer.customerId);
       return next()
     } else {
       ctx.log.info(`got response: ${ JSON.stringify(await response.json()) }`);
       ctx.status = 403
       ctx.body = { msg: "unauthorized" }
     }
     
   }
  }
}