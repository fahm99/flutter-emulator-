// Flutter IDE Mobile - Request Validation Middleware

/**
 * Validate compile request
 */
function validateCompileRequest(req, res, next) {
  const { code } = req.body;

  if (!code) {
    return res.status(400).json({
      error: 'Validation Error',
      message: 'Code is required'
    });
  }

  if (typeof code !== 'string') {
    return res.status(400).json({
      error: 'Validation Error',
      message: 'Code must be a string'
    });
  }

  // Check code size (max 1MB)
  if (code.length > 1000000) {
    return res.status(400).json({
      error: 'Validation Error',
      message: 'Code exceeds maximum size (1MB)'
    });
  }

  // Validate mainFile if provided
  if (req.body.mainFile) {
    const validExtensions = ['.dart', '.yaml', '.json', '.md'];
    const hasValidExtension = validExtensions.some(ext => 
      req.body.mainFile.endsWith(ext)
    );
    
    if (!hasValidExtension) {
      return res.status(400).json({
        error: 'Validation Error',
        message: 'mainFile must have a valid extension (.dart, .yaml, .json, .md)'
      });
    }
  }

  next();
}

/**
 * Validate session ID format
 */
function validateSessionId(req, res, next) {
  const { sessionId } = req.params;

  // UUID v4 format check
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  
  if (!uuidRegex.test(sessionId)) {
    return res.status(400).json({
      error: 'Validation Error',
      message: 'Invalid session ID format'
    });
  }

  next();
}

/**
 * Validate run request
 */
function validateRunRequest(req, res, next) {
  const { sessionId, deviceId } = req.body;

  if (!sessionId) {
    return res.status(400).json({
      error: 'Validation Error',
      message: 'sessionId is required'
    });
  }

  // Device ID is optional but if provided, validate format
  if (deviceId && typeof deviceId !== 'string') {
    return res.status(400).json({
      error: 'Validation Error',
      message: 'deviceId must be a string'
    });
  }

  next();
}

/**
 * Sanitize input to prevent injection attacks
 */
function sanitizeInput(req, res, next) {
  // Recursively sanitize object properties
  function sanitize(obj) {
    if (typeof obj === 'string') {
      return obj
        .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
        .replace(/javascript:/gi, '')
        .replace(/on\w+\s*=/gi, '');
    }
    
    if (Array.isArray(obj)) {
      return obj.map(sanitize);
    }
    
    if (obj && typeof obj === 'object') {
      const sanitized = {};
      for (const key in obj) {
        sanitized[key] = sanitize(obj[key]);
      }
      return sanitized;
    }
    
    return obj;
  }

  req.body = sanitize(req.body);
  next();
}

module.exports = {
  validateCompileRequest,
  validateSessionId,
  validateRunRequest,
  sanitizeInput
};