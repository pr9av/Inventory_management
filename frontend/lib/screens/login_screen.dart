import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart' as auth_config;
import 'package:http/http.dart' as http;
import '../main.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final auth_config.Config config = auth_config.Config(
    tenant: 'common', // Replace with your Tenant ID if strictly single-tenant
    clientId: '0cde56fa-1ae9-4e58-a23f-1df78dffe979', 
    scope: 'openid profile offline_access User.Read',
    redirectUri: kIsWeb 
        ? 'http://localhost:5173' 
        : 'msauth://com.example.frontend/uAjnB1SZZB2oraYMvM%2BT71AFJTw%3D', 
    navigatorKey: navigatorKey,
    webUseRedirect: false, // True if you want a full-page redirect instead of popup
  );
  
  final AadOAuth oauth = AadOAuth(config);
  bool _isLoading = false;

  Future<void> _handleMicrosoftSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Prompt user login popup/browser
      await oauth.login();
      final String? accessToken = await oauth.getAccessToken();

      if (accessToken != null) {
        await _authenticateWithBackend(accessToken);
      } else {
        _showError('No Access Token received from Microsoft.');
      }
    } catch (error) {
      _showError('Sign in failed: \n$error');
    } finally {
      setState(() {
        if(mounted) _isLoading = false;
      });
    }
  }

  Future<void> _authenticateWithBackend(String accessToken) async {
    // Call the live Render URL for global access
    const String apiUrl = 'https://inventory-management-p8tg.onrender.com/api/users/microsoft-login'; 
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accessToken': accessToken}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        _showError(data['message'] ?? 'Authentication failed');
        await oauth.logout();
      }
    } catch (e) {
      _showError('Error connecting to backend: $e');
      await oauth.logout();
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.jpg',
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Text(
                  'Inventory',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to manage your hardware',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 48),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    onPressed: _handleMicrosoftSignIn,
                    icon: const Icon(Icons.window, color: Colors.blueAccent), // Simple placeholder for Microsoft logo
                    label: Text(
                      'Sign in with Microsoft',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Company access only (@blauplug.com)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
