import 'package:flutter/material.dart';
import '../utils/colors.dart';

class VendorAgreementScreen extends StatefulWidget {
  const VendorAgreementScreen({super.key});

  @override
  State<VendorAgreementScreen> createState() => _VendorAgreementScreenState();
}

class _VendorAgreementScreenState extends State<VendorAgreementScreen> {
  bool _agreeGeneral = false;
  bool _agreeCommission = false;
  bool _agreeDispute = false;

  bool get _canSubmit => _agreeGeneral && _agreeCommission && _agreeDispute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Perjanjian Vendor', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan Perjanjian
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFDE8EE), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.handshake_outlined, color: AppColors.primaryPink, size: 20),
                      SizedBox(width: 8),
                      Text('Ringkasan Perjanjian', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.black12),
                  _buildRow('Komisi platform', '3% per transaksi'),
                  _buildRow('Pencairan dana', 'H+3 pasca acara selesai'),
                  _buildRow('Metode pencairan', 'Transfer bank ke rekening terdaftar'),
                  _buildRow('Minimal pencairan', 'Rp 100.000'),
                  _buildRow('Penalti pembatalan', '5% dari nilai transaksi'),
                  _buildRow('Dispute window', '3x24 jam pasca acara'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Simulasi Komisi
            const Text('Simulasi Komisi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildSimulasiRow('Nilai transaksi', 'Rp 5.000.000', Colors.black87),
            _buildSimulasiRow('Komisi Vowly (3%)', 'Rp 150.000', Colors.red),
            const Divider(),
            _buildSimulasiRow('Yang Anda terima', 'Rp 4.850.000', Colors.green, isBold: true),
            const SizedBox(height: 24),

            // Syarat & Ketentuan
            const Text('Syarat & Ketentuan Lengkap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
              child: const SingleChildScrollView(
                child: Text(
                  '1. Definisi & Ruang Lingkup\nPerjanjian ini berlaku antara Vendor ("Mitra") dan PT Vowly Indonesia ("Platform")...\n\n2. Komisi & Pembayaran\nPlatform memungut komisi sebesar 3% dari total nilai transaksi...\n\n3. Verifikasi & Akun\nVendor wajib memberikan dokumen legalitas yang valid...\n\n4. Kewajiban Vendor\nVendor wajib menyelesaikan pesanan sesuai kesepakatan...',
                  style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Checkboxes
            const Text('Persetujuan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _buildCheckbox(
              value: _agreeGeneral,
              onChanged: (v) => setState(() => _agreeGeneral = v ?? false),
              text: 'Saya telah membaca dan menyetujui Syarat & Ketentuan serta Kebijakan Privasi Vowly',
            ),
            _buildCheckbox(
              value: _agreeCommission,
              onChanged: (v) => setState(() => _agreeCommission = v ?? false),
              text: 'Saya menyetujui pemotongan komisi sebesar 3% dari setiap transaksi yang berhasil diselesaikan',
            ),
            _buildCheckbox(
              value: _agreeDispute,
              onChanged: (v) => setState(() => _agreeDispute = v ?? false),
              text: 'Saya menyetujui ketentuan pencairan dana, kebijakan pembatalan, dan mekanisme dispute Vowly',
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _canSubmit ? () => Navigator.pop(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: const Text('Simpan Persetujuan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSimulasiRow(String label, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: isBold ? Colors.black : Colors.black54, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 14, color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCheckbox({required bool value, required ValueChanged<bool?> onChanged, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 24, height: 24, child: Checkbox(value: value, onChanged: onChanged, activeColor: AppColors.primaryPink)),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.5))),
      ],
    );
  }
}