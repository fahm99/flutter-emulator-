# Flutter Multi-Emulator

English | [العربية](#arabic)

A powerful VS Code extension for testing Flutter web applications with **multiple device emulators**, screen capture, and responsive design testing. This extension allows you to preview your Flutter web apps on various phones and tablets with realistic device frames and interactive controls.

---

## ✨ Features

- **🌐 Multiple Device Support**: Test on 14+ different devices including:
  - 📱 **iPhone**: 14 Pro, 14 Pro Max, SE
  - 📱 **iPad**: Pro 12.9", Air, Mini
  - 📱 **Android**: Pixel 7, Pixel 6, Samsung Galaxy S23, S22 Ultra, OnePlus 11, Xiaomi 13, Huawei P50
  
- **📸 Screenshot Capture**: Take screenshots of your app with one click (Ctrl+Shift+S)

- **🔄 Hot Reload Support**: Real-time updates with Flutter's experimental web hot reload

- **🔄 Device Rotation**: Seamlessly switch between portrait and landscape orientations

- **🎮 Interactive Controls**: Simulate home, back, power, and volume buttons

- **📲 All Devices View**: Visual grid to quickly select and switch between devices

---

## ⚙ Requirements

- Flutter SDK with web support enabled
- Visual Studio Code version **1.103.0** or higher
- Node.js (for development)

---

## 📦 Installation

### From VSIX File (Recommended for Testing)

1. Download the `.vsix` package from the releases
2. Open **Extensions View** in VS Code (`Ctrl+Shift+X` or `Cmd+Shift+X` on macOS)
3. Click the `...` menu in the top-right corner
4. Select **Install from VSIX...** and choose the downloaded file

### From Source (Development)

```bash
# Clone the repository
git clone https://github.com/fahm99/flutter-emulator-.git
cd flutter-emulator-

# Install dependencies
npm install

# Compile TypeScript
npm run compile

# Package the extension
npm run package

# Install the .vsix file (see above)
```

---

## 🚀 Usage

1. Open a Flutter project with web support enabled
2. Open the Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P` on macOS)
3. Run: `Flutter Multi-Emulator: Start`
4. The emulator will launch in a new panel

### Selecting Devices

- Use the **dropdown menu** in the toolbar to select a device
- Click **"All Devices"** button to see a visual grid of all available devices
- Click any device card to switch to that device

### Taking Screenshots

- Click the **📷 Screenshot** button in the toolbar
- Or use keyboard shortcut: `Ctrl+Shift+S` (macOS: `Cmd+Shift+S`)
- Screenshots are saved to: `${workspaceFolder}/screenshots/`

### Rotating Device

- Click the **↻ Rotate** button in the toolbar
- Or use keyboard shortcut: `Ctrl+Shift+R` (macOS: `Cmd+Shift+R`)

### Hot Reload

- Edit any `.dart` file and save to trigger automatic reload
- Or use keyboard shortcut: `Ctrl+R` (macOS: `Cmd+R`)

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+R` / `Cmd+R` | Hot Reload |
| `Ctrl+Shift+R` / `Cmd+Shift+R` | Rotate Device |
| `Ctrl+Shift+S` / `Cmd+Shift+S` | Take Screenshot |

---

## ⚙️ Extension Settings

| Setting | Description | Default |
|---------|-------------|---------|
| `flutterMultiEmulator.devicePresets` | Device configurations | 14 devices |
| `flutterMultiEmulator.defaultDevice` | Default device | iPhone 14 Pro |
| `flutterMultiEmulator.autoReload` | Auto reload on save | true |
| `flutterMultiEmulator.enableScreenshot` | Enable screenshot feature | true |
| `flutterMultiEmulator.screenshotFolder` | Screenshot save location | `${workspaceFolder}/screenshots` |
| `flutterMultiEmulator.customFlags` | Custom Flutter server flags | [] |

---

## 📝 Available Devices

### Phones
- iPhone 14 Pro (393x852)
- iPhone 14 Pro Max (430x932)
- iPhone SE (375x667)
- Pixel 7 (412x915)
- Pixel 6 (412x915)
- Samsung Galaxy S23 (360x780)
- Samsung Galaxy S22 Ultra (384x824)
- OnePlus 11 (412x915)
- Xiaomi 13 (360x780)
- Huawei P50 (360x780)

### Tablets
- iPad Pro 12.9" (1024x1366)
- iPad Air (820x1180)
- iPad Mini (744x1133)
- Samsung Galaxy Tab S8 (800x1280)

---

## 🐞 Known Issues

- Hot reload for Flutter web is experimental and may have inconsistencies
- Some Flutter plugins may have limited functionality in web mode
- This emulator is a simulation and may not fully replicate physical device behavior
- Screenshot capture may not work for cross-origin iframes due to browser security

---

## 📝 Release Notes

### 1.0.0
- Initial release of **Flutter Multi-Emulator**
- Features:
  - Multiple device support (14+ devices)
  - Screenshot capture functionality
  - Device rotation
  - All devices grid view
  - Hot reload support

---

## 📄 License

MIT License - see LICENSE file for details

---

## 👤 Author

- GitHub: [fahm99](https://github.com/fahm99)

---

<div id="arabic"></div>

# Flutter Multi-Emulator (العربية)

امتداد قوي لـ VS Code لاختبار تطبيقات Flutter web مع **محاكيات أجهزة متعددة**، التقاط الشاشة، واختبار التصميم المتجاوب.

---

## ✨ المميزات

- **🌐 دعم أجهزة متعددة**: اختبار على 14+ جهاز مختلف:
  - 📱 **iPhone**: 14 Pro, 14 Pro Max, SE
  - 📱 **iPad**: Pro 12.9", Air, Mini
  - 📱 **Android**: Pixel 7, Pixel 6, Samsung Galaxy S23, S22 Ultra, OnePlus 11, Xiaomi 13, Huawei P50
  
- **📸 التقاط الشاشة**: التقط لقطات شاشة بتطبيقك بضغطة زر (Ctrl+Shift+S)

- **🔄 دعم Hot Reload**: تحديثات فورية مع Hot reload التجريبي لـ Flutter web

- **🔄 تدوير الجهاز**: التبديل بين الوضع العمودي والأفقي بسلاسة

- **🎮 عناصر تحكم تفاعلية**: محاكاة أزرار home، back، power، و volume

- **📲 عرض جميع الأجهزة**: شبكة بصرية للتبديل السريع بين الأجهزة

---

## ⚙ المتطلبات

- Flutter SDK مع دعم الويب مفعل
- Visual Studio Code الإصدار **1.103.0** أو أعلى
- Node.js (للطوير)

---

## 📦 التثبيت

### من ملف VSIX (موصى به للاختبار)

1. حمل حزمة `.vsix` من الإصدارات
2. افتح **عرض الامتدادات** في VS Code (`Ctrl+Shift+X`)
3. انقر على قائمة `...` في الزاوية العلوية اليمنى
4. اختر **التثبيت من VSIX...** واختر الملف الذي حملته

### من الكود المصدري (تطوير)

```bash
# استنسخ المستودع
git clone https://github.com/fahm99/flutter-emulator-.git
cd flutter-emulator-

# ثبت المتطلبات
npm install

#.compile TypeScript
npm run compile

#Package الامتداد
npm run package

# ثبت ملف .vsix (راجع الخطوات أعلاه)
```

---

## 🚀 الاستخدام

1. افتح مشروع Flutter مع دعم الويب مفعل
2. افتح **لوحة الأوامر** (`Ctrl+Shift+P`)
3. شغل: `Flutter Multi-Emulator: Start`
4. سيطلق المحاكي في لوحة جديدة

### اختيار الأجهزة

- استخدم **القائمة المنسدلة** في شريط الأدوات لتحديد جهاز
- انقر زر **"جميع الأجهزة"** لرؤية شبكة بصرية لجميع الأجهزة المتاحة
- انقر على أي بطاقة جهاز للتبديل إلى هذا الجهاز

### التقاط الشاشة

- انقر زر **📷 لقطة شاشة** في شريط الأدوات
- أو استخدم اختصار لوحة المفاتيح: `Ctrl+Shift+S`
- يتم حفظ لقطات الشاشة في: `${workspaceFolder}/screenshots/`

### تدوير الجهاز

- انقر زر **↻ تدوير** في شريط الأدوات
- أو استخدم اختصار لوحة المفاتيح: `Ctrl+Shift+R`

### Hot Reload

- عدل أي ملف `.dart` واحفظه لتفعيل إعادة التحميل التلقائية
- أو استخدم اختصار لوحة المفاتيح: `Ctrl+R`

---

## ⌨️ اختصارات لوحة المفاتيح

| الاختصار | الإجراء |
|----------|---------|
| `Ctrl+R` | Hot Reload |
| `Ctrl+Shift+R` | تدوير الجهاز |
| `Ctrl+Shift+S` | التقاط صورة للشاشة |

---

## ⚙️ إعدادات الامتداد`

| الإعداد | الوصف | الافتراضي |
|---------|-------|----------|
| `flutterMultiEmulator.devicePresets` | تكوينات الأجهزة | 14 جهاز |
| `flutterMultiEmulator.defaultDevice` | الجهاز الافتراضي | iPhone 14 Pro |
| `flutterMultiEmulator.autoReload` | إعادة التحميل التلقائية | true |
| `flutterMultiEmulator.enableScreenshot` | تفعيل التقاط الشاشة | true |
| `flutterMultiEmulator.screenshotFolder` | مسار حفظ لقطات الشاشة | `${workspaceFolder}/screenshots` |
| `flutterMultiEmulator.customFlags` | أعلام مخصصة للخادم | [] |

---

## 📝 الأجهزة المتاحة

### الهواتف
- iPhone 14 Pro (393x852)
- iPhone 14 Pro Max (430x932)
- iPhone SE (375x667)
- Pixel 7 (412x915)
- Pixel 6 (412x915)
- Samsung Galaxy S23 (360x780)
- Samsung Galaxy S22 Ultra (384x824)
- OnePlus 11 (412x915)
- Xiaomi 13 (360x780)
- Huawei P50 (360x780)

### الأجهزة اللوحية
- iPad Pro 12.9" (1024x1366)
- iPad Air (820x1180)
- iPad Mini (744x1133)
- Samsung Galaxy Tab S8 (800x1280)

---

## 🐞 المشاكل المعروفة

- Hot reload لـ Flutter web تجريبي وقد يكون غير مستقر
- بعض إضافات Flutter قد تكون ذات وظائف محدودة في وضع الويب
- هذا المحاكي محاكاة وقد لا يكرر سلوك الجهاز الفعلي بالكامل
- التقاط الشاشة قد لا يعمل لـ iframes من نطاقات مختلفة بسبب أمان المتصفح

---

## 📝 ملاحظات الإصدار

### 1.0.0
- الإصدار الأول من **Flutter Multi-Emulator**
- المميزات:
  - دعم أجهزة متعددة (14+ جهاز)
  - وظيفة التقاط الشاشة
  - تدوير الجهاز
  - عرض شبكة جميع الأجهزة
  - دعم Hot Reload

---

## 📄 الترخيص

ترخيص MIT - راجع ملف LICENSE للتفاصيل

---

## 👤 المؤلف

- GitHub: [fahm99](https://github.com/fahm99)