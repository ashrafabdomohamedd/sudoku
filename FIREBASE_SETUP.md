# Firebase Realtime Database Setup

## Required Database Rules

Go to [Firebase Console](https://console.firebase.google.com/) → Your Project → Realtime Database → Rules

Replace the rules with:

```json
{
  "rules": {
    "leaderboards": {
      "$difficulty": {
        ".read": true,
        ".write": true,
        ".indexOn": ["time", "deviceId"]
      }
    },
    "tournaments": {
      "$tournamentId": {
        "info": {
          ".read": true,
          ".write": true
        },
        "entries": {
          ".read": true,
          "$deviceId": {
            ".write": true
          },
          ".indexOn": ["time"]
        }
      }
    },
    "rooms": {
      "$roomId": {
        ".read": true,
        ".write": true
      }
    }
  }
}
```

## Important Notes

1. **Test Mode vs Locked Mode**
   - If your database is in "Locked Mode", no reads/writes will work
   - Change to the rules above to enable leaderboards

2. **Check Database URL**
   - Your database URL should be: `https://sudoku-challenge-98e4d-default-rtdb.firebaseio.com/`
   - This is configured in `lib/firebase_options.dart`

3. **Verify Setup**
   - After updating rules, complete a puzzle in the app
   - Check Firebase Console → Realtime Database → Data
   - You should see a `leaderboards` node with your score

## Troubleshooting

### "Permission Denied" Error
- Check that rules are set correctly
- Make sure you clicked "Publish" after editing rules

### No Data Appearing
- Check the debug console for error messages
- Verify Firebase is initialized (look for "Firebase initialized successfully")
- Check that `deviceId` is not null in the app

### Leaderboard Shows Empty
- Scores are stored per difficulty: `leaderboards/easy`, `leaderboards/medium`, etc.
- Make sure you're checking the right difficulty tab

## Database Structure

```
/leaderboards
  /easy
    /-Nxxx (auto-generated key)
      name: "Player"
      deviceId: "abc123..."
      time: 245
      mistakes: 1
      timestamp: 1234567890
  /medium
    ...
  /hard
    ...
  /expert
    ...

/tournaments
  /daily_2025-01-15
    /info
      difficulty: "medium"
      seed: 12345
      startTime: ...
      endTime: ...
      status: "active"
    /entries
      /deviceId123
        name: "Player"
        time: 300
        mistakes: 0
        submittedAt: ...
```
