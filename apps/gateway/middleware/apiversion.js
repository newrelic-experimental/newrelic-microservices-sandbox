module.exports = function createApiVersionMiddleware(headerName) {
  
  const HEADERNAME = (headerName || 'X-Api-Version').toLowerCase();
  
  return (ctx, next) => {
    
    let version = undefined;
    if (ctx.request.headers.hasOwnProperty(HEADERNAME)) {
      version = ctx.request.headers[HEADERNAME];
      ctx.log.info(`using version ${version}`);
    } else {
      ctx.log.info(`No header named ${HEADERNAME} found.  Defaulting to v1`);
      version = "v1";
    }
    ctx.state.apiVersion = version;
    
    return next();
  }
}