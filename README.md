# SportsPulse — Full Stack Project

Next.js + Capacitor + Swift + Supabase + RevenueCat

---

## Project Structure

```
sportspulse/
├── src/
│   ├── app/
│   │   ├── page.tsx              # Home screen (live matches)
│   │   ├── layout.tsx            # Root layout
│   │   └── globals.css           # Global styles
│   ├── components/
│   │   └── MatchCard.tsx         # Match card component
│   ├── lib/
│   │   └── supabase.ts           # Supabase client + realtime
│   └── plugins/
│       └── SportsPulsePlugin.ts  # Capacitor JS bridge
│
├── ios/                          # Swift files → drop into Xcode
│   ├── App/AppDelegate.swift
│   ├── MatchLiveActivity/
│   │   ├── MatchAttributes.swift
│   │   ├── MatchWidgetView.swift
│   │   └── LiveActivityManager.swift
│   ├── Plugins/SportsPulsePlugin.swift
│   └── Purchases/PurchaseManager.swift
│
├── android/
│   └── app/src/main/
│       ├── java/com/sportspulse/MainActivity.kt
│       └── AndroidManifest.xml
│
├── capacitor.config.ts
├── next.config.js
├── package.json
└── .env.local                    # Add your Supabase keys here
```

---

## Run in Browser

```bash
npm install
npm run dev
# Open http://localhost:3000
```

---

## Build for Android (APK)

Requirements: Android Studio

```bash
npm install @capacitor/android
npx cap add android
npm run cap:sync
npx cap open android
# In Android Studio: Build → Build APK
```

---

## Build for iOS (IPA)

Requirements: Mac + Xcode + Apple Developer Account ($99/yr)

```bash
npm install @capacitor/ios
npx cap add ios
npm run cap:sync
npx cap open ios
# Copy Swift files from ios/ folder into Xcode project
# In Xcode: Product → Archive → Distribute App
```

### Required Xcode capabilities
- Push Notifications
- Background Modes → Remote Notifications
- Info.plist: NSSupportsLiveActivities = YES

---

## Supabase Setup

Edit `.env.local`:
```
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Create matches table:
```sql
create table matches (
  id             uuid primary key default gen_random_uuid(),
  home_team      text,
  away_team      text,
  home_short     text,
  away_short     text,
  home_score     int default 0,
  away_score     int default 0,
  minute         int default 0,
  status         text default 'upcoming',
  competition    text,
  kickoff        timestamptz,
  win_prob_home  float default 0.5
);
alter publication supabase_realtime add table matches;
```

---

## Tech Stack

| Layer          | Tech                        |
|----------------|-----------------------------|
| Web App        | Next.js 14 + React          |
| Styling        | Tailwind CSS                |
| Backend        | Supabase (DB + Realtime)    |
| Hosting        | Vercel                      |
| Mobile Wrapper | Capacitor v6                |
| iOS Native     | Swift + SwiftUI             |
| Live Widget    | ActivityKit                 |
| Push           | APNs (iOS) + FCM (Android)  |
| Payments       | RevenueCat                  |
