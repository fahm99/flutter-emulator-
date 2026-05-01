// Flutter IDE Mobile - Request Logger Middleware

/**
 * Request logger middleware
 */
function requestLogger(req, res, next) {
  const start = Date.now();

  // Log request
  console.log(`[Request] ${req.method} ${req.path}`);

  // Log response when finished
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[Response] ${req.method} ${req.path} - ${res.statusCode} (${duration}ms)`);
  });

  next();
}

module.exports = { requestLogger };