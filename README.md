# Hardware Tracking Database Setup

This directory contains the SQL scripts and configuration examples for setting up the PostgreSQL database for the Hardware Tracking System.

## Prerequisites

- PostgreSQL (v13 or higher recommended) installed and running.
- `psql` command-line tool available.

## Setup Instructions

Run the scripts in the following order.

### 1. Create Role
Run as superuser (e.g., `postgres`).

```bash
psql -U postgres -f 00_create_role.sql
```

### 2. Create Database
Run as superuser.

```bash
psql -U postgres -f 01_create_database.sql
```

### 3. Security Setup
Run as superuser (or database owner) to apply security restrictions.

```bash
psql -U postgres -d hardware_management -f 02_security_setup.sql
```

### 4. Schema Creation
Run as `hardware_admin` or superuser. The script sets the role to `hardware_admin` internally to ensure ownership.

```bash
psql -U hardware_admin -d hardware_management -h localhost -f 03_schema.sql
```

### 5. Triggers
Run as `hardware_admin`.

```bash
psql -U hardware_admin -d hardware_management -h localhost -f 04_triggers.sql
```

## Security Best Practices implemented

1.  **Strict Role**: `hardware_admin` has no superuser or create db privileges.
2.  **Least Privilege**: Public access to the implementation database is fully revoked.
3.  **Owner Separation**: Database and objects are owned by `hardware_admin`, not `postgres`.
4.  **Environment Variables**: Credentials should be stored in a `.env` file.
5.  **SSL**: `DB_SSL_MODE=require` is recommended.

## 🚀 Environment Setup for New Developers

If you are cloning this repository to run your own instance, follow these steps to configure your own Database, Google API Keys, and Server bindings.

### 1. Database Setup (Supabase)
To establish the PostgreSQL database locally or in the cloud:
1. Go to [Supabase](https://supabase.com) and create a free project.
2. Go to **Project Settings > Database**.
3. Scroll down to Connection String. **Check the box for "Use connection pooling"**.
4. Copy the URL (it will look like `postgresql://postgres.[you]:[password]...`).
5. Open the root folder of this repository, create a `.env` file, and set the Database URL:
   ```env
   DATABASE_URL="your_copied_pooler_url_here"
   ```
6. Run the database setup script to generate tables and seed initial data:
   ```bash
   node migrate_supabase.js
   ```

### 2. Google Authentication (OAuth 2.0)
You must generate your own Google Client ID to allow users to sign in.
1. Go to the [Google Cloud Console](https://console.cloud.google.com).
2. Create a new Project.
3. Configure the **OAuth Consent Screen**.
4. Go to Credentials -> **Create Credentials > OAuth client ID**.
5. Choose **Web application**. Add your local URL (e.g., `http://localhost:3000`) and your live Render URL to the *Authorized JavaScript origins*.
6. Copy the **Client ID** (Ends in `.apps.googleusercontent.com`).

**Update the Backend Key:**
In your `.env` file, add the Client ID and set your allowed organization domains:
```env
GOOGLE_CLIENT_ID="your_google_client_id_here"
ALLOWED_DOMAIN="yourcompany.com"
ALLOWED_TEST_EMAIL="your_personal_test_email@gmail.com"
```

**Update the Frontend Keys:**
You must manually replace the hardcoded Google Client IDs in the Flutter codebase:
1. Open `frontend/lib/screens/login_screen.dart` and update `clientId` in the `GoogleSignIn` constructor.
2. Open `frontend/web/index.html` and update the `content` inside the `<meta name="google-signin-client_id">` tag.

### 3. API Connection Strings
Since the Flutter frontend runs on independent devices, it needs to know the absolute IP address or web URL of your Node.js backend.

Search for and update the following variables to point to your laptop's Local IPv4 address (e.g. `192.168.1.xxx:3000`) or your live cloud deployment URL (e.g. `https://your-app.onrender.com`):

1. **`frontend/lib/services/api_service.dart`**: Update `baseUrl`.
   ```dart
   static const String baseUrl = 'https://inventory-app.onrender.com/api'; // Or your local IP
   ```
2. **`frontend/lib/screens/login_screen.dart`**: Update `apiUrl` inside `_authenticateWithBackend()`.
   ```dart
   const String apiUrl = 'https://inventory-app.onrender.com/api/users/google-login';
   ```

### 4. Run the Application
Start the Backend:
```bash
npm install
npm start
```

Start the Frontend (in a new terminal):
```bash
cd frontend
flutter pub get
flutter run
```

To build a physical APK for Android:
```bash
flutter build apk --release
```
