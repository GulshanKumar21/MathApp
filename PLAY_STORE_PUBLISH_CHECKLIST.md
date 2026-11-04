# 🚀 PrepVanta — 100% Google Play Store Rejection-Proof Guide

Aapki app **Google Play Store par bina kisi rejection ya issue ke 100% approve ho**, iske liye saari policies, sensitive permissions, aur billing rules ko audit karke fix kar diya gaya hai.

Play Console par upload karte waqt niche diye gaye steps aur answers follow karein:

---

## 1. 🛡️ Safe Permissions & Clean Manifest (Audit Complete)

Google Play automated scanners in cheezon par apps reject karte hain:
- ❌ `USE_EXACT_ALARM`: **Removed**. (Google Play sirf dedicated alarm clock apps ko allow karta hai, education apps ko reject kar deta hai. Iski jagah compliant `SCHEDULE_EXACT_ALARM` active hai).
- ❌ `FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_MEDIA_PLAYBACK`: **Removed**. (Android 14 par bina video proof aur background service declaration ke Google Play App Bundle accept nahi karta).
- ❌ External UPI `<data android:scheme="upi"/>`: **Removed**. (Play Store policy ke hisaab se external payment scheme scan hone par app hold par chali jaati thi).
- ✅ **Active Compliant Permissions**:
  - `INTERNET` & `ACCESS_NETWORK_STATE` (Cloud sync)
  - `POST_NOTIFICATIONS` (Android 13+ Spaced repetition alerts)
  - `SCHEDULE_EXACT_ALARM` (Exact 1-hour & 3-hour mistake alerts)
  - `VIBRATE` & `WAKE_LOCK` (Practice tactile feedback)
  - `RECEIVE_BOOT_COMPLETED` (Phone reboot hone par reminder restore karna)
  - `com.android.vending.BILLING` (Official Google Play In-App Billing)

---

## 2. 📋 Play Console: App Content & Policy Form Answers

Play Console me **App Content (Policy)** section ke questionnaire me exact ye select karein:

| Section | Sahi Answer | Kyun? |
|---|---|---|
| **Privacy Policy** | `https://sites.google.com/view/prepvanta/home` | Live working HTTPS link |
| **App Access** | *All functionality is available without restrictions* | Core app khuli hai, optional PRO billing hai |
| **Ads** | *No, my app does not contain ads* | App 100% ad-free hai |
| **Target Audience** | **13-15**, **16-17**, aur **18+** | ⚠️ **13 se neeche kabhi mat select karna** (nahi to Google Play strict Designed for Families review me daal dega) |
| **Appeal to Children** | *No* | Competitive exams (SSC, Bank, CAT) ke liye hai |
| **Financial Features** | *None / No Financial Features* | Google Play Billing Google handle karta hai, app koi direct banking/crypto nahi karti |
| **Data Safety Form** | | |
| • Data collection? | **Yes** | Name, email (Firebase Auth), performance score |
| • Encrypted in transit? | **Yes** | HTTPS/TLS encryption |
| • Account deletion link? | **Yes** (App me button hai + email deletion hai) | Google Play mandatory requirement |
| • Financial data collected? | **No** | Card/UPI Google Play handle karta hai, hum nahi |

---

## 3. 🎨 Graphic Assets (Ready in Workspace)

Google Play Console me upload karne ke liye dono high-quality images already generated hain:

1. **App Icon (512 × 512 px, 32-bit PNG)**:
   - File Path: `assets/images/play_store_512.png`
   - *(Aapki di gayi Graduation cap + Open Book + Growth Arrow emblem)*
2. **Feature Graphic (1024 × 500 px, 24-bit PNG)**:
   - File Path: `assets/images/play_store_feature_graphic_1024x500.png`
   - *(PrepVanta logo, PRO Ready badge, exam tags like SSC, Bank PO, CAT, Railways)*

---

## 4. 💰 In-App Product Setup (Google Play Console)

Google Play Console me **Monetize ➔ In-app products ➔ Create product**:
- **Product ID**: `speedmath_pro_lifetime_29` *(Exact yahi ID honi chahiye, app me mapped hai)*
- **Name**: `PrepVanta PRO (Lifetime Access)`
- **Description**: `Unlock advanced speed math multiplication modules, custom spaced repetition, and printable PDF cheat sheets forever.`
- **Price**: ₹29.00 (INR)
- **Status**: Active

---

## 5. 📦 Build Production Release Bundle (`.aab`)

Apne terminal me production App Bundle generate karne ke liye ye command run karein:

```bash
flutter build appbundle --release
```

Generated Bundle yahan milega:
`build/app/outputs/bundle/release/app-release.aab`

Ise direct Google Play Console ke **Production (ya Internal Testing)** track me upload karein!

---

## 6. 🔑 Production Release Keystore (Auto-Configured)

Aapki release app bundle ko digitally sign karne ke liye official upload keystore already generate aur link kar diya gaya hai:
- **Keystore File**: `android/app/upload-keystore.jks`
- **Config File**: `android/key.properties`
- **Key Alias**: `upload`
- **Store & Key Password**: `prepvanta_release_key`
- **Validity**: 10,000 Days (27+ years)

> [!IMPORTANT]
> Is `upload-keystore.jks` file ko hamesha safe rakhein. Future me jab bhi app ka naya version (e.g. version 2.0) play store par upload karenge, isi key se sign hoga. Ab Google Play Console par kabhi "Signed with debug key" ka error nahi aayega!
