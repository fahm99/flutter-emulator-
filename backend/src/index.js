// Flutter IDE Mobile - Backend Server
// Cloud Compiler for Flutter Code

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const { WebSocketServer } = require('ws');
const { v4: uuidv4 } = require('uuid');
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');
const shell = require('shelljs');

// Import controllers
const { CompilationController } = require('./controllers/compilationController');
const { SessionController } = require('./controllers/sessionController');
const { DeviceController } = require('./controllers/deviceController');

// Import middleware
const { errorHandler } = require('./middleware/errorHandler');
const { requestLogger } = require('./middleware/requestLogger');
const { validateCompileRequest } = require('./middleware/validation');

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: { error: 'Too many requests, please try again later.' }
});
app.use('/api/', limiter);

// Create HTTP server
const server = app.use(express.static(path.join(__dirname, '../public')));

// WebSocket server for live output
const wss = new WebSocketServer({ server, path: '/ws' });

// Store active sessions
const sessions = new Map();
const wsConnections = new Map();

// Initialize controllers
const compilationController = new CompilationController(sessions, wsConnections);
const sessionController = new SessionController(sessions);
const deviceController = new DeviceController();

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    uptime: process.uptime()
  });
});

// API Status endpoint
app.get('/api/status', (req, res) => {
  res.json({
    status: 'ready',
    sessions: sessions.size,
    devices: deviceController.getDevices()
  });
});

// Compile endpoint
app.post('/api/compile', 
  validateCompileRequest,
  async (req, res, next) => {
    try {
      const { code, mainFile, files, device } = req.body;
      const sessionId = uuidv4();
      
      console.log(`[Compile] Starting compilation for session: ${sessionId}`);
      
      // Create session
      const session = await compilationController.createSession({
        sessionId,
        code,
        mainFile: mainFile || 'main.dart',
        files: files || {},
        device,
        ws: null
      });
      
      sessions.set(sessionId, session);
      
      // Start compilation
      compilationController.compile(sessionId, code, files)
        .then(result => {
          // Broadcast result via WebSocket
          if (session.ws) {
            session.ws.send(JSON.stringify({
              type: 'status',
              payload: { 
                sessionId, 
                status: result.success ? 'success' : 'error',
                output: result.output,
                error: result.error,
                webUrl: result.webUrl
              }
            }));
          }
        })
        .catch(err => {
          console.error(`[Compile] Error: ${err.message}`);
          if (session.ws) {
            session.ws.send(JSON.stringify({
              type: 'error',
              payload: { sessionId, error: err.message }
            }));
          }
        });
      
      res.json({
        success: true,
        sessionId,
        status: 'compiling'
      });
    } catch (error) {
      next(error);
    }
  }
);

// Get compilation status
app.get('/api/status/:sessionId', (req, res) => {
  const { sessionId } = req.params;
  const session = sessions.get(sessionId);
  
  if (!session) {
    return res.status(404).json({ 
      error: 'Session not found',
      sessionId 
    });
  }
  
  res.json({
    sessionId,
    status: session.status,
    progress: session.progress,
    output: session.output,
    error: session.error,
    webUrl: session.webUrl
  });
});

// Cancel compilation
app.delete('/api/compile/:sessionId', (req, res) => {
  const { sessionId } = req.params;
  const session = sessions.get(sessionId);
  
  if (!session) {
    return res.status(404).json({ error: 'Session not found' });
  }
  
  // Kill the process
  if (session.process) {
    session.process.kill();
  }
  
  session.status = 'cancelled';
  res.json({ success: true, sessionId, status: 'cancelled' });
});

// Run compiled app
app.post('/api/run', (req, res) => {
  const { sessionId, deviceId } = req.body;
  const session = sessions.get(sessionId);
  
  if (!session) {
    return res.status(404).json({ error: 'Session not found' });
  }
  
  if (session.status !== 'success') {
    return res.status(400).json({ error: 'App not compiled yet' });
  }
  
  const device = deviceId || deviceController.getDefaultDevice();
  const url = session.webUrl || `http://localhost:3001`;
  
  res.json({
    success: true,
    sessionId,
    url,
    device
  });
});

// Get available devices
app.get('/api/devices', (req, res) => {
  res.json({
    devices: deviceController.getDevices()
  });
});

// WebSocket connection handling
wss.on('connection', (ws, req) => {
  console.log('[WebSocket] Client connected');
  
  ws.isAlive = true;
  
  ws.on('pong', () => {
    ws.isAlive = true;
  });
  
  ws.on('message', async (message) => {
    try {
      const data = JSON.parse(message);
      console.log('[WebSocket] Received:', data.type);
      
      switch (data.type) {
        case 'connection':
          if (data.payload?.action === 'ping') {
            ws.send(JSON.stringify({ 
              type: 'connection', 
              payload: { action: 'pong' } 
            }));
          }
          break;
          
        case 'status':
          const { action, sessionId, code, files } = data.payload || {};
          
          if (action === 'compile' && sessionId) {
            const session = sessions.get(sessionId);
            if (session) {
              session.ws = ws;
            }
            
            // Start compilation
            const result = await compilationController.compile(sessionId, code, files);
            
            ws.send(JSON.stringify({
              type: 'status',
              payload: {
                sessionId,
                status: result.success ? 'success' : 'error',
                output: result.output,
                error: result.error,
                webUrl: result.webUrl,
                errors: result.errors,
                warnings: result.warnings
              }
            }));
          }
          break;
          
        case 'hotReload':
          // Trigger hot reload
          ws.send(JSON.stringify({
            type: 'hotReload',
            payload: { status: 'triggered' }
          }));
          break;
          
        case 'deviceInfo':
          ws.send(JSON.stringify({
            type: 'deviceInfo',
            payload: { devices: deviceController.getDevices() }
          }));
          break;
      }
    } catch (error) {
      console.error('[WebSocket] Error:', error.message);
      ws.send(JSON.stringify({
        type: 'error',
        payload: { error: error.message }
      }));
    }
  });
  
  ws.on('close', () => {
    console.log('[WebSocket] Client disconnected');
    // Clean up session references
    for (const [id, session] of sessions) {
      if (session.ws === ws) {
        session.ws = null;
      }
    }
  });
  
  ws.on('error', (error) => {
    console.error('[WebSocket] Error:', error.message);
  });
});

// Heartbeat for WebSocket connections
const heartbeatInterval = setInterval(() => {
  wss.clients.forEach((ws) => {
    if (ws.isAlive === false) {
      return ws.terminate();
    }
    ws.isAlive = false;
    ws.ping();
  });
}, 30000);

wss.on('close', () => {
  clearInterval(heartbeatInterval);
});

// Error handling middleware
app.use(errorHandler);
app.use(requestLogger);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Start server
server.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   Flutter IDE Mobile - Cloud Compiler Server                  ║
║                                                               ║
║   Server running on: http://localhost:${PORT}                    ║
║   WebSocket running on: ws://localhost:${PORT}/ws                ║
║                                                               ║
║   Available endpoints:                                        ║
║   - POST /api/compile     - Compile Flutter code              ║
║   - GET  /api/status/:id  - Get compilation status            ║
║   - DELETE /api/compile/:id - Cancel compilation              ║
║   - POST /api/run         - Run compiled app                  ║
║   - GET  /api/devices     - Get available devices             ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('[Server] Shutting down...');
  
  // Kill all running processes
  for (const [, session] of sessions) {
    if (session.process) {
      session.process.kill();
    }
  }
  
  server.close(() => {
    console.log('[Server] Closed');
    process.exit(0);
  });
});

module.exports = { app, server };