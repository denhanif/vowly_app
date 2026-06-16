import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  // Email dibiarkan statis/read-only karena mengubah email di Firebase Auth butuh verifikasi khusus
  String _userEmail = ''; 
  
  bool _isLoading = true; // Untuk memuat data awal
  bool _isSaving = false; // Untuk indikator tombol simpan

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Mengambil data dari Firebase saat halaman dibuka
  Future<void> _loadUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _userEmail = currentUser.email ?? '';
      
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = data['name'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _locationController.text = data['location'] ?? ''; // Jika belum ada, akan kosong
          });
        }
      } catch (e) {
        debugPrint("Error memuat data: $e");
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Menyimpan data baru ke Firebase
  Future<void> _saveProfile() async {
    setState(() { _isSaving = true; });
    
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'location': _locationController.text.trim(),
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green)
          );
          // Kembali ke halaman profil sebelumnya
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan profil.'), backgroundColor: Colors.red)
          );
        }
      }
    }
    
    setState(() { _isSaving = false; });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      const CircleAvatar(radius: 50, backgroundColor: AppColors.primaryPink, child: Icon(Icons.person, size: 50, color: Colors.white)),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.white, 
                          radius: 18, 
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFFE56B8B), 
                            radius: 16, 
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 14, color: Colors.white), 
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur ubah foto segera hadir!')));
                              }, 
                              padding: EdgeInsets.zero
                            )
                          )
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                _buildTextField('Nama Lengkap', _nameController),
                
                // Email menggunakan container karena tidak bisa diubah langsung (Read-Only)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300, // Warna abu-abu lebih gelap menandakan tidak bisa diedit
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text(_userEmail, style: const TextStyle(color: Colors.black54)),
                      ),
                    ],
                  ),
                ),
                
                _buildTextField('No. Hp', _phoneController),
                _buildTextField('Lokasi / Kota', _locationController),
                
                const SizedBox(height: 40),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE56B8B),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}