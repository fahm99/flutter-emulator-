// Flutter IDE Mobile - Device Controller
// Manages available devices for emulation

class DeviceController {
  constructor() {
    this.devices = this._getDefaultDevices();
  }

  /**
   * Get default device list
   */
  _getDefaultDevices() {
    return [
      {
        id: 'iphone_14_pro',
        name: 'iPhone 14 Pro',
        type: 'phone',
        width: 393,
        height: 852,
        pixelRatio: 3,
        platform: 'ios'
      },
      {
        id: 'iphone_14_pro_max',
        name: 'iPhone 14 Pro Max',
        type: 'phone',
        width: 430,
        height: 932,
        pixelRatio: 3,
        platform: 'ios'
      },
      {
        id: 'iphone_se',
        name: 'iPhone SE',
        type: 'phone',
        width: 375,
        height: 667,
        pixelRatio: 2,
        platform: 'ios'
      },
      {
        id: 'ipad_pro_12_9',
        name: 'iPad Pro 12.9"',
        type: 'tablet',
        width: 1024,
        height: 1366,
        pixelRatio: 2,
        platform: 'ios'
      },
      {
        id: 'ipad_air',
        name: 'iPad Air',
        type: 'tablet',
        width: 820,
        height: 1180,
        pixelRatio: 2,
        platform: 'ios'
      },
      {
        id: 'pixel_7',
        name: 'Pixel 7',
        type: 'phone',
        width: 412,
        height: 915,
        pixelRatio: 2.6,
        platform: 'android'
      },
      {
        id: 'pixel_6',
        name: 'Pixel 6',
        type: 'phone',
        width: 412,
        height: 915,
        pixelRatio: 2.6,
        platform: 'android'
      },
      {
        id: 'samsung_galaxy_s23',
        name: 'Samsung Galaxy S23',
        type: 'phone',
        width: 360,
        height: 780,
        pixelRatio: 3,
        platform: 'android'
      },
      {
        id: 'samsung_galaxy_tab_s8',
        name: 'Samsung Galaxy Tab S8',
        type: 'tablet',
        width: 800,
        height: 1280,
        pixelRatio: 2,
        platform: 'android'
      },
      {
        id: 'oneplus_11',
        name: 'OnePlus 11',
        type: 'phone',
        width: 412,
        height: 915,
        pixelRatio: 2.6,
        platform: 'android'
      }
    ];
  }

  /**
   * Get all devices
   */
  getDevices() {
    return this.devices;
  }

  /**
   * Get device by ID
   */
  getDevice(deviceId) {
    return this.devices.find(d => d.id === deviceId);
  }

  /**
   * Get default device
   */
  getDefaultDevice() {
    return this.devices[0];
  }

  /**
   * Get devices by type
   */
  getDevicesByType(type) {
    return this.devices.filter(d => d.type === type);
  }

  /**
   * Get devices by platform
   */
  getDevicesByPlatform(platform) {
    return this.devices.filter(d => d.platform === platform);
  }

  /**
   * Add custom device
   */
  addDevice(device) {
    const existing = this.devices.find(d => d.id === device.id);
    if (existing) {
      throw new Error('Device already exists');
    }
    this.devices.push(device);
    return device;
  }

  /**
   * Remove custom device
   */
  removeDevice(deviceId) {
    const index = this.devices.findIndex(d => d.id === deviceId);
    if (index === -1) {
      return false;
    }
    this.devices.splice(index, 1);
    return true;
  }
}

module.exports = { DeviceController };