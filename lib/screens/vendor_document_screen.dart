import 'package:flutter/material.dart';
import '../utils/colors.dart';

class VendorDocumentScreen extends StatefulWidget {
  const VendorDocumentScreen({super.key});

  @override
  State<VendorDocumentScreen> createState() => _VendorDocumentScreenState();
}

class _VendorDocumentScreenState extends State<VendorDocumentScreen> {
  // Status simulasi upload
  bool isNibUploaded = false;
  bool isPortoUploaded = false;

  void _simulateUpload(String type) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sedang mengunggah file...')));
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          if (type == 'NIB') isNibUploaded = true;
          if (type == 'PORTO') isPortoUploaded = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dokumen berhasil diunggah!'), backgroundColor: Colors.green));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Dokumen Usaha', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload dokumen legalitas bisnis Anda. Semua dokumen dijaga kerahasiaannya dan hanya digunakan untuk verifikasi.', style: TextStyle(color: Colors.black54, height: 1.5)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade100)),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('Format diterima: PDF, JPG, PNG. Ukuran maksimum 5MB per file.', style: TextStyle(color: Colors.blue, fontSize: 12))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            _buildUploadedFileCard('KTP PEMILIK USAHA *', 'ktp_pemilik.jpg', '1.2 MB'),
            _buildUploadedFileCard('NPWP *', 'npwp_usaha.pdf', '0.8 MB'),
            
            const SizedBox(height: 8),
            const Text('NIB / SIUP / TDP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            isNibUploaded 
              ? _buildUploadedFileCard('', 'izin_usaha_nib.pdf', '2.1 MB')
              : _buildUploadButton('Upload Dokumen Izin Usaha', 'NIB dari OSS, SIUP, atau TDP', () => _simulateUpload('NIB')),
            
            const SizedBox(height: 20),
            const Text('FOTO PORTOFOLIO (OPSIONAL)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            isPortoUploaded 
              ? _buildUploadedFileCard('', 'portofolio_lengkap.zip', '4.5 MB')
              : _buildUploadButton('Upload Portofolio', 'Maks. 10 foto, JPG/PNG, tampilkan karya terbaik', () => _simulateUpload('PORTO')),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedFileCard(String label, String fileName, String fileSize) {
    return Padding(
      padding: EdgeInsets.only(bottom: label.isEmpty ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file, color: Colors.redAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(fileSize, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: const Color(0xFFFDE8EE), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primaryPink, style: BorderStyle.solid, width: 1)),
        child: Column(
          children: [
            const Icon(Icons.upload_file, color: AppColors.primaryPink),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: AppColors.primaryPink, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}