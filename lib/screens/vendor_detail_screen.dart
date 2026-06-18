import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import 'booking_screen.dart';
import 'chatclient_room_screen.dart'; // Import Halaman Chat Klien

class VendorDetailScreen extends StatefulWidget {
  final String? vendorId;
  final String? vendorName;

  const VendorDetailScreen({super.key, this.vendorId, this.vendorName});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isChatLoading = false;

  // Logika pembuatan jalur chat antara Klien dan Vendor
  Future<void> _startChat() async {
    if (widget.vendorId == null || currentUser == null) return;
    setState(() => _isChatLoading = true);

    try {
      // 1. Cek apakah sudah pernah nge-chat sebelumnya
      var chatQuery = await FirebaseFirestore.instance.collection('chats')
          .where('vendorId', isEqualTo: widget.vendorId)
          .where('customerId', isEqualTo: currentUser!.uid)
          .limit(1).get();

      String chatId;

      if (chatQuery.docs.isEmpty) {
        // Jika belum, ambil nama Klien lalu buat jalur chat baru
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
        String customerName = (userDoc.data() as Map<String, dynamic>)['name'] ?? 'Klien';

        var newChat = await FirebaseFirestore.instance.collection('chats').add({
          'vendorId': widget.vendorId,
          'vendorName': widget.vendorName ?? 'Vendor Vowly',
          'customerId': currentUser!.uid,
          'customerName': customerName,
          'lastMessage': 'Memulai percakapan...',
          'unreadVendor': 0,
          'unreadCustomer': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        chatId = newChat.id;
      } else {
        // Jika sudah ada, gunakan ID chat yang lama
        chatId = chatQuery.docs.first.id;
      }

      if (mounted) {
        setState(() => _isChatLoading = false);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatClientRoomScreen(
          chatId: chatId, vendorId: widget.vendorId!, vendorName: widget.vendorName ?? 'Vendor Vowly'
        )));
      }
    } catch (e) {
      if (mounted) setState(() => _isChatLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0, pinned: true, backgroundColor: AppColors.primaryPink,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.vendorName ?? 'Detail Vendor', style: const TextStyle(fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black54, blurRadius: 10)])),
              background: Container(color: Colors.grey.shade400, child: const Icon(Icons.store, size: 100, color: Colors.white)),
            ),
            leading: IconButton(icon: const CircleAvatar(backgroundColor: Colors.white54, child: Icon(Icons.arrow_back, color: Colors.black)), onPressed: () => Navigator.pop(context)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Daftar Layanan & Paket', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Icon(Icons.verified, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (widget.vendorId != null)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('packages').where('vendorId', isEqualTo: widget.vendorId).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('Vendor ini belum memiliki paket.', style: TextStyle(color: Colors.black54))));

                        return ListView.builder(
                          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var package = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                            String packageId = snapshot.data!.docs[index].id;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(package['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(height: 8),
                                    Text(package['description'] ?? '', style: const TextStyle(color: Colors.black54, height: 1.5)),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(currencyFormat.format(package['price'] ?? 0), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE56B8B), fontSize: 16)),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => BookingScreen(vendorId: widget.vendorId!, vendorName: widget.vendorName!, packageId: packageId, packageData: package)));
                                          },
                                          child: const Text('Pesan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    )
                ],
              ),
            ),
          ),
        ],
      ),
      // --- TOMBOL MENGAMBANG UNTUK CHAT VENDOR ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isChatLoading ? null : _startChat,
        backgroundColor: AppColors.primaryPink,
        icon: _isChatLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text('Chat Vendor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}