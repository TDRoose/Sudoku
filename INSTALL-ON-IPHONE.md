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

## Step 3 — Connect and prepare your iPhone (do this before signing)

Xcode must see your phone **before** it can create a provisioning profile. If you set up signing first, you may see:

> *Your team has no devices from which to generate a provisioning profile*

1. **Unlock** the iPhone and connect it with a **USB cable** (use a data-capable cable, not charge-only).
2. On the iPhone: **Trust This Computer?** → **Trust**, then enter your passcode.
3. Check your iOS version: **Settings → General → About → iOS Version**.
   - **iOS 15**: there is **no** Developer Mode setting — skip to step 4; that is normal.
   - **iOS 16 or newer**: Developer Mode is often **hidden until Xcode pairs**. Finish step 4–5 first; if the phone then shows **Turn On Developer Mode?**, tap **Turn On**, enter passcode, restart, then turn it **On** under **Settings → Privacy & Security → Developer Mode** (scroll to the bottom of that screen).
4. In Xcode: **Window → Devices and Simulators** → **Devices** tab.
   - Your iPhone should appear by name. Status should become ready (not stuck on “pairing” forever — see troubleshooting below).

Keep the phone connected, unlocked, and on the Home Screen while you do Step 4.

**If Xcode says “already started pairing” but the phone shows nothing:** unplug the cable → quit Xcode → restart the iPhone → plug in again → unlock → open Xcode → Devices window. On the iPhone, leave it unlocked on the Home Screen for 30 seconds. If still stuck, try **Run** (⌘R) with your phone selected as the destination — that often completes pairing or triggers the Developer Mode alert on the phone.

---

## Step 4 — Turn on signing for the app

1. In the left sidebar, click the blue **Sudoku** project (top item).
2. Under **TARGETS**, select **Sudoku** (not SudokuTests).
3. Open **Signing & Capabilities**.
4. Check **Automatically manage signing**.
5. **Team**: choose your name — **Personal Team** (or your paid team if you have one).
6. If a yellow warning remains, click **Try Again** (with the phone still connected).

If Xcode shows an error about the bundle ID:

- Change **Bundle Identifier** to something unique, e.g. `com.yourname.Sudoku` (letters, numbers, dots only).
- The default in this project is `com.tdroose.Sudoku`; only one app can use a given ID per team, so use your own if needed.

Repeat for target **SudokuTests** if tests fail to sign: same Team, automatic signing.

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

### “Your team has no devices…” / “Communication with Apple failed”

1. **Connect the iPhone by USB** and unlock it (Step 3 above).
2. Confirm it appears in **Window → Devices and Simulators**.
3. In **Signing & Capabilities**, select your **Personal Team**, then click **Try Again**.
4. At the top of Xcode, select **your iPhone** as the run destination (not “Any iOS Device” and not a Simulator), then press **Run** (⌘R) once — that registers the device with your team.
5. If it still fails:
   - **Xcode → Settings → Accounts** → select your Apple ID → **Download Manual Profiles** (or sign out and sign back in).
   - Check internet connection; Apple’s servers occasionally time out — wait a minute and **Try Again**.
   - Restart Xcode with the phone still plugged in.

With a **free** Apple ID you normally do **not** need to add devices manually at [developer.apple.com](https://developer.apple.com/account/) — Xcode does that when the phone is connected and you build to it.

### “Failed to register bundle identifier”

Use a unique **Bundle Identifier** under Signing (e.g. `com.yourname.Sudoku`).

### “Signing for Sudoku requires a development team”

Pick a **Team** in Signing & Capabilities and enable **Automatically manage signing**.

### iPhone doesn’t appear in the device menu

- Unplug/replug the cable; unlock the phone.
- In Xcode: **Window → Devices and Simulators** — confirm the phone is connected and not busy.
- On the phone: trust the computer again.

### “Developer Mode is disabled” (iOS 16+)

Run from Xcode once so the phone offers **Turn On Developer Mode?**, then enable it under **Settings → Privacy & Security → Developer Mode** and restart.

### I cannot find Developer Mode in Settings

- **iOS 15**: this toggle does not exist — you do not need it.
- **iOS 16+**: open **Settings → Privacy & Security** and scroll **to the bottom**. If it is missing, connect the phone, select it in Xcode, press **Run** (⌘R), and watch the iPhone for a system alert.
- Update iOS (**Settings → General → Software Update**) if you are far behind.

### Xcode stuck on “already started pairing…”

1. Unplug the iPhone.
2. Quit Xcode completely.
3. Restart the iPhone.
4. Plug in again, unlock, tap **Trust** if asked.
5. Open Xcode → **Window → Devices and Simulators** — wait 30 seconds with the phone unlocked.
6. Select your iPhone as the run destination and press **Run** (⌘R) even if Devices still looks odd — check the **phone** for any new popup.
7. Try another USB port/cable if the phone never appears as ready.

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
- [ ] iPhone connected (USB), trusted Mac, **Developer Mode** on
- [ ] iPhone visible in **Devices and Simulators**
- [ ] **Sudoku** target: Automatic signing + Personal Team (**Try Again** if needed)
- [ ] Device menu: your iPhone selected (not Simulator)
- [ ] **Run** (⌘R)
- [ ] If needed: **Trust** developer in iPhone Settings

For simulator-only play (no phone), see [README.md](README.md).
