# Nexus App

Flutter frontend for Nexus.

## Local Google Sign-In

Google login needs a server OAuth client id at app launch. The backend must use
the same web OAuth client id and secret in Identity secrets.

The app can receive one client id per supported platform:

- `GOOGLE_OAUTH_WEB_CLIENT_ID`
- `GOOGLE_OAUTH_ANDROID_CLIENT_ID`
- `GOOGLE_OAUTH_IOS_CLIENT_ID`
- `GOOGLE_OAUTH_MACOS_CLIENT_ID`
- `GOOGLE_OAUTH_SERVER_CLIENT_ID`

`GOOGLE_OAUTH_SERVER_CLIENT_ID` is the web/server client id used by Identity to
exchange the server auth code.

Run locally on web with:

```bash
flutter run
```

The local web dev server is pinned to `http://localhost:3000` through
`web_dev_config.yaml`, and the public local Google web client id has a default
value in the app config.

To override OAuth values explicitly, use:

```bash
cp .env.exemple .env
flutter run --dart-define-from-file=.env
```

For Linux desktop, Google login uses the system browser and a local loopback
callback. Add this Authorized redirect URI to the same Google Web OAuth client:

```text
http://127.0.0.1:53682/oauth/google/callback
```

For Android emulator or devices, make sure `ApiConfig.authUrl` points to a host
reachable from that platform.
