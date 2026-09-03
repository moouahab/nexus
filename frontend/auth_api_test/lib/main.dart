import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'http_client_factory.dart';

void main() {
  runApp(const AuthApiTestApp());
}

class AuthApiTestApp extends StatelessWidget {
  const AuthApiTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Auth API Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            side: BorderSide(color: Color(0xFFE1E5EA)),
          ),
        ),
      ),
      home: const AuthApiTestPage(),
    );
  }
}

class AuthApiTestPage extends StatefulWidget {
  const AuthApiTestPage({super.key});

  @override
  State<AuthApiTestPage> createState() => _AuthApiTestPageState();
}

class _AuthApiTestPageState extends State<AuthApiTestPage> {
  final _client = AuthApiClient();
  final _baseUrl = TextEditingController(text: 'http://127.0.0.1:8182');
  final _username = TextEditingController(text: _defaultUsername());
  final _password = TextEditingController(text: 'test-password-123');
  final _email = TextEditingController();
  final _newEmail = TextEditingController();
  final _verificationCode = TextEditingController();
  final _resetEmail = TextEditingController();
  final _resetCode = TextEditingController();
  final _newPassword = TextEditingController(text: 'new-password-123');
  final _oauthCode = TextEditingController();
  final _oauthRedirectUri = TextEditingController(
    text: 'http://127.0.0.1:5173/auth/callback',
  );
  final _oauthCodeVerifier = TextEditingController();

  AuthMode _mode = AuthMode.cookie;
  String _oauthProvider = 'google';
  String? _accessToken;
  String? _refreshToken;
  bool _busy = false;
  ApiResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _email.text = '${_username.text}@example.com';
    _newEmail.text = 'new_${_email.text}';
    _resetEmail.text = _email.text;
  }

  @override
  void dispose() {
    _client.close();
    for (final controller in [
      _baseUrl,
      _username,
      _password,
      _email,
      _newEmail,
      _verificationCode,
      _resetEmail,
      _resetCode,
      _newPassword,
      _oauthCode,
      _oauthRedirectUri,
      _oauthCodeVerifier,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexus Auth API Test'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: StatusPill(
                label: _busy ? 'running' : _lastResult?.statusLabel ?? 'idle',
                good: _lastResult == null || _lastResult!.ok,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1120;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 440, child: _controls()),
                      const SizedBox(width: 16),
                      Expanded(child: _resultPanel()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _controls(),
                      const SizedBox(height: 16),
                      _resultPanel(),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _controls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section(
          title: 'Connection',
          children: [
            TextField(
              controller: _baseUrl,
              decoration: const InputDecoration(
                labelText: 'API base URL',
                prefixIcon: Icon(Icons.dns_outlined),
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<AuthMode>(
              segments: const [
                ButtonSegment(
                  value: AuthMode.cookie,
                  icon: Icon(Icons.cookie_outlined),
                  label: Text('Cookie'),
                ),
                ButtonSegment(
                  value: AuthMode.body,
                  icon: Icon(Icons.phone_iphone),
                  label: Text('Body'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (value) =>
                  setState(() => _mode = value.first),
            ),
          ],
        ),
        _section(
          title: 'Identity',
          children: [
            _field(_username, 'Username', Icons.person_outline),
            _field(_email, 'Email', Icons.alternate_email),
            _field(_password, 'Password', Icons.lock_outline, secret: true),
            _actions([
              _action(Icons.person_add_alt_1, 'Register', _register),
              _action(Icons.login, 'Login', _login),
              _action(Icons.badge_outlined, 'Me', _me),
              _action(Icons.refresh, 'Refresh', _refresh),
              _action(Icons.logout, 'Logout', _logout),
            ]),
          ],
        ),
        _section(
          title: 'Email',
          children: [
            _field(
              _verificationCode,
              'Verification code',
              Icons.verified_outlined,
            ),
            _field(_newEmail, 'New email', Icons.mark_email_unread_outlined),
            _actions([
              _action(Icons.send_outlined, 'Resend', _resendEmail),
              _action(Icons.verified_user_outlined, 'Verify', _verifyEmail),
              _action(Icons.edit_outlined, 'Change', _changeEmail),
            ]),
          ],
        ),
        _section(
          title: 'Password Reset',
          children: [
            _field(_resetEmail, 'Reset email', Icons.alternate_email),
            _field(_resetCode, 'Reset code', Icons.pin_outlined),
            _field(_newPassword, 'New password', Icons.password, secret: true),
            _actions([
              _action(Icons.outgoing_mail, 'Start', _startPasswordReset),
              _action(Icons.key_outlined, 'Finish', _finishPasswordReset),
              _action(Icons.lock_reset, 'Change', _changePassword),
            ]),
          ],
        ),
        _section(
          title: 'OAuth',
          children: [
            DropdownButtonFormField<String>(
              initialValue: _oauthProvider,
              decoration: const InputDecoration(
                labelText: 'Provider',
                prefixIcon: Icon(Icons.account_tree_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'google', child: Text('Google')),
                DropdownMenuItem(value: 'github', child: Text('GitHub')),
                DropdownMenuItem(value: 'apple', child: Text('Apple')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _oauthProvider = value);
              },
            ),
            const SizedBox(height: 12),
            _field(_oauthCode, 'Authorization code', Icons.code),
            _field(_oauthRedirectUri, 'Redirect URI', Icons.link),
            _field(_oauthCodeVerifier, 'PKCE code verifier', Icons.security),
            _actions([_action(Icons.hub_outlined, 'OAuth Login', _oauthLogin)]),
          ],
        ),
      ],
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool secret = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: secret,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
  }

  Widget _actions(List<Widget> children) {
    return Wrap(spacing: 8, runSpacing: 8, children: children);
  }

  Widget _action(
    IconData icon,
    String label,
    Future<ApiResult> Function() call,
  ) {
    return FilledButton.icon(
      onPressed: _busy ? null : () => _run(label, call),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Widget _resultPanel() {
    final result = _lastResult;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Result',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Clear result',
                  onPressed: () => setState(() => _lastResult = null),
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusPill(label: _mode.name, good: true),
                StatusPill(
                  label: _accessToken == null
                      ? 'no access token'
                      : 'access token',
                  good: _accessToken != null,
                ),
                StatusPill(
                  label: _refreshToken == null
                      ? 'no refresh token'
                      : 'refresh token',
                  good: _refreshToken != null,
                ),
                StatusPill(label: kIsWeb ? 'web' : 'native', good: true),
              ],
            ),
            const SizedBox(height: 16),
            SelectableText(
              result == null
                  ? '{}'
                  : const JsonEncoder.withIndent('  ').convert(result.toJson()),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _run(String action, Future<ApiResult> Function() call) async {
    setState(() => _busy = true);
    try {
      final result = await call();
      _storeTokens(result.body);
      setState(() => _lastResult = result.copyWith(action: action));
    } catch (error) {
      setState(() {
        _lastResult = ApiResult(
          action: action,
          statusCode: 0,
          headers: const {},
          body: {'error': error.toString()},
        );
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Uri _base() => Uri.parse(_baseUrl.text.trim());

  Future<ApiResult> _register() {
    return _client.postJson(
      _base(),
      '/auth/register',
      _body({
        'username': _username.text.trim(),
        'password': _password.text,
        'email': _email.text.trim(),
      }),
    );
  }

  Future<ApiResult> _login() {
    return _client.postJson(
      _base(),
      '/auth/login',
      _body({'username': _username.text.trim(), 'password': _password.text}),
    );
  }

  Future<ApiResult> _me() {
    return _client.getJson(
      _base(),
      '/auth/me',
      bearerToken: _mode == AuthMode.body ? _accessToken : null,
    );
  }

  Future<ApiResult> _refresh() {
    return _client.postJson(
      _base(),
      '/auth/refresh',
      _body({if (_mode == AuthMode.body) 'refreshToken': _refreshToken ?? ''}),
    );
  }

  Future<ApiResult> _logout() async {
    final result = await _client.postJson(_base(), '/auth/logout', const {});
    _accessToken = null;
    _refreshToken = null;
    return result;
  }

  Future<ApiResult> _resendEmail() {
    return _client.postJson(
      _base(),
      '/auth/email/verification/resend',
      const {},
      bearerToken: _mode == AuthMode.body ? _accessToken : null,
    );
  }

  Future<ApiResult> _verifyEmail() {
    return _client.postJson(
      _base(),
      '/auth/email/verify',
      {'code': _verificationCode.text.trim()},
      bearerToken: _mode == AuthMode.body ? _accessToken : null,
    );
  }

  Future<ApiResult> _changeEmail() {
    return _client.postJson(
      _base(),
      '/auth/email/change',
      {'email': _newEmail.text.trim()},
      bearerToken: _mode == AuthMode.body ? _accessToken : null,
    );
  }

  Future<ApiResult> _startPasswordReset() {
    return _client.postJson(_base(), '/auth/password/reset/start', {
      'email': _resetEmail.text.trim(),
    });
  }

  Future<ApiResult> _finishPasswordReset() {
    return _client.postJson(_base(), '/auth/password/reset/finish', {
      'email': _resetEmail.text.trim(),
      'code': _resetCode.text.trim(),
      'newPassword': _newPassword.text,
    });
  }

  Future<ApiResult> _changePassword() {
    return _client.postJson(
      _base(),
      '/auth/password/change',
      {'currentPassword': _password.text, 'newPassword': _newPassword.text},
      bearerToken: _mode == AuthMode.body ? _accessToken : null,
    );
  }

  Future<ApiResult> _oauthLogin() {
    return _client.postJson(
      _base(),
      '/auth/oauth/login',
      _body({
        'provider': _oauthProvider,
        'code': _oauthCode.text.trim(),
        'redirectUri': _oauthRedirectUri.text.trim(),
        if (_oauthCodeVerifier.text.trim().isNotEmpty)
          'codeVerifier': _oauthCodeVerifier.text.trim(),
      }),
    );
  }

  Map<String, dynamic> _body(Map<String, dynamic> value) {
    return {...value, if (_mode == AuthMode.body) 'tokenTransport': 'body'};
  }

  void _storeTokens(Map<String, dynamic> body) {
    final accessToken = body['accessToken'];
    final refreshToken = body['refreshToken'];
    if (accessToken is String && accessToken.isNotEmpty) {
      _accessToken = accessToken;
    }
    if (refreshToken is String && refreshToken.isNotEmpty) {
      _refreshToken = refreshToken;
    }
  }
}

class AuthApiClient {
  AuthApiClient() : _client = createAuthHttpClient();

  final http.Client _client;

  Future<ApiResult> getJson(Uri baseUrl, String path, {String? bearerToken}) {
    return _send('GET', baseUrl.resolve(path), bearerToken: bearerToken);
  }

  Future<ApiResult> postJson(
    Uri baseUrl,
    String path,
    Map<String, dynamic> body, {
    String? bearerToken,
  }) {
    return _send(
      'POST',
      baseUrl.resolve(path),
      body: body,
      bearerToken: bearerToken,
    );
  }

  void close() => _client.close();

  Future<ApiResult> _send(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
    String? bearerToken,
  }) async {
    final request = http.Request(method, uri);
    request.headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    if (bearerToken != null && bearerToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $bearerToken';
    }

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    return ApiResult(
      statusCode: response.statusCode,
      headers: response.headers,
      body: decoded,
    );
  }
}

class ApiResult {
  const ApiResult({
    this.action,
    required this.statusCode,
    required this.headers,
    required this.body,
  });

  final String? action;
  final int statusCode;
  final Map<String, String> headers;
  final Map<String, dynamic> body;

  bool get ok => statusCode >= 200 && statusCode < 300;
  String get statusLabel => statusCode == 0 ? 'error' : '$statusCode';

  ApiResult copyWith({String? action}) {
    return ApiResult(
      action: action ?? this.action,
      statusCode: statusCode,
      headers: headers,
      body: body,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (action != null) 'action': action,
      'statusCode': statusCode,
      'headers': headers,
      'body': {
        for (final entry in body.entries)
          entry.key: _sensitiveKeys.contains(entry.key)
              ? '<redacted>'
              : entry.value,
      },
    };
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.good});

  final String label;
  final bool good;

  @override
  Widget build(BuildContext context) {
    final color = good ? const Color(0xFF0F766E) : const Color(0xFFB42318);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.08),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

enum AuthMode { cookie, body }

const _sensitiveKeys = {
  'accessToken',
  'refreshToken',
  'token',
  'code',
  'password',
  'newPassword',
  'currentPassword',
};

String _defaultUsername() {
  return 'auth_test_${DateTime.now().millisecondsSinceEpoch}';
}
