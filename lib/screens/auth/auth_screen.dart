import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../services/cloud_firestore_sync_service.dart';
import '../../services/backend_service.dart';
import '../main_navigation_holder.dart';

class AuthScreen extends StatefulWidget {
  final bool initialIsLogin;
  final bool isMandatory;

  const AuthScreen({
    super.key,
    this.initialIsLogin = true,
    this.isMandatory = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _phoneRegex = RegExp(r'^\d{10}$');

  late bool _isLogin; // Toggle between Login and Register
  bool _usePhoneAuth = false; // Toggle between Email & Phone OTP
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _otpSent = false;
  bool _isLoading = false;

  String? _verificationId;
  int? _resendToken;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {Color backgroundColor = AppTheme.error}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  String _mapFirebaseAuthError(FirebaseAuthException e, {String fallback = 'Authentication failed. Please try again.'}) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email. Please register first.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please verify and try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network and retry.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled right now. Please try Email Sign-In.';
      case 'invalid-phone-number':
        return 'Invalid 10-digit mobile number. Please check and retry.';
      case 'invalid-verification-code':
        return 'Incorrect OTP code. Please check the SMS and try again.';
      case 'session-expired':
        return 'OTP expired. Please request a fresh OTP.';
      case 'quota-exceeded':
        return 'SMS quota temporarily exceeded. Please try Email or Google Sign-In.';
      case 'app-not-authorized':
      case 'missing-client-identifier':
        return 'Phone verification is not authorized for this build. Please use Email or Google Sign-In.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      default:
        return e.message ?? '$fallback (${e.code})';
    }
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _completeAuthSuccess({
    required User user,
    required String displayName,
    required String email,
    required String phone,
    required String userRole,
    required bool isNewUser,
  }) async {
    if (!mounted) return;
    setState(() => _isLoading = false);

    final provider = context.read<AppStateProvider>();
    await provider.setLoggedInUser(
      name: displayName,
      email: email,
      uid: user.uid,
      role: userRole,
      phone: phone,
      isNewUser: isNewUser,
    );
    provider.setAdminStudentPreview(false);

    if (!mounted) return;

    final String successMsg = userRole == 'admin'
        ? '👑 Admin authenticated! Opening Admin Control Center...'
        : (isNewUser
            ? 'Account registered successfully! Unlimited access unlocked.'
            : 'Welcome back, $displayName!');

    _showSnack(
      successMsg,
      backgroundColor: userRole == 'admin' ? AppTheme.gold : const Color(0xFF10B981),
    );

    if (userRole == 'admin' || !Navigator.canPop(context)) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationHolder()),
        (route) => false,
      );
    } else {
      Navigator.pop(context, true);
    }
  }

  Future<void> _handleSubmit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    if (_usePhoneAuth) {
      if (!_otpSent) {
        await _sendOtp();
        return;
      }
      await _verifyOtpAndSignIn();
      return;
    }

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (!_isLogin && password != _confirmPasswordController.text) {
      _showSnack('Passwords do not match. Please verify.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final UserCredential cred;
      final bool isNewUser = !_isLogin;

      if (_isLogin) {
        cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      final user = cred.user;
      if (user == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnack('Authentication did not return a valid user. Please try again.');
        return;
      }

      final fallbackName = email.split('@').first.isNotEmpty ? email.split('@').first : 'Aspirant';
      String displayName;
      if (isNewUser && _nameController.text.trim().isNotEmpty) {
        displayName = _nameController.text.trim();
        try {
          await user.updateDisplayName(displayName);
        } catch (_) {}
      } else {
        displayName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : fallbackName;
      }

      final String verifiedEmail = (user.email != null && user.email!.trim().isNotEmpty)
          ? user.email!.trim().toLowerCase()
          : email;

      // Never allow self-registration to claim admin; verify role from Firestore on sign-in.
      final String userRole = isNewUser
          ? 'student'
          : await CloudFirestoreSyncService().fetchUserRoleFromCloud(user.uid, verifiedEmail);

      await CloudFirestoreSyncService().saveUserProfile(
        uid: user.uid,
        name: displayName,
        email: verifiedEmail,
        role: userRole,
        isNewUser: isNewUser,
      );

      if (isNewUser) {
        await BackendService().syncUserProgressToLeaderboard(
          userName: displayName,
          score: 0,
          accuracy: 0.0,
          streak: 0,
          userUid: user.uid,
          targetExam: 'SSC CGL',
          questionsSolved: 0,
        );
      }

      await _completeAuthSuccess(
        user: user,
        displayName: displayName,
        email: verifiedEmail,
        phone: user.phoneNumber ?? '',
        userRole: userRole,
        isNewUser: isNewUser,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack(_mapFirebaseAuthError(e));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Unable to sign in right now. Please check your connection and try again.');
      debugPrint('Email auth error: $e');
    }
  }

  Future<void> _sendOtp({bool isResend = false}) async {
    if (_isLoading) return;
    final phone = _phoneController.text.trim();
    if (!_phoneRegex.hasMatch(phone)) {
      _showSnack('Please enter a valid 10-digit mobile number.');
      return;
    }
    if (!_isLogin && _nameController.text.trim().isEmpty) {
      _showSnack('Please enter your full name.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$phone',
        forceResendingToken: isResend ? _resendToken : null,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithPhoneCredential(credential, phone);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showSnack(_mapFirebaseAuthError(e, fallback: 'Failed to send OTP'));
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _otpSent = true;
            _isLoading = false;
          });
          _startResendCountdown();
          _showSnack(
            'OTP sent to +91 $phone. Please check your SMS messages.',
            backgroundColor: const Color(0xFF10B981),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack(_mapFirebaseAuthError(e, fallback: 'Failed to start phone verification'));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Unable to send OTP right now. Please try again.');
      debugPrint('Phone verify error: $e');
    }
  }

  Future<void> _verifyOtpAndSignIn() async {
    final otp = _otpController.text.trim();
    final phone = _phoneController.text.trim();

    if (otp.length != 6) {
      _showSnack('Please enter the 6-digit OTP.');
      return;
    }
    if (_verificationId == null || _verificationId!.isEmpty) {
      _showSnack('OTP session expired. Please request a new OTP.');
      setState(() => _otpSent = false);
      return;
    }

    setState(() => _isLoading = true);
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    await _signInWithPhoneCredential(credential, phone);
  }

  Future<void> _signInWithPhoneCredential(PhoneAuthCredential credential, String phone) async {
    try {
      final cred = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = cred.user;
      if (user == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnack('OTP verification did not return a valid user.');
        return;
      }

      final bool isNewUser = cred.additionalUserInfo?.isNewUser ?? !_isLogin;
      final String formattedPhone = user.phoneNumber ?? '+91$phone';
      String displayName = _nameController.text.trim();
      if (displayName.isNotEmpty) {
        try {
          await user.updateDisplayName(displayName);
        } catch (_) {}
      } else if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
        displayName = user.displayName!.trim();
      } else {
        displayName = 'Aspirant ${phone.length >= 4 ? phone.substring(phone.length - 4) : phone}';
      }

      final String userRole = isNewUser
          ? 'student'
          : await CloudFirestoreSyncService().fetchUserRoleFromCloud(user.uid, user.email ?? '');

      await CloudFirestoreSyncService().saveUserProfile(
        uid: user.uid,
        name: displayName,
        email: user.email ?? '',
        phone: formattedPhone,
        role: userRole,
        isNewUser: isNewUser,
      );

      if (isNewUser) {
        await BackendService().syncUserProgressToLeaderboard(
          userName: displayName,
          score: 0,
          accuracy: 0.0,
          streak: 0,
          userUid: user.uid,
          targetExam: 'SSC CGL',
          questionsSolved: 0,
        );
      }

      await _completeAuthSuccess(
        user: user,
        displayName: displayName,
        email: user.email ?? '',
        phone: formattedPhone,
        userRole: userRole,
        isNewUser: isNewUser,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack(_mapFirebaseAuthError(e, fallback: 'OTP verification failed'));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('OTP sign-in failed. Please try again.');
      debugPrint('Phone credential sign-in error: $e');
    }
  }

  void _handleForgotPassword() {
    final resetEmailController = TextEditingController(text: _emailController.text.trim());
    bool isSending = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF13192B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: AppTheme.accent),
              SizedBox(width: 8),
              Text('Reset Password', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your registered email address to receive a secure password reset link.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !isSending,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'student@example.com',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.white60),
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSending
                  ? null
                  : () async {
                      final email = resetEmailController.text.trim().toLowerCase();
                      if (!_emailRegex.hasMatch(email)) {
                        _showSnack('Please enter a valid email address.');
                        return;
                      }
                      setDialogState(() => isSending = true);
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                        if (ctx.mounted) Navigator.pop(ctx);
                        _showSnack(
                          '📧 Password reset link sent! Please check your inbox and spam folder.',
                          backgroundColor: const Color(0xFF10B981),
                        );
                      } on FirebaseAuthException catch (e) {
                        setDialogState(() => isSending = false);
                        _showSnack(_mapFirebaseAuthError(e, fallback: 'Failed to send reset email'));
                      } catch (e) {
                        setDialogState(() => isSending = false);
                        _showSnack('Could not send reset email. Please check your internet connection.');
                        debugPrint('Reset email error: $e');
                      }
                    },
              child: isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Send Reset Link', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ).whenComplete(resetEmailController.dispose);
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final googleProvider = GoogleAuthProvider()
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'});

      final cred = await FirebaseAuth.instance.signInWithProvider(googleProvider);
      final user = cred.user;
      if (user == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnack('Google Sign-In did not return a valid account.');
        return;
      }

      final bool isNewUser = cred.additionalUserInfo?.isNewUser ?? false;
      final String email = (user.email ?? '').trim().toLowerCase();
      final String name = (user.displayName != null && user.displayName!.trim().isNotEmpty)
          ? user.displayName!.trim()
          : (email.isNotEmpty ? email.split('@').first : 'Aspirant');

      final String userRole = isNewUser
          ? 'student'
          : await CloudFirestoreSyncService().fetchUserRoleFromCloud(user.uid, email);

      await CloudFirestoreSyncService().saveUserProfile(
        uid: user.uid,
        name: name,
        email: email,
        phone: user.phoneNumber ?? '',
        role: userRole,
        isNewUser: isNewUser,
      );

      if (isNewUser) {
        await BackendService().syncUserProgressToLeaderboard(
          userName: name,
          score: 0,
          accuracy: 0.0,
          streak: 0,
          userUid: user.uid,
          targetExam: 'SSC CGL',
          questionsSolved: 0,
        );
      }

      await _completeAuthSuccess(
        user: user,
        displayName: name,
        email: email,
        phone: user.phoneNumber ?? '',
        userRole: userRole,
        isNewUser: isNewUser,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (e.code == 'canceled' || e.code == 'popup-closed-by-user' || e.code == 'web-context-canceled') {
        _showSnack('Google Sign-In was cancelled.', backgroundColor: AppTheme.surfaceElevated);
      } else {
        _showSnack(_mapFirebaseAuthError(e, fallback: 'Google Sign-In failed'));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Google Sign-In failed. Please try Email Sign-In.');
      debugPrint('Google Sign-In error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AppStateProvider>().isLoggedIn;
    final bool blockPop = widget.isMandatory && !isLoggedIn;

    return PopScope(
      canPop: !blockPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && blockPop) {
          _showSnack(
            '⚠️ Free 3-question preview completed! Register your free account to continue practicing.',
            backgroundColor: const Color(0xFFBE123C),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.bgDark,
        appBar: AppBar(
          title: Text(_isLogin ? 'Sign In' : 'Create Account'),
          automaticallyImplyLeading: !blockPop,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Free Trial Limit Banner (when navigated after 3 questions)
                  if (widget.isMandatory) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE11D48).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_clock_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '3 Free Questions Preview Done!',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.5),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Register your free account now to practice unlimited, preserve your streak, and track calculation speed.',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Top Brand Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flash_on_rounded, size: 48, color: AppTheme.gold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _isLogin ? 'Welcome Back!' : 'Start Speed Practice',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      _isLogin
                          ? 'Sign in to sync your score, streak, and mistakes across devices'
                          : 'Join thousands of SSC, Banking & CAT aspirants',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Method Selector (Email vs Phone OTP)
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () => setState(() {
                                      _usePhoneAuth = false;
                                      _otpSent = false;
                                      _verificationId = null;
                                    }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_usePhoneAuth ? AppTheme.primaryLight : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Email ID',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !_usePhoneAuth ? Colors.white : Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () => setState(() {
                                      _usePhoneAuth = true;
                                    }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _usePhoneAuth ? AppTheme.primaryLight : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Mobile OTP',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _usePhoneAuth ? Colors.white : Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Full Name (Only on Registration)
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _nameController,
                      enabled: !_isLoading,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.white60),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Input fields based on Email or Phone OTP
                  if (!_usePhoneAuth) ...[
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.white60),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (v) {
                        final trimmed = v?.trim() ?? '';
                        if (trimmed.isEmpty) return 'Please enter your email';
                        if (!_emailRegex.hasMatch(trimmed)) return 'Enter a valid email address';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isLoading,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white60),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white60),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter your password';
                        if (!_isLogin && v.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),

                    // Forgot Password Button (Only in Login mode)
                    if (_isLogin) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading ? null : _handleForgotPassword,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ],

                    // Confirm Password Field (Only in Register mode)
                    if (!_isLogin) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmPasswordController,
                        enabled: !_isLoading,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_clock_outlined, color: Colors.white60),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white60),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          filled: true,
                          fillColor: AppTheme.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please confirm your password';
                          if (v != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                  ] else ...[
                    // Phone Number Field
                    TextFormField(
                      controller: _phoneController,
                      enabled: !_isLoading && !_otpSent,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        labelText: '10-Digit Mobile Number',
                        prefixText: '+91 ',
                        prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        prefixIcon: const Icon(Icons.phone_outlined, color: Colors.white60),
                        suffixIcon: _otpSent
                            ? TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => setState(() {
                                          _otpSent = false;
                                          _verificationId = null;
                                          _otpController.clear();
                                        }),
                                child: const Text('Change', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                              )
                            : TextButton(
                                onPressed: _isLoading ? null : () => _sendOtp(),
                                child: const Text('Send OTP', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                              ),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (v) => !_phoneRegex.hasMatch((v ?? '').trim()) ? 'Enter valid 10-digit mobile number' : null,
                    ),
                    const SizedBox(height: 14),

                    // OTP field (if OTP sent)
                    if (_otpSent) ...[
                      TextFormField(
                        controller: _otpController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Enter 6-Digit OTP',
                          prefixIcon: const Icon(Icons.pin_outlined, color: Colors.white60),
                          filled: true,
                          fillColor: AppTheme.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (v) => (v == null || v.trim().length != 6) ? 'Enter 6-digit OTP' : null,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: (_isLoading || _resendSeconds > 0) ? null : () => _sendOtp(isResend: true),
                          child: Text(
                            _resendSeconds > 0 ? 'Resend OTP in ${_resendSeconds}s' : 'Resend OTP',
                            style: TextStyle(
                              color: _resendSeconds > 0 ? Colors.white38 : AppTheme.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 24),

                  // Main Submit Button (Login / Register / Send OTP / Verify OTP)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryLight,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isLoading ? null : _handleSubmit,
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(
                            _usePhoneAuth
                                ? (_otpSent ? 'Verify OTP & Continue' : 'Send OTP')
                                : (_isLogin ? 'Sign In' : 'Create Account'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Divider Or
                  Row(
                    children: const [
                      Expanded(child: Divider(color: AppTheme.surfaceLight)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Divider(color: AppTheme.surfaceLight)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Google Sign In Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppTheme.surfaceLight),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: Colors.redAccent),
                    label: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w600)),
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                  ),

                  const SizedBox(height: 24),

                  // Toggle Login / Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin ? "Don't have an account? " : "Already have an account? ",
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () => setState(() {
                                  _isLogin = !_isLogin;
                                  _otpSent = false;
                                  _verificationId = null;
                                  _otpController.clear();
                                }),
                        child: Text(
                          _isLogin ? 'Register Now' : 'Sign In',
                          style: const TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
