// Flutter IDE Mobile - Session Controller
// Handles session management

class SessionController {
  constructor(sessions) {
    this.sessions = sessions;
  }

  /**
   * Get session by ID
   */
  get(sessionId) {
    return this.sessions.get(sessionId);
  }

  /**
   * Get all sessions
   */
  getAll() {
    return Array.from(this.sessions.values());
  }

  /**
   * Delete session
   */
  delete(sessionId) {
    const session = this.sessions.get(sessionId);
    if (session) {
      // Kill process if running
      if (session.process) {
        session.process.kill();
      }
      this.sessions.delete(sessionId);
      return true;
    }
    return false;
  }

  /**
   * Get sessions by status
   */
  getByStatus(status) {
    return this.getAll().filter(s => s.status === status);
  }

  /**
   * Clean up old sessions
   */
  cleanupOldSessions(maxAge = 3600000) { // 1 hour
    const now = Date.now();
    const toDelete = [];
    
    for (const [id, session] of this.sessions) {
      const age = now - new Date(session.createdAt).getTime();
      if (age > maxAge) {
        toDelete.push(id);
      }
    }
    
    for (const id of toDelete) {
      this.delete(id);
    }
    
    return toDelete.length;
  }

  /**
   * Get session stats
   */
  getStats() {
    const sessions = this.getAll();
    return {
      total: sessions.length,
      pending: sessions.filter(s => s.status === 'pending').length,
      compiling: sessions.filter(s => s.status === 'compiling').length,
      success: sessions.filter(s => s.status === 'success').length,
      error: sessions.filter(s => s.status === 'error').length
    };
  }
}

module.exports = { SessionController };