#!/bin/bash
# Run Flutter app on two devices simultaneously

DEVICE1="a198f071"        # Redmi Note 9 Pro
DEVICE2="emulator-5554"   # Android Emulator

echo "🚀 Starting app on both devices..."

# Run on first device in background
flutter run -d $DEVICE1 &
PID1=$!

# Small delay to avoid conflicts
sleep 2

# Run on second device in background
flutter run -d $DEVICE2 &
PID2=$!

echo "📱 Device 1 PID: $PID1"
echo "📱 Device 2 PID: $PID2"
echo ""
echo "Press Ctrl+C to stop both"

# Wait for both processes
wait $PID1 $PID2
