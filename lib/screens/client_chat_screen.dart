import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import 'chatclient_room_screen.dart';

class ClientChatScreen extends StatelessWidget {
  const ClientChatScreen({super.key});

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
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite, elevation: 0,
        title: const Text('Pesan Saya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: currentUser == null
        ? const Center(child: Text('Silakan login terlebih dahulu'))
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('chats').where('customerId', isEqualTo: currentUser.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('Anda belum memiliki percakapan.', style: TextStyle(color: Colors.black54)));

              var chats = snapshot.data!.docs;
              chats.sort((a, b) {
                Timestamp? timeA = (a.data() as Map<String, dynamic>)['updatedAt'] as Timestamp?;
                Timestamp? timeB = (b.data() as Map<String, dynamic>)['updatedAt'] as Timestamp?;
                if (timeA == null || timeB == null) return 0;
                return timeB.compareTo(timeA);
              });

              return ListView.builder(
                padding: const EdgeInsets.all(20), itemCount: chats.length,
                itemBuilder: (context, index) {
                  var chatData = chats[index].data() as Map<String, dynamic>;
                  String chatId = chats[index].id;
                  int unreadCount = chatData['unreadCustomer'] ?? 0;

                  return InkWell(
                    onTap: () {
                      if (unreadCount > 0) FirebaseFirestore.instance.collection('chats').doc(chatId).update({'unreadCustomer': 0});
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatClientRoomScreen(
                        chatId: chatId, vendorId: chatData['vendorId'], vendorName: chatData['vendorName'] ?? 'Vendor',
                      )));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        children: [
                          const CircleAvatar(radius: 25, backgroundColor: Color(0xFFFDE8EE), child: Icon(Icons.store, color: AppColors.primaryPink)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(chatData['vendorName'] ?? 'Vendor', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(_formatTime(chatData['updatedAt'] as Timestamp?), style: TextStyle(color: unreadCount > 0 ? AppColors.primaryPink : Colors.black38, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(chatData['lastMessage'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: unreadCount > 0 ? Colors.black87 : Colors.black54, fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal)),
                              ],
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 10),
                            Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: AppColors.primaryPink, shape: BoxShape.circle), child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))
                          ]
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}