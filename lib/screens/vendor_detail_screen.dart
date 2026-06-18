import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import 'booking_screen.dart';
import 'chatclient_room_screen.dart';

class VendorDetailScreen extends StatefulWidget {
  final String vendorId;
  final String vendorName;

  const VendorDetailScreen({super.key, required this.vendorId, required this.vendorName});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isChatLoading = false;

  Future<void> _startChat() async {
    if (currentUser == null) return;
    setState(() => _isChatLoading = true);

    try {
      var chatQuery = await FirebaseFirestore.instance.collection('chats')
          .where('vendorId', isEqualTo: widget.vendorId)
          .where('customerId', isEqualTo: currentUser!.uid)
          .limit(1).get();

      String chatId;

      if (chatQuery.docs.isEmpty) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
        String customerName = (userDoc.data() as Map<String, dynamic>?)?['name'] ?? 'Klien';

        var newChat = await FirebaseFirestore.instance.collection('chats').add({
          'vendorId': widget.vendorId,
          'vendorName': widget.vendorName,
          'customerId': currentUser!.uid,
          'customerName': customerName,
          'lastMessage': 'Memulai percakapan...',
          'unreadVendor': 0,
          'unreadCustomer': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        chatId = newChat.id;
      } else {
        chatId = chatQuery.docs.first.id;
      }

      if (!mounted) return;
      setState(() => _isChatLoading = false);
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatClientRoomScreen(
        chatId: chatId, vendorId: widget.vendorId, vendorName: widget.vendorName
      )));
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _isChatLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.vendorId).get(),
        builder: (context, vendorSnapshot) {
          if (vendorSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
          }

          var vendorData = (vendorSnapshot.data?.data() as Map<String, dynamic>?) ?? {};
          String imageUrl = vendorData['imageUrl'] ?? 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=500&auto=format&fit=crop';
          String category = vendorData['category'] ?? 'Event Organizer';
          String address = vendorData['address'] ?? 'Alamat belum diatur';
          String displayName = vendorData['name'] ?? widget.vendorName;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0, 
                pinned: true, 
                backgroundColor: AppColors.primaryPink,
                leading: IconButton(
                  icon: const CircleAvatar(backgroundColor: Colors.white54, child: Icon(Icons.arrow_back, color: Colors.black)), 
                  onPressed: () => Navigator.pop(context)
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 20),
                  title: Text(
                    displayName, 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18, shadows: [Shadow(color: Colors.black87, blurRadius: 4)]),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(imageUrl, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            // ---> KITA KEMBALIKAN KE WITHOPACITY YANG AMAN <---
                            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 45, left: 20, right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.primaryPink, borderRadius: BorderRadius.circular(4)),
                              child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                Expanded(child: Text(address, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Daftar Layanan & Paket', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Icon(Icons.verified, color: Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('packages').where('vendorId', isEqualTo: widget.vendorId).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('Vendor ini belum memiliki paket.', style: TextStyle(color: Colors.black54))));

                          return ListView.builder(
                            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), 
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var package = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                              String packageId = snapshot.data!.docs[index].id;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16), 
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)), 
                                elevation: 0, 
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(package['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                                      const SizedBox(height: 8),
                                      Text(package['description'] ?? '', style: const TextStyle(color: Colors.black54, height: 1.5, fontSize: 13)),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(currencyFormat.format(package['price'] ?? 0), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPink, fontSize: 18)),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primaryPink, 
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                                            ),
                                            onPressed: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => BookingScreen(
                                                vendorId: widget.vendorId, 
                                                vendorName: displayName, 
                                                packageId: packageId, 
                                                packageData: package
                                              )));
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
          );
        }
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isChatLoading ? null : _startChat,
        backgroundColor: AppColors.primaryPink,
        icon: _isChatLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text('Chat Vendor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}