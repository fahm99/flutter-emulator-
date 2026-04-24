// Enhanced Flutter Multi-Emulator - Authentic Mobile Device Experience with Screenshot Support

// Store device state with enhanced emulator features
let currentState = {
    isPortrait: true,
    currentDevice: null,
    flutterAppUrl: '',
    isDevControlsVisible: false,
    lastUpdateTime: 0,
    touchFeedbackEnabled: true,
    isAllDevicesView: false
};

// Emulator configuration for authentic experience
const EMULATOR_CONFIG = {
    authenticLook: true,
    showPhysicalButtons: true,
    realisticStatusBar: true,
    smoothAnimations: true,
    touchFeedback: true,
    updateThreshold: 16 // 60fps
};

// DOM Elements cache for better performance
let domCache = {};

// Initialize the authentic emulator when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    console.log('Flutter Multi-Emulator initializing...');
    
    // Cache DOM elements for performance
    cacheDOMElements();
    
    // Apply emulator enhancements
    applyEmulatorEnhancements();
    
    console.log('DOM loaded, sending webviewReady');
    vscode.postMessage({ command: 'webviewReady' });

    initializeControls();
    initializePhysicalButtons();
    updateRealisticClock();
    setInterval(updateRealisticClock, 60000);
    
    // Initialize keyboard shortcuts
    initializeKeyboardShortcuts();
    
    // Initialize all devices view
    initializeAllDevicesView();
    
    console.log('Flutter Multi-Emulator initialized successfully');
});

// Cache DOM elements for better performance
function cacheDOMElements() {
    domCache = {
        deviceWrapper: document.querySelector('.device-wrapper'),
        deviceFrame: document.querySelector('.device-frame'),
        deviceScreen: document.querySelector('.device-screen'),
        flutterAppFrame: document.getElementById('flutter-app'),
        statusTime: document.querySelector('.status-time'),
        deviceSelect: document.getElementById('device-select'),
        devControls: document.querySelector('.dev-controls'),
        reloadBtn: document.getElementById('reload-btn'),
        rotateBtn: document.getElementById('rotate-btn'),
        screenshotBtn: document.getElementById('screenshot-btn'),
        allDevicesBtn: document.getElementById('all-devices-btn'),
        powerButton: document.querySelector('.power-button'),
        volumeUp: document.querySelector('.volume-up'),
        volumeDown: document.querySelector('.volume-down'),
        batteryLevel: document.querySelector('.battery-level'),
        signalBars: document.querySelectorAll('.signal-bar'),
        allDevicesView: document.getElementById('all-devices-view'),
        emulatorView: document.getElementById('emulator-view')
    };

    // Verify critical elements
    if (!domCache.flutterAppFrame) {
        console.error('Critical: flutter-app iframe not found');
    }
    if (!domCache.deviceWrapper || !domCache.deviceFrame || !domCache.deviceScreen) {
        console.error('Critical: Required device elements not found');
    }
}

// Apply emulator enhancements for authentic experience
function applyEmulatorEnhancements() {
    if (!EMULATOR_CONFIG.authenticLook) return;
    
    // Enable hardware acceleration for smooth animations
    const acceleratedElements = [
        domCache.deviceWrapper,
        domCache.deviceFrame,
        domCache.deviceScreen,
        domCache.flutterAppFrame
    ];
    
    acceleratedElements.forEach(element => {
        if (element) {
            element.style.willChange = 'transform';
            element.style.transform = 'translateZ(0)';
        }
    });
    
    // Optimize iframe for better performance
    if (domCache.flutterAppFrame) {
        domCache.flutterAppFrame.style.contain = 'layout style paint';
        domCache.flutterAppFrame.style.willChange = 'contents';
    }
    
    // Add realistic device animations
    addDeviceAnimations();
    
    console.log('Emulator enhancements applied');
}

// Add realistic device animations
function addDeviceAnimations() {
    // Subtle breathing animation for power button
    if (domCache.powerButton) {
        domCache.powerButton.style.animation = 'subtle-pulse 4s ease-in-out infinite';
    }
    
    // Dynamic signal strength animation
    if (domCache.signalBars.length > 0) {
        animateSignalStrength();
        setInterval(animateSignalStrength, 3000);
    }
    
    // Battery level updates
    if (domCache.batteryLevel) {
        updateBatteryLevel();
        setInterval(updateBatteryLevel, 30000);
    }
}

// Animate signal strength for realism
function animateSignalStrength() {
    if (!domCache.signalBars.length) return;
    
    const patterns = [
        [true, true, true, true],    // Full signal
        [true, true, true, false],   // Good signal
        [true, true, false, false],  // Medium signal
        [true, false, false, false]  // Weak signal
    ];
    
    const pattern = patterns[Math.floor(Math.random() * patterns.length)];
    
    domCache.signalBars.forEach((bar, index) => {
        if (pattern[index]) {
            bar.classList.add('active');
        } else {
            bar.classList.remove('active');
        }
    });
}

// Update battery level realistically
function updateBatteryLevel() {
    if (!domCache.batteryLevel) return;
    
    // Simulate battery drain over time
    const currentWidth = parseInt(domCache.batteryLevel.style.width) || 100;
    const newWidth = Math.max(20, currentWidth - Math.random() * 2);
    
    domCache.batteryLevel.style.width = `${newWidth}%`;
    
    // Change color based on battery level
    if (newWidth < 20) {
        domCache.batteryLevel.style.background = '#ff3b30';
    } else if (newWidth < 50) {
        domCache.batteryLevel.style.background = '#ff9500';
    } else {
        domCache.batteryLevel.style.background = '#30d158';
    }
}

// Initialize physical device buttons
function initializePhysicalButtons() {
    if (!EMULATOR_CONFIG.showPhysicalButtons) return;
    
    // Power button functionality
    if (domCache.powerButton) {
        domCache.powerButton.addEventListener('click', () => {
            console.log('Power button pressed');
            addTouchFeedback(domCache.powerButton);
            vscode.postMessage({ command: 'powerButton' });
        });
    }
    
    // Volume buttons functionality
    if (domCache.volumeUp) {
        domCache.volumeUp.addEventListener('click', () => {
            console.log('Volume up pressed');
            addTouchFeedback(domCache.volumeUp);
            vscode.postMessage({ command: 'volumeUp' });
        });
    }
    
    if (domCache.volumeDown) {
        domCache.volumeDown.addEventListener('click', () => {
            console.log('Volume down pressed');
            addTouchFeedback(domCache.volumeDown);
            vscode.postMessage({ command: 'volumeDown' });
        });
    }
}

// Add touch feedback to buttons
function addTouchFeedback(element) {
    if (!EMULATOR_CONFIG.touchFeedback || !element) return;
    
    element.style.transform = 'scale(0.95)';
    element.style.transition = 'transform 0.1s ease';
    
    setTimeout(() => {
        element.style.transform = 'scale(1)';
    }, 100);
}

// Initialize all devices view
function initializeAllDevicesView() {
    if (domCache.allDevicesBtn) {
        domCache.allDevicesBtn.addEventListener('click', () => {
            toggleAllDevicesView();
        });
    }
    
    // Add click handlers for device cards
    const deviceCards = document.querySelectorAll('.device-card');
    deviceCards.forEach(card => {
        card.addEventListener('click', () => {
            const deviceName = card.getAttribute('data-device');
            if (deviceName) {
                changeDevice(deviceName);
                toggleAllDevicesView();
            }
        });
    });
}

// Toggle all devices view
function toggleAllDevicesView() {
    currentState.isAllDevicesView = !currentState.isAllDevicesView;
    
    if (domCache.allDevicesView && domCache.emulatorView) {
        if (currentState.isAllDevicesView) {
            domCache.allDevicesView.style.display = 'block';
            domCache.emulatorView.style.display = 'none';
        } else {
            domCache.allDevicesView.style.display = 'none';
            domCache.emulatorView.style.display = 'block';
        }
    }
}

// Initialize control buttons and device selection
function initializeControls() {
    const deviceSelect = domCache.deviceSelect;

    if (deviceSelect) {
        // Device selection
        deviceSelect.addEventListener('change', (event) => {
            const deviceName = event.target.value;
            console.log('Device selected:', deviceName);
            changeDevice(deviceName);
        });

        // Initialize with the currently selected device
        if (deviceSelect.value) {
            changeDevice(deviceSelect.value);
        }
    }
    
    // Rotate button
    if (domCache.rotateBtn) {
        domCache.rotateBtn.addEventListener('click', () => {
            console.log('Rotate button clicked');
            triggerRotate();
        });
    }
    
    // Screenshot button
    if (domCache.screenshotBtn) {
        domCache.screenshotBtn.addEventListener('click', () => {
            console.log('Screenshot button clicked');
            takeScreenshot();
        });
    }
    
    // Reload button
    if (domCache.reloadBtn) {
        domCache.reloadBtn.addEventListener('click', () => {
            console.log('Reload button clicked');
            triggerReload();
        });
    }
}

// Take screenshot of the emulator screen
function takeScreenshot() {
    if (!domCache.flutterAppFrame || !currentState.flutterAppUrl) {
        vscode.postMessage({ command: 'screenshot' });
        return;
    }
    
    try {
        // Use html2canvas approach - capture the screen content
        const iframe = domCache.flutterAppFrame;
        
        // Create a canvas to capture the screen
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');
        
        if (!ctx) {
            vscode.postMessage({ command: 'screenshot' });
            return;
        }
        
        // Get device dimensions
        const width = currentState.currentDevice?.width || 393;
        const height = currentState.currentDevice?.height || 852;
        
        canvas.width = width;
        canvas.height = height;
        
        // For cross-origin iframes, we need a different approach
        // Send message to VS Code to handle screenshot
        vscode.postMessage({ command: 'screenshot' });
        
    } catch (error) {
        console.error('Screenshot error:', error);
        vscode.postMessage({ command: 'screenshot' });
    }
}

// Initialize keyboard shortcuts
function initializeKeyboardShortcuts() {
    document.addEventListener('keydown', (event) => {
        // Ctrl+R or Cmd+R for reload
        if ((event.ctrlKey || event.metaKey) && event.key === 'r' && !event.shiftKey) {
            event.preventDefault();
            console.log('Keyboard shortcut: Reload');
            triggerReload();
        }
        
        // Ctrl+Shift+R or Cmd+Shift+R for rotate
        if ((event.ctrlKey || event.metaKey) && event.key === 'R' && event.shiftKey) {
            event.preventDefault();
            console.log('Keyboard shortcut: Rotate');
            triggerRotate();
        }
        
        // Ctrl+Shift+S or Cmd+Shift+S for screenshot
        if ((event.ctrlKey || event.metaKey) && event.key === 'S' && event.shiftKey) {
            event.preventDefault();
            console.log('Keyboard shortcut: Screenshot');
            takeScreenshot();
        }
    });
    
    console.log('Keyboard shortcuts initialized');
}

// Trigger reload with visual feedback
function triggerReload() {
    vscode.postMessage({ command: 'reload' });
    
    // Add visual feedback
    if (domCache.deviceScreen) {
        domCache.deviceScreen.style.opacity = '0.8';
        setTimeout(() => {
            domCache.deviceScreen.style.opacity = '1';
        }, 200);
    }
}

// Trigger rotate with smooth animation
function triggerRotate() {
    currentState.isPortrait = !currentState.isPortrait;
    updateDeviceOrientation();
    vscode.postMessage({ command: 'rotate', isPortrait: currentState.isPortrait });
}

// Change the current device with smooth transition
function changeDevice(deviceName) {
    if (!devicePresets || !devicePresets[deviceName]) {
        console.error('Device preset not found for', deviceName);
        return;
    }

    currentState.currentDevice = devicePresets[deviceName];
    console.log('Changed device to:', deviceName, currentState.currentDevice);

    // Update dropdown if exists
    if (domCache.deviceSelect) {
        domCache.deviceSelect.value = deviceName;
    }
    
    // Apply device-specific styling
    updateDeviceDimensions();
    
    // Add transition effect
    if (domCache.deviceWrapper) {
        domCache.deviceWrapper.style.transition = 'all 0.6s cubic-bezier(0.4, 0, 0.2, 1)';
    }

    // Notify extension about device change
    vscode.postMessage({ 
        command: 'deviceChanged', 
        device: deviceName,
        dimensions: currentState.currentDevice
    });
}

// Update device dimensions with smooth transitions
function updateDeviceDimensions() {
    if (!currentState.currentDevice || !domCache.deviceWrapper) return;
    
    // Throttle updates for better performance
    const now = performance.now();
    if (EMULATOR_CONFIG.smoothAnimations && 
        now - currentState.lastUpdateTime < EMULATOR_CONFIG.updateThreshold) {
        return;
    }
    currentState.lastUpdateTime = now;

    // Apply authentic device dimensions
    const { width, height } = currentState.currentDevice;
    
    if (currentState.isPortrait) {
        domCache.deviceWrapper.style.width = `${width}px`;
        domCache.deviceWrapper.style.height = `${height}px`;
    } else {
        domCache.deviceWrapper.style.width = `${height}px`;
        domCache.deviceWrapper.style.height = `${width}px`;
    }
}

// Update device orientation with smooth animation
function updateDeviceOrientation() {
    if (!domCache.deviceWrapper) return;

    // Use requestAnimationFrame for smooth transitions
    requestAnimationFrame(() => {
        if (currentState.isPortrait) {
            domCache.deviceWrapper.classList.remove('landscape');
            domCache.deviceWrapper.classList.add('portrait');
        } else {
            domCache.deviceWrapper.classList.remove('portrait');
            domCache.deviceWrapper.classList.add('landscape');
        }
        updateDeviceDimensions();
    });
}

// Update realistic clock in status bar
function updateRealisticClock() {
    if (!domCache.statusTime) return;
    
    const now = new Date();
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    domCache.statusTime.textContent = `${hours}:${minutes}`;
}

// Handle messages from the extension
window.addEventListener('message', event => {
    const message = event.data;
    console.log('Webview received message:', message.command);
    
    switch (message.command) {
        case 'setAppUrl':
            console.log('Setting flutterAppUrl to:', message.url);
            currentState.flutterAppUrl = message.url;
            if (domCache.flutterAppFrame) {
                // Use requestAnimationFrame for smooth loading
                requestAnimationFrame(() => {
                    domCache.flutterAppFrame.src = currentState.flutterAppUrl;
                });
                console.log('Iframe src set to:', message.url);
            }
            break;
            
        case 'reload':
            if (domCache.flutterAppFrame && currentState.flutterAppUrl) {
                // Force reload with cache bypass for development
                const url = new URL(currentState.flutterAppUrl);
                url.searchParams.set('_t', Date.now());
                domCache.flutterAppFrame.src = url.toString();
                console.log('Reloaded iframe with cache bypass');
                
                // Visual feedback
                if (domCache.deviceScreen) {
                    domCache.deviceScreen.style.opacity = '0.9';
                    setTimeout(() => {
                        domCache.deviceScreen.style.opacity = '1';
                    }, 300);
                }
            }
            break;
            
        case 'rotate':
            currentState.isPortrait = message.isPortrait !== undefined ? message.isPortrait : true;
            console.log('Rotate message received, isPortrait:', currentState.isPortrait);
            updateDeviceOrientation();
            break;
            
        case 'requestScreenshot':
            // Capture screenshot and send back to extension
            captureScreenshot();
            break;
            
        case 'showAllDevices':
            currentState.isAllDevicesView = true;
            if (domCache.allDevicesView && domCache.emulatorView) {
                domCache.allDevicesView.style.display = 'block';
                domCache.emulatorView.style.display = 'none';
            }
            break;
            
        case 'fileChanged':
            console.log('File change detected - hot reload triggered');
            // Visual indicator for file changes
            if (domCache.deviceFrame) {
                domCache.deviceFrame.style.boxShadow = 'inset 0 0 0 2px #00ff00';
                setTimeout(() => {
                    domCache.deviceFrame.style.boxShadow = '';
                }, 500);
            }
            break;
            
        default:
            console.log('Unhandled message command:', message.command);
    }
});

// Capture screenshot of the emulator screen
async function captureScreenshot() {
    try {
        const iframe = domCache.flutterAppFrame;
        if (!iframe) {
            vscode.postMessage({ command: 'captureScreenshot', data: null });
            return;
        }
        
        // Try to capture the iframe content
        const iframeDoc = iframe.contentDocument || iframe.contentWindow?.document;
        
        if (iframeDoc) {
            // Create canvas from iframe content
            const canvas = document.createElement('canvas');
            const ctx = canvas.getContext('2d');
            
            if (ctx) {
                const width = currentState.currentDevice?.width || 393;
                const height = currentState.currentDevice?.height || 852;
                
                canvas.width = width;
                canvas.height = height;
                
                // Draw the iframe content
                try {
                    // For same-origin content
                    ctx.drawWindow(iframe.contentWindow, 0, 0, width, height, 'rgb(255,255,255)');
                    const dataUrl = canvas.toDataURL('image/png');
                    vscode.postMessage({ command: 'captureScreenshot', data: dataUrl });
                    return;
                } catch (e) {
                    console.log('Cannot capture cross-origin iframe directly');
                }
            }
        }
        
        // Fallback: notify that screenshot cannot be captured
        vscode.postMessage({ command: 'screenshot' });
        
    } catch (error) {
        console.error('Screenshot capture error:', error);
        vscode.postMessage({ command: 'screenshot' });
    }
}

// Performance monitoring
if (typeof performance !== 'undefined' && performance.mark) {
    performance.mark('flutter-multi-emulator-init-complete');
    console.log('Performance mark set: flutter-multi-emulator-init-complete');
}

// Error handling for iframe loading
if (domCache.flutterAppFrame) {
    domCache.flutterAppFrame.addEventListener('load', () => {
        console.log('Flutter app iframe loaded successfully');
        
        // Remove loading state
        domCache.flutterAppFrame.style.animation = 'none';
    });
    
    domCache.flutterAppFrame.addEventListener('error', (error) => {
        console.error('Flutter app iframe failed to load:', error);
    });
}

// Add CSS animations dynamically
const style = document.createElement('style');
style.textContent = `
    @keyframes subtle-pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.8; }
    }
    
    .signal-bar {
        transition: background-color 0.3s ease;
    }
    
    .battery-level {
        transition: width 0.5s ease, background-color 0.3s ease;
    }
    
    /* All Devices Grid Styles */
    .all-devices-view {
        padding: 20px;
        background: #1e1e1e;
        border-radius: 8px;
        margin: 20px;
    }
    
    .all-devices-view h2 {
        color: #fff;
        margin-bottom: 20px;
        text-align: center;
    }
    
    .devices-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
        gap: 15px;
    }
    
    .device-card {
        background: #2d2d2d;
        border: 2px solid #404040;
        border-radius: 12px;
        padding: 15px;
        cursor: pointer;
        transition: all 0.3s ease;
        text-align: center;
    }
    
    .device-card:hover {
        background: #3d3d3d;
        border-color: #007acc;
        transform: translateY(-2px);
    }
    
    .device-card-name {
        color: #fff;
        font-weight: bold;
        margin-bottom: 5px;
    }
    
    .device-card-size {
        color: #888;
        font-size: 12px;
        margin-bottom: 5px;
    }
    
    .device-card-type {
        color: #007acc;
        font-size: 11px;
        text-transform: uppercase;
    }
`;
document.head.appendChild(style);

// Expose state for debugging
if (typeof window !== 'undefined') {
    window.flutterEmulatorState = currentState;
    window.flutterEmulatorCache = domCache;
    window.flutterEmulatorConfig = EMULATOR_CONFIG;
}