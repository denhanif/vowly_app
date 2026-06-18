// (Bagian Import dan Build tetap sama, hanya ubah fungsi _login di bawah ini)
// ...
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; 

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email dan Kata Sandi tidak boleh kosong!'), backgroundColor: Colors.red));
      return;
    }
    setState(() { _isLoading = true; });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
      
      if (mounted) {
        if (userDoc.exists && (userDoc.data() as Map<String, dynamic>).containsKey('role')) {
          String userRole = (userDoc.data() as Map<String, dynamic>)['role'];
          
          // --- LOGIKA PINTU MASUK LOGIN ---
          if (userRole == 'vendor') {
            Navigator.pushReplacementNamed(context, '/vendor_main');
          } else {
            Navigator.pushReplacementNamed(context, '/main');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/role_selection');
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Terjadi kesalahan saat masuk.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') errorMessage = 'Email atau Kata Sandi salah.';
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );                                                                         
        } finally {
          if (mounted) setState(() { _isLoading = false; });
        }
      }

  // ... (Kode _build dan lain-lain di bawah ini biarkan sama persis seperti kode login Anda sebelumnya)
  @override
  void dispose() { _emailController.dispose(); _passwordController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text('Selamat Datang', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const Text('Masuk untuk melanjutkan', textAlign: TextAlign.center),
              const SizedBox(height: 40),
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(hintText: 'Email', filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(hintText: 'Kata Sandi', filled: true, fillColor: Colors.grey[200], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Lupa Kata Sandi?', style: TextStyle(color: Colors.black54)))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: _isLoading ? null : _login,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Masuk', style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),
              const Row(children: [Expanded(child: Divider(color: Colors.black45)), Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('atau masuk dengan')), Expanded(child: Divider(color: Colors.black45))]),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 30), label: const Text('Google', style: TextStyle(color: Colors.black)))),
                  const SizedBox(width: 16),
                  Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.email, color: Colors.black), label: const Text('Email', style: TextStyle(color: Colors.black)))),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun? '),
                  GestureDetector(onTap: () => Navigator.pushNamed(context, '/register'), child: const Text('Daftar', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}