# 🚀 Speed Math Pro — Competitive Exam Calculation Suite
> Complete Flutter Source Code, Architecture, Admin Panel, Monetization & Handover Documentation.

---

## 📌 Executive Summary
**Speed Math Pro** is a high-performance calculation workout and speed-drilling mobile application tailored specifically for students preparing for **SSC (CGL, CHSL, MTS), Banking (IBPS, SBI PO/Clerk, RRB), Railways (NTPC, Group D), CAT, CDS, and State PCS**.

The app is built to maximize mental arithmetic speed, accuracy, and reflex recall with zero distractions.

---

## 🧮 1. Core Modules & Content

| Module | Scope / Range | Description |
| :--- | :--- | :--- |
| **Multiplication Tables** | 1 to 50 (up to $\times 20$) | Horizontal number picker with high-speed flash recall tables. |
| **Square Numbers** | 1 to 50 | Grid and list layout for instant square value recall. |
| **Cube Numbers** | 1 to 30 | High-speed cube calculation cards. |
| **Fractions $\leftrightarrow$ Decimals & %** | $1/2$ to $1/25$, $3/8$, $5/8$, $7/8$, etc. | Crucial percentage & decimal equivalence memory sheets. |
| **Pythagorean Triples** | $(3,4,5)$, $(5,12,13)$, $(7,24,25)$, $(8,15,17)$, $(9,40,41)$, $(20,21,29)\dots$ | Exam-favourite geometry & trigonometry triplets. |
| **Vedic Math Shortcuts** | Squares of 5s, Base 100, $\times 11$, $\times 99$, etc. | Practical calculation shortcut rules with examples. |

---

## ⚡ 2. High-Performance Practice & Game Modes

1. **MCQ Timed Practice**:
   - Dynamic question generation with intelligent close distractors.
   - Real-time ticker tracking seconds per calculation.
   - Scoring algorithm (+10 pts correct, -2 pts wrong).
   - Instant calculation accuracy % and average speed per question.
2. **Survival Rush (4-Second Sudden Death)**:
   - High-adrenaline reflex mode. 1 mistake or time-out ends the session.
   - Streak multipliers for high scores.
3. **Numpad Direct-Type Drill**:
   - Custom in-app numeric keypad for true memory recall without relying on multiple-choice clues.
4. **Admin Daily Target Challenge**:
   - Hand-picked custom questions published directly by the Admin for today's practice.
5. **PDF Formula Cheat-Sheet Export**:
   - One-tap printable A4 cheat-sheet generator (Tables, Squares, Cubes, Triples) for students' study tables.

---

## 🔁 3. Smart Mistake Notebook & Notification Loop

- **Automatic Error Detection**: Any calculation answered incorrectly during practice is instantly captured.
- **English Revision Alert**: The student receives an immediate push notification:
  > *"⚠️ Revision Alert: Weak in TABLES - You answered '24 × 7 = ?' incorrectly. Go to Learn Mode now and review it!"*
- **Direct Learn Redirection**: One-tap **"Learn Now"** shortcut transports the student to that exact formula table.
- **Targeted Mistake Drill**: Students can hit **"Drill Now"** to practice exclusively against their historical mistakes until mastered.

---

## 🛠️ 4. Admin Management Channel

The in-app Admin Channel (accessed securely via Profile) gives full dynamic control:

1. **Live Question Management**:
   - Add new custom questions with prompt, correct answer, and distractors.
   - Edit existing questions on the fly.
   - Delete questions.
   - Content updates immediately reflect on students' apps without waiting for a Google Play Store update.
2. **User Count & Real-time Revenue Ledger**:
   - Live registered student count.
   - Total gross and net revenue tracking.
   - Verified ₹29 One-Time Purchase transaction ledger with Order ID, Student Name, Date, and Status.
3. **Push Notification Broadcast Console**:
   - Send custom broadcast alerts and study reminders directly to all students' device status bars and App Notification Inboxes (🔔).

---

## 🔐 5. Authentication & Cloud Backend

- **Email & Password Authentication**: Standard secure registration and sign-in.
- **Mobile Number OTP (+91)**: One-tap phone number authentication for Indian students.
- **Google Sign-In**: Instant one-tap onboarding.
- **Offline-First Resilience**: Full offline practice capability. Local SQLite/SharedPreferences cache auto-syncs to cloud servers whenever an internet connection is established.

---

## 💰 6. Commercial Cost Breakdown (Transparent)

| Service | Provider | One-Time / Recurring | Estimated Cost |
| :--- | :--- | :--- | :--- |
| **Google Play Developer Account** | Google Console | One-Time Lifetime | **$25 (~₹2,100)** |
| **Database & Cloud Functions** | Firebase / Supabase | Free Tier | **₹0 / Free** (Sufficient for first 50,000 users) |
| **Mobile OTP / SMS** | Firebase Phone Auth | Free Tier | **Free up to 10,000 SMS / month** |
| **Admin & Web Hosting** | Firebase Hosting / Vercel | Free Tier | **₹0 / Free** |
| **Push Notification Server** | Firebase Cloud Messaging (FCM) | Free Tier | **100% Free & Unlimited** |
| **Total Mandatory Overhead** | — | — | **Only ₹2,100 (Google Account fee)** |

---

## 📦 7. How to Build & Handover to the Client

### A. Run in Web Browser (For Instant Client Demo):
```powershell
flutter run -d chrome
```

### B. Generate Android APK for Client Testing:
```powershell
flutter build apk --release
```
*Output APK location:* `build/app/outputs/flutter-apk/app-release.apk`

### C. Generate Android App Bundle (.aab) for Google Play Publishing:
```powershell
flutter build appbundle --release
```
*Output AAB location:* `build/app/outputs/bundle/release/app-release.aab`
