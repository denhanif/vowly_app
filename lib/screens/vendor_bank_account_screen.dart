import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';

class VendorBankAccountScreen extends StatefulWidget {
  const VendorBankAccountScreen({super.key});

  @override
  State<VendorBankAccountScreen> createState() => _VendorBankAccountScreenState();
}

class _VendorBankAccountScreenState extends State<VendorBankAccountScreen> {
  Map<String, dynamic>? bankAccount;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBankAccount();
  }

  Future<void> loadBankAccount() async {
    setState(() => isLoading = true);
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists && (userDoc.data() as Map<String, dynamic>).containsKey('bankAccount')) {
          setState(() {
            bankAccount = (userDoc.data() as Map<String, dynamic>)['bankAccount'];
          });
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // --- FUNGSI MUNCULKAN POPUP EDIT REKENING ---
  Future<void> _showEditDialog() async {
    TextEditingController bankController = TextEditingController(text: bankAccount?['bankName']);
    TextEditingController numberController = TextEditingController(text: bankAccount?['accountNumber']);
    TextEditingController holderController = TextEditingController(text: bankAccount?['accountHolder']);

    await showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Ubah Rekening', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: bankController, decoration: const InputDecoration(labelText: 'Nama Bank (mis. BCA)')),
            const SizedBox(height: 8),
            TextField(controller: numberController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nomor Rekening')),
            const SizedBox(height: 8),
            TextField(controller: holderController, decoration: const InputDecoration(labelText: 'Nama Pemilik Rekening')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.black54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink),
            onPressed: () async {
              if (bankController.text.isEmpty || numberController.text.isEmpty || holderController.text.isEmpty) return;
              
              final User? currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null) {
                // Menyimpan data ke Firestore
                await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
                  'bankAccount': {
                    'bankName': bankController.text.trim(),
                    'accountNumber': numberController.text.trim(),
                    'accountHolder': holderController.text.trim(),
                  }
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rekening berhasil disimpan!'), backgroundColor: Colors.green));
                }
                loadBankAccount(); // Muat ulang layar
              }
            }, 
            child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Rekening Bank', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [Icon(Icons.account_balance, color: AppColors.primaryPink), SizedBox(width: 8), Text('Rekening Pencairan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))]),
                        const SizedBox(height: 20),
                        const Text('Bank', style: TextStyle(color: Colors.black54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(bankAccount?['bankName'] ?? 'Belum diatur', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        const Text('Nomor Rekening', style: TextStyle(color: Colors.black54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(bankAccount?['accountNumber'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        const Text('Nama Pemilik', style: TextStyle(color: Colors.black54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(bankAccount?['accountHolder'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: _showEditDialog, // Panggil fungsi form edit
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('Ubah Rekening', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}