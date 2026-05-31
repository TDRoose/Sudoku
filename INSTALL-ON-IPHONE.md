# Install Sudoku on your iPhone

This app is built for **your own phone**, not the App Store. You install it from Xcode on your Mac using your **Apple ID** (free is enough).

**Requirements**

- Mac with **Xcode** installed
- iPhone on **iOS 15 or later** (iPhone 13 and newer; same as the app’s minimum version)
- USB cable, or **wireless debugging** set up in Xcode
- An **Apple ID** signed into Xcode

---

## Step 1 — Get the project on your Mac

If you already have the repo (e.g. `Desktop/sudoku`), skip to Step 2.

Otherwise clone it:

```bash
git clone git@github.com:TDRoose/Sudoku.git
cd Sudoku
```

Open **`Sudoku.xcodeproj`** (double-click it or **File → Open** in Xcode).

---

## Step 2 — Sign in to Xcode with your Apple ID

1. Open **Xcode**.
2. Menu **Xcode → Settings…** (or **Preferences…** on older Xcode).
3. Go to **Accounts**.
4. Click **+** → **Apple ID** → sign in with the Apple ID you use on your iPhone.

You do **not** need a paid **Apple Developer Program** membership ($99/year) for personal use. A free account gives you a “Personal Team” for development.

---

## Step 3 — Turn on signing for the app

1. In the left sidebar, click the blue **Sudoku** project (top item).
2. Under **TARGETS**, select **Sudoku** (not SudokuTests).
3. Open **Signing & Capabilities**.
4. Check **Automatically manage signing**.
5. **Team**: choose your name — **Personal Team** (or your paid team if you have one).

If Xcode shows an error about the bundle ID:

- Change **Bundle Identifier** to something unique, e.g. `com.yourname.Sudoku` (letters, numbers, dots only).
- The default in this project is `com.tdroose.Sudoku`; only one app can use a given ID per team, so use your own if needed.

Repeat for target **SudokuTests** if tests fail to sign: same Team, automatic signing.

---

## Step 4 — Prepare your iPhone

1. **Unlock** the phone and connect it with USB (or use a device already paired for wireless debugging).
2. On the iPhone, if prompted **Trust This Computer?** → **Trust**, and enter your passcode.
3. On **iOS 16+**, enable **Developer Mode** (needed to run apps from Xcode):
   - **Settings → Privacy & Security → Developer Mode** → On → restart when asked.

The first time you run an app from Xcode, the phone may ask you to confirm Developer Mode again.

---

## Step 5 — Select your iPhone and run

1. At the top of Xcode, next to the Run (▶) button, open the device menu.
2. Choose **your iPhone** (by name), not a Simulator.
3. Press **Run** (⌘R) or the ▶ button.

Xcode will build the app, install it on the phone, and launch it. The first build can take a minute.

---

## Step 6 — Trust the developer on the phone (first install only)

If the app icon appears but won’t open, or you see “Untrusted Developer”:

1. On the iPhone: **Settings → General → VPN & Device Management** (sometimes **Device Management**).
2. Under **Developer App**, tap your Apple ID / developer name.
3. Tap **Trust …** → **Trust**.

Open **Sudoku** from the home screen again.

---

## What to expect day to day

| Topic | What happens |
|--------|----------------|
| **Updates** | Change code in Xcode → select your iPhone → **Run** again. Xcode reinstalls the new build. |
| **Free Apple ID** | Apps signed with a free Personal Team **expire after about 7 days**. When the app won’t open, connect the phone and **Run** from Xcode again to refresh. |
| **Paid Developer account** | Certificates last longer; still reinstall from Xcode when you change the app. |
| **Offline** | The app runs fully on the phone; no server required. |
| **App Store** | This guide does **not** publish to the App Store. That’s a separate process (Archive, TestFlight, review). |

---

## Troubleshooting

### “Failed to register bundle identifier”

Use a unique **Bundle Identifier** under Signing (e.g. `com.yourname.Sudoku`).

### “Signing for Sudoku requires a development team”

Pick a **Team** in Signing & Capabilities and enable **Automatically manage signing**.

### iPhone doesn’t appear in the device menu

- Unplug/replug the cable; unlock the phone.
- In Xcode: **Window → Devices and Simulators** — confirm the phone is connected and not busy.
- On the phone: trust the computer again.

### “Developer Mode is disabled”

Turn on **Developer Mode** in Settings (see Step 4) and restart.

### Build errors about iOS version

The app targets **iOS 15+**. If your iPhone 13 is on an older iOS version, update it in **Settings → General → Software Update**.

### App disappeared or won’t launch after a week

Normal with a **free** Personal Team. Plug in the phone and **Run** from Xcode to reinstall.

---

## Optional: run without a cable (wireless)

1. Connect the iPhone once by USB.
2. **Window → Devices and Simulators** → select your iPhone → **Connect via network**.
3. After pairing, you can choose the phone from the device menu over Wi‑Fi (same network as the Mac).

---

## Quick checklist

- [ ] Xcode installed, Apple ID added under **Settings → Accounts**
- [ ] **Sudoku** target: Automatic signing + Personal Team
- [ ] iPhone: trusted Mac, **Developer Mode** on
- [ ] Device menu: your iPhone selected
- [ ] **Run** (⌘R)
- [ ] If needed: **Trust** developer in iPhone Settings

For simulator-only play (no phone), see [README.md](README.md).
