# 🚀 Pre-Launch Feature Roadmap

> Strategic breakdown — prioritized by impact on **retention**, **revenue**, and **store ratings**.

---

## 📊 Implementation Progress

| Category | Completed | Remaining |
|----------|-----------|-----------|
| 🔴 Must-Have (Blockers) | 4/4 | 0 ✅ |
| 🟡 High Impact | 0/6 | 6 |
| 🟢 Version 2 | 0/6 | 6 |

### Recently Completed ✅
- **Legal & Compliance** — Privacy Policy, Terms of Service, GDPR consent dialog
- **Rate Us Prompt** — Triggers after 3 perfect wins, uses native in-app review
- **Ad Infrastructure** — Banner, Interstitial, Rewarded ads with AdMob

---

## 🔴 MUST-HAVE Before Publishing

> These are **blockers**. Without them, you'll get 1-star reviews or get rejected.

### 1. Legal & Compliance ✅

| Requirement | Status | Notes |
|-------------|--------|-------|
| Privacy Policy page | ✅ Done | Required by both App Store & Play Store |
| GDPR/CCPA consent dialog | ✅ Done | Required in EU/US, especially for ads |
| Terms of Service link | ✅ Done | Required for app store approval |

> ✅ **Implemented:** Privacy Policy & Terms of Service in `lib/widgets/legal_modal.dart`, GDPR consent in `lib/widgets/gdpr_consent_dialog.dart`

---

### 2. Ad Infrastructure ✅

| Ad Type | Placement | Status |
|---------|-----------|--------|
| Rewarded Video | "Watch ad to get a hint" | ✅ Done |
| Interstitial | Between completed games (every 3 games) | ✅ Done |
| Banner | Bottom of home screen | ✅ Done |

> ✅ **Implemented:** `lib/services/ad_service.dart`, respects GDPR consent, uses test ads in debug mode

---

### 3. Rate Us Prompt ✅

- ✅ Trigger after user wins **3rd game** with **no mistakes**
- This is your **#1 driver** for App Store rating
- Timing is everything — catch them at peak satisfaction

> ✅ **Implemented:** `lib/services/rate_app_service.dart` + `lib/widgets/rate_app_dialog.dart`

---

### 4. Offline Mode Guarantee

- All core gameplay must work **100% offline**
- Show graceful fallback when leaderboards fail to load

---

## 🟡 HIGH IMPACT — Ship at Launch or Shortly After

### 5. 🔁 Retention Loops *(The most important thing)*

> Without retention → users leave after 2 days → no ad revenue

#### Daily Login Reward (coin/gem system)

| Day | Reward |
|-----|--------|
| Day 1 | 10 coins |
| Day 2 | 15 coins |
| Day 3 | 20 coins |
| ... | ... |
| Day 7 | 50 coins |

- Coins used to buy hints, unlock themes
- **This alone can 2-3x your Day 7 retention**

#### Streak Protection

- *"You have a 12-day streak! Use a Streak Shield to protect it"*
- Rewarded ad to protect streak = **top monetization moment**

#### Push Notifications

- *"Your daily challenge is ready 🧩"*
- *"You have a 5-day streak — don't break it!"*
- *"[Friend] just beat your time on Hard!"*

---

### 6. 📤 Shareable Result Card *(Viral Growth)*

Like Wordle's share pattern — this is **free organic marketing**:

```
🧩 Sudoku · Hard · Day 47
⏱ 4:32 | ✅ 0 mistakes | 🔥 12-day streak

⬜🟦⬜🟦⬜🟦⬜🟦⬜
🟦⬜🟦⬜🟦⬜🟦⬜🟦
...

Play: [app link]
```

Users share to WhatsApp, Twitter, Instagram Stories → **free installs**

---

### 7. 🎨 Themes & Customization *(IAP + Engagement)*

- Board color themes (Dark Blue, Forest, Sunset, Midnight...)
- Number font styles (Classic, Bold, Rounded)
- Some free, some purchasable (IAP) or unlockable via coins
- Gives users a reason to keep playing beyond puzzle-solving

---

### 8. 💡 Smart Hint System *(Monetization Core)*

| Level | Feature | Cost |
|-------|---------|------|
| Level 1 | Highlight the cell to fill | Free / cheap |
| Level 2 | Show the number + explanation | Coins / rewarded ad |
| Level 3 | Auto-solve one region | Premium cost |

> Turns hints into a **monetization touchpoint** instead of a free giveaway

---

### 9. 🏆 Friends Leaderboard

- Global leaderboards are motivating at first but **discouraging long-term** (you're always #847,293)
- Friends leaderboard keeps competition **personal and achievable**
- Share invite link → friend installs → joins your board
- This is your **viral acquisition channel**

---

### 10. 📱 App Store Optimization (ASO)

Before you submit:

| Element | Action |
|---------|--------|
| App icon | Test multiple versions (A/B test) |
| Screenshots | Show gameplay + features, not just UI |
| Preview video | 15-second gameplay clip |
| Keywords | "sudoku", "brain puzzle", "number game", "daily puzzle" |
| Localization | At least English + Arabic + Spanish = 3x reach |

---

## 🟢 VERSION 2 — After You See Traction

| Feature | Why It Matters |
|---------|----------------|
| Puzzle Variants (Killer Sudoku, Diagonal) | Re-engages users who solved everything |
| Seasonal Events (Ramadan pack, Christmas) | Spikes in engagement + press coverage |
| Clubs/Groups | Small friend groups with weekly leaderboards |
| Subscription tier (Remove ads + extras) | Predictable monthly revenue |
| Accessibility (colorblind mode, larger fonts) | Required for enterprise/government distribution + goodwill |
| Puzzle Editor (make your own puzzle) | UGC = free content forever |

---

## 💰 Revenue Projection Logic

```
Daily Active Users (DAU) × Ad eCPM × Impressions per session = Revenue
```

### Example at 10,000 DAU:

| Ad Type | Calculation | Daily Revenue |
|---------|-------------|---------------|
| Rewarded ads | 10,000 × 30% CTR × $15 CPM | ~$45/day |
| Interstitials | 10,000 × 60% see it × $8 CPM | ~$48/day |
| Banners | 10,000 × $2 CPM | ~$20/day |
| **Total** | | **~$113/day (~$3,400/mo)** |

> 🔑 **The multiplier is retention.** Going from 10% Day-7 retention to 25% doesn't just add users — it **multiplies** your revenue per user.

---

## ✅ Recommended Launch Checklist

### Legal & Compliance
- [x] Privacy Policy + Terms of Service ✅
- [x] GDPR consent dialog ✅

### Monetization
- [x] Rewarded ad for hints ✅
- [x] Interstitial between games (NOT mid-game) ✅

### Engagement
- [x] Rate Us prompt (after 3rd win) ✅
- [ ] Daily login reward
- [ ] Push notifications
- [ ] Shareable result card

### Technical
- [ ] Offline graceful fallback

### Store Presence
- [ ] App Store screenshots + preview video
- [ ] At least 2 board themes

---

## ⚠️ Critical Advice

> **The single biggest mistake most indie game devs make** is launching without the retention loop (daily reward + push notifications). You get a spike on launch day, then users churn in 48 hours and never come back. **Nail that first.**
