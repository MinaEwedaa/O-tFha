# Android Emulator Connection Fix

## ✅ Problem Solved!

The error you were experiencing:
```
Failed to get prediction: ClientException: Connection reset by peer, 
uri=http://10.0.2.2:5000/v1/predict/disease
```

has been fixed by updating the Flask server configuration.

## 🔧 What Was Changed

### 1. Backend Configuration (`.env` file)
Changed:
```
HOST=localhost  ❌
```
To:
```
HOST=0.0.0.0  ✅
```

This allows the Flask server to accept connections from the Android emulator.

### 2. Startup Script (`START_FLASK_NOW.bat`)
Updated to:
- Automatically set `HOST=0.0.0.0`
- Display correct connection URLs for different platforms

## 📱 How to Use

### Step 1: Restart Your Flask Server

If the server is currently running, **stop it** (Ctrl+C), then restart:

```bash
cd backend
START_FLASK_NOW.bat
```

### Step 2: Verify Server is Running Correctly

You should see:
```
🚀 Server starting on http://0.0.0.0:5000
```

✅ **Good** - Server accessible from emulator
❌ **Bad** - `http://localhost:5000` or `http://127.0.0.1:5000`

### Step 3: Test on Your Android Emulator

1. Start your Android emulator
2. Run your Flutter app
3. Tap "Analyze Plant" button
4. It should now work! 🎉

## 🌐 Network Configuration Reference

### Android Emulator
- **Server:** Run with `HOST=0.0.0.0` (already configured)
- **App URL:** `http://10.0.2.2:5000` (already in `ml_service.dart`)
- **Special IP:** `10.0.2.2` is the Android emulator's alias for `localhost` on the host machine

### iOS Simulator
- **Server:** Can use `HOST=localhost` or `HOST=0.0.0.0`
- **App URL:** `http://localhost:5000`
- No special configuration needed

### Physical Android/iOS Device
- **Server:** Must use `HOST=0.0.0.0`
- **App URL:** `http://YOUR_COMPUTER_IP:5000` (e.g., `http://192.168.1.100:5000`)
- **Requirements:**
  1. Both devices on same WiFi network
  2. Find your IP: Run `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
  3. Update `baseUrl` in `lib/services/ml_service.dart` (line 7)
  4. Allow Python through Windows Firewall

## 🧪 Testing the Connection

### Test 1: Health Check
Open in browser or curl:
- Android Emulator: http://10.0.2.2:5000/health
- Physical Device: http://YOUR_IP:5000/health

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2024-..."
}
```

### Test 2: API Root
- Android Emulator: http://10.0.2.2:5000/
- Should show API information and endpoints

### Test 3: Full App Test
1. Open camera screen in app
2. Take/select a photo
3. Tap "Analyze Plant"
4. Should navigate to results screen

## 🔥 Firewall Configuration (If Still Not Working)

### Windows Defender Firewall
1. Search "Windows Defender Firewall" in Start menu
2. Click "Allow an app or feature through Windows Defender Firewall"
3. Click "Change settings"
4. Find "Python" or click "Allow another app..."
5. Browse to: `backend\venv\Scripts\python.exe`
6. ✅ Check both "Private" and "Public" boxes
7. Click OK

### Alternative: Open Port 5000
```powershell
# Run PowerShell as Administrator
New-NetFirewallRule -DisplayName "Flask Dev Server" -Direction Inbound -LocalPort 5000 -Protocol TCP -Action Allow
```

## 🐛 Troubleshooting

### Issue: Server starts but app still can't connect
**Solution:** 
1. Check server output shows `0.0.0.0:5000` not `localhost:5000`
2. Restart the server if needed
3. Try restarting the emulator

### Issue: "API server is not responding"
**Solution:**
1. Ensure Flask server is running (check terminal)
2. Test health endpoint in browser
3. Check firewall settings

### Issue: Works on emulator but not physical device
**Solution:**
1. Confirm both devices on same WiFi
2. Use your computer's actual IP address (not 10.0.2.2)
3. Update `lib/services/ml_service.dart` baseUrl
4. Check firewall allows external connections

### Issue: Connection timeout
**Solution:**
1. Server might be starting up (ML models take 30-60 seconds to load)
2. Wait for "Running on http://0.0.0.0:5000" message
3. Check antivirus isn't blocking Python

## 📝 Important Notes

### Development vs Production
- `HOST=0.0.0.0` is fine for **local development**
- For **production**, use proper deployment (Cloud Run, AWS, Heroku, etc.)
- Never expose development server to public internet

### Security Warning
When running with `HOST=0.0.0.0`:
- Server is accessible to any device on your local network
- Anyone on your WiFi can access it
- Don't use on public WiFi
- Don't enable remote access without authentication

### Model Loading
- First request may be slow (model loading)
- Subsequent requests will be faster
- Console shows "Model loading takes 30-60 seconds"

## 📚 Additional Resources

- **Backend Setup Guide:** `backend/ANDROID_SETUP.md`
- **API Documentation:** http://10.0.2.2:5000/ (when server running)
- **Health Endpoint:** http://10.0.2.2:5000/health
- **Metrics Endpoint:** http://10.0.2.2:5000/metrics

## ✅ Checklist

Before reporting issues, verify:
- [ ] Flask server is running
- [ ] Server shows `0.0.0.0:5000` (not `localhost:5000`)
- [ ] Android emulator is running
- [ ] Flutter app is installed on emulator
- [ ] Health endpoint returns 200 OK
- [ ] Windows Firewall allows Python
- [ ] Server finished loading ML models (wait 30-60s)

## 🎉 Success!

If everything is working:
1. Server shows `0.0.0.0:5000`
2. Health check returns `{"status": "healthy"}`
3. App can analyze plant images
4. Results screen displays correctly

You're all set! Happy plant disease detection! 🌱

