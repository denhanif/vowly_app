import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import 'chatvendor_room_screen.dart'; // <-- UPDATE IMPORT DI SINI

class VendorChatScreen extends StatefulWidget {
  const VendorChatScreen({super.key});

  @override
  State<VendorChatScreen> createState() => _VendorChatScreenState();
}

class _VendorChatScreenState extends State<VendorChatScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    DateTime date = timestamp.toDate();
    DateTime now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return DateFormat('HH:mm').format(date);
    } else {
      return DateFormat('dd MMM').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        title: const Text('Pesan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: currentUser == null
        ? const Center(child: Text('Silakan login terlebih dahulu'))
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .where('vendorId', isEqualTo: currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Belum ada pesan masuk.', style: TextStyle(color: Colors.black54)));
              }

              var chats = snapshot.data!.docs;
              chats.sort((a, b) {
                Timestamp? timeA = (a.data() as Map<String, dynamic>)['updatedAt'] as Timestamp?;
                Timestamp? timeB = (b.data() as Map<String, dynamic>)['updatedAt'] as Timestamp?;
                if (timeA == null || timeB == null) return 0;
                return timeB.compareTo(timeA);
              });

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  var chatData = chats[index].data() as Map<String, dynamic>;
                  String chatId = chats[index].id;
                  int unreadCount = chatData['unreadVendor'] ?? 0;

                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          if (unreadCount > 0) {
                            FirebaseFirestore.instance.collection('chats').doc(chatId).update({'unreadVendor': 0});
                          }
                          // --- UPDATE PANGGILAN CLASS DI SINI ---
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatVendorRoomScreen(
                            chatId: chatId,
                            receiverId: chatData['customerId'],
                            receiverName: chatData['customerName'] ?? 'Klien',
                            isVendor: true,
                          )));
                        },
                        child: _buildChatItem(
                          chatData['customerName'] ?? 'Klien',
                          chatData['lastMessage'] ?? 'Memulai obrolan...',
                          _formatTime(chatData['updatedAt'] as Timestamp?),
                          unreadCount,
                        ),
                      ),
                      if (index < chats.length - 1) const Divider(height: 30, color: Colors.black12),
                    ],
                  );
                },
              );
            },
          ),
    );
  }

  Widget _buildChatItem(String name, String message, String time, int unreadCount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundColor: Color(0xFFFDE8EE),
          child: Icon(Icons.people, color: AppColors.primaryPink),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                  Text(time, style: TextStyle(color: unreadCount > 0 ? AppColors.primaryPink : Colors.black38, fontSize: 12, fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message, 
                maxLines: 1, 
                overflow: TextOverflow.ellipsis, 
                style: TextStyle(color: unreadCount > 0 ? Colors.black87 : Colors.black54, fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal)
              ),
            ],
          ),
        ),
        if (unreadCount > 0) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: AppColors.primaryPink, shape: BoxShape.circle),
            child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ]
      ],
    );
  }
}