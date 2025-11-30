# Deploying Firestore Rules and Indexes

The Firestore security rules and indexes have been updated to support the new schedule feature. You need to deploy both to Firebase.

## IMPORTANT: Deploy Indexes First

Deploy the indexes before testing the app to avoid "Error loading tasks" issues.

### Deploy Indexes

#### Option 1: Using Firebase Console (Easiest)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** → **Indexes**
4. Click **Add Index**
5. Add the following composite index:
   - **Collection ID**: `schedules`
   - **Fields to index**:
     - Field: `userId`, Order: Ascending
     - Field: `startDateTime`, Order: Ascending
   - **Query scope**: Collection
6. Click **Create**
7. Wait for the index to build (usually takes a few minutes)

#### Option 2: Using Firebase CLI

If you have Firebase CLI installed:

```bash
firebase deploy --only firestore:indexes
```

## Deploy Security Rules

After deploying indexes, deploy the security rules:

### Option 1: Using Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** → **Rules**
4. Copy the contents of `firestore.rules` from your project
5. Paste it into the Firebase Console rules editor
6. Click **Publish**

### Option 2: Using Firebase CLI

If you have Firebase CLI installed:

```bash
firebase deploy --only firestore:rules
```

Or deploy both at once:

```bash
firebase deploy --only firestore
```

## Installing Firebase CLI (if needed)

### Windows
```powershell
npm install -g firebase-tools
firebase login
firebase deploy --only firestore
```

### Mac/Linux
```bash
npm install -g firebase-tools
firebase login
firebase deploy --only firestore
```

## What Was Fixed

### The Problem
The app was showing "Error loading tasks" intermittently because:
1. Complex Firestore queries with multiple `where` clauses required composite indexes
2. The indexes weren't created, causing queries to fail
3. Error handling wasn't robust enough

### The Solution
1. **Simplified queries** - Now queries fetch all user tasks and filter in-memory for the date
2. **Added composite index** - Created index for `userId` + `startDateTime` for better performance
3. **Better error handling** - Added error messages with retry button
4. **Stream error handling** - Added `.handleError()` to gracefully handle query failures

## What the Rules Do

The updated rules add support for the `schedules` collection:

- Users can **create** schedules (only for themselves)
- Users can **read** their own schedules
- Users can **update** their own schedules
- Users can **delete** their own schedules
- Admins can read all schedules

This ensures that each user can only access and manage their own scheduled tasks.

## Testing

After deploying BOTH the indexes and rules, test the feature by:

1. **Restart your app** completely (close and reopen)
2. Creating a new task in the app
3. Viewing it on the Home Screen (if scheduled for today)
4. Viewing it on the Schedule Screen
5. Completing and deleting tasks

If you still get errors:
- Check that the index is fully built (not still building)
- Check that the rules are deployed correctly
- Check the Firebase Console logs for any permission errors
- Try logging out and back in
- Clear app data and restart

## Troubleshooting

### "Error loading tasks" still appearing
1. Check if the composite index is fully built in Firebase Console
2. Make sure you're logged in to the app
3. Check Firebase Console → Firestore → Data to verify tasks exist
4. Check that `firestore.rules` is deployed

### Index still building
- Indexes can take 5-15 minutes to build
- You'll see a building indicator in Firebase Console
- Wait for it to complete before testing

### Permission denied errors
- Make sure `firestore.rules` is deployed
- Verify the user is authenticated
- Check Firebase Console logs for specific permission errors


