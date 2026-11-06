import 'package:flutter/material.dart';

import '../core/home_store.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, this.splash = false});
  final bool splash;
  @override
  Widget build(BuildContext context) => splash
      ? Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1C1C1E)
              : Colors.white,
          body: Center(
            child: InkWell(
              onTap: () => root(context, '/welcome'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.png', width: 72, height: 72),
                  const SizedBox(height: 20),
                  const Text(
                    'SuperSemart',
                    style: TextStyle(
                      color: blue,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      : Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/onboarding.png', fit: BoxFit.cover),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x334A70B3),
                      Colors.transparent,
                      Color(0x33132253),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'SuperSemart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(flex: 2),
                      const Text(
                        'Welcome',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Your key to a smarter and more\nconvenient home!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.8,
                        ),
                      ),
                      const Spacer(flex: 5),
                      Center(
                        child: SizedBox(
                          width: 180,
                          child: FilledButton(
                            onPressed: () => go(context, '/sign-up'),
                            child: const Text('Get Started'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            final s = HomeScope.of(context);
                            s.signedIn = true;
                            s.changed();
                            root(context, '/home');
                          },
                          child: const Text(
                            'Explore demo',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.mode});
  final String mode;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController(),
      confirm = TextEditingController(),
      code = TextEditingController();
  bool visible = false;
  @override
  void dispose() {
    for (final c in [name, email, password, confirm, code]) {
      c.dispose();
    }
    super.dispose();
  }

  String? requiredText(String? v) =>
      v == null || v.trim().isEmpty ? 'This field is required' : null;
  String? validEmail(String? v) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v ?? '')
      ? null
      : 'Enter a valid email address';
  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    final signUp = mode == 'sign-up',
        signIn = mode == 'sign-in',
        verify = mode == 'verify';
    final title = signUp
        ? 'Create account'
        : signIn
        ? 'Hi, Welcome Back! 👋'
        : verify
        ? 'Verify Code'
        : mode == 'forgot'
        ? 'Forgot Password'
        : 'Reset Password';
    final subtitle = signUp || signIn
        ? 'We are happy to see you again. ${signUp ? 'Sign Up' : 'Sign In'}\nto your account'
        : verify
        ? 'Please enter the code we just sent to\n${HomeScope.of(context).email}'
        : mode == 'forgot'
        ? 'Enter your email, we will send a\nverification code to your email'
        : 'Your password must be at least 8 characters\nand include letters and numbers.';
    Future<void> submit() async {
      if (!form.currentState!.validate()) return;
      final s = HomeScope.of(context);
      if (signUp || signIn) {
        s.email = email.text.trim();
        if (signUp) s.owner = name.text.trim();
        s.signedIn = signIn;
        await s.changed();
        if (context.mounted) {
          if (signUp) {
            showTerms(context);
          } else {
            root(context, '/home');
          }
        }
      } else if (mode == 'forgot') {
        s.email = email.text.trim();
        await s.changed();
        if (context.mounted) go(context, '/verify');
      } else if (verify) {
        if (context.mounted) go(context, '/reset');
      } else {
        if (context.mounted) {
          toast(context, 'Demo password reset complete. Sign in to continue.');
          root(context, '/sign-in');
        }
      }
    }

    return PageFrame(
      title: signUp || signIn ? null : title,
      footer: signUp || signIn
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () =>
                      root(context, signUp ? '/sign-in' : '/sign-up'),
                  child: Text(
                    signUp
                        ? 'Already have an account? Log In'
                        : 'Don’t have an account? Sign Up',
                  ),
                ),
                const Text(
                  'By signing up you agree to our Terms\nand Conditions of Use',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: muted),
                ),
              ],
            )
          : null,
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (signUp || signIn) ...[
              const SizedBox(height: 30),
              Center(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Center(
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted, fontSize: 14),
              ),
            ),
            const SizedBox(height: 30),
            if (signUp || signIn) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => toast(
                        context,
                        'Google sign-in is not connected in this local demo. Use the email form or Explore demo.',
                      ),
                      child: const Text('G  Google'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => toast(
                        context,
                        'Apple sign-in is not connected in this local demo. Use the email form or Explore demo.',
                      ),
                      child: const Text('●  Apple'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Or continue with',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ),
              const SizedBox(height: 28),
            ],
            if (signUp)
              Field(
                'Full Name',
                controller: name,
                hint: 'Your name...',
                validator: requiredText,
              ),
            if (signUp || signIn || mode == 'forgot')
              Field(
                'Email',
                controller: email,
                hint: 'Email...',
                keyboard: TextInputType.emailAddress,
                validator: validEmail,
              ),
            if (signUp || signIn || mode == 'reset')
              Field(
                mode == 'reset' ? 'New Password' : 'Password',
                controller: password,
                hint: 'Password...',
                obscure: !visible,
                validator: (v) => (v ?? '').length < 8
                    ? 'Use at least 8 characters'
                    : mode == 'reset' &&
                          (!RegExp(r'[A-Za-z]').hasMatch(v!) ||
                              !RegExp(r'\d').hasMatch(v))
                    ? 'Include letters and numbers'
                    : null,
                suffix: IconButton(
                  tooltip: 'Show password',
                  onPressed: () => setState(() => visible = !visible),
                  icon: Icon(
                    visible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
              ),
            if (mode == 'reset')
              Field(
                'Confirm New Password',
                controller: confirm,
                obscure: !visible,
                hint: 'Password...',
                validator: (v) =>
                    v != password.text ? 'Passwords do not match' : null,
              ),
            if (verify) ...[
              const SizedBox(height: 32),
              Field(
                'Verification Code',
                controller: code,
                hint: 'Enter 1234 for demo',
                keyboard: TextInputType.number,
                validator: (v) => v != '1234' ? 'Demo code is 1234' : null,
              ),
              const Center(
                child: Text(
                  'Demo verification code: 1234',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: () =>
                    toast(context, 'Demo code: 1234. No email has been sent.'),
                child: const Text('Resend code'),
              ),
              const SizedBox(height: 28),
            ],
            if (signIn)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => go(context, '/forgot'),
                  child: const Text('Forgot Password?'),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: submit,
              child: Text(
                signUp
                    ? 'Create Account'
                    : signIn
                    ? 'Log In'
                    : mode == 'forgot'
                    ? 'Send'
                    : verify
                    ? 'Verify Code'
                    : 'Submit',
              ),
            ),
            if (signIn)
              TextButton(
                onPressed: () {
                  final s = HomeScope.of(context);
                  s.signedIn = true;
                  s.changed();
                  root(context, '/home');
                },
                child: const Text('Explore demo without an account'),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> showTerms(BuildContext context) => showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text('Terms of Service'),
    content: const Text(
      'I agree to the Terms of Service and Conditions of Use, including consent to electronic communications, and affirm that the information provided is my own.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: const Text('Disagree'),
      ),
      FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size(0, 46)),
        onPressed: () async {
          final s = HomeScope.of(context);
          s.signedIn = true;
          await s.changed();
          if (!ctx.mounted || !context.mounted) return;
          Navigator.pop(ctx);
          root(context, '/add-house');
        },
        child: const Text('Agree and Continue'),
      ),
    ],
  ),
);
