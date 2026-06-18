import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';

class ChatVendorRoomScreen extends StatefulWidget {
  final String chatId;
  final String receiverId;
  final String receiverName;
  final bool isVendor;

  const ChatVendorRoomScreen({
    super.key, 
    required this.chatId, 
    required this.receiverId, 
    required this.receiverName,
    required this.isVendor,
  });

  @override
  State<ChatVendorRoomScreen> createState() => _ChatVendorRoomScreenState();
}

class _ChatVendorRoomScreenState extends State<ChatVendorRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || currentUser == null) return;

    String messageText = _messageController.text.trim();
    _messageController.clear(); 

    // 1. Tambah pesan ke sub-koleksi 'messages'
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'senderId': currentUser!.uid,
      'text': messageText,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Perbarui dokumen 'chat' utama
    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
      'lastMessage': messageText,
      'updatedAt': FieldValue.serverTimestamp(),
      widget.isVendor ? 'unreadCustomer' : 'unreadVendor': FieldValue.increment(1),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            const CircleAvatar(backgroundColor: Color(0xFFFDE8EE), child: Icon(Icons.person, color: AppColors.primaryPink, size: 20)),
            const SizedBox(width: 12),
            Text(widget.receiverName, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada pesan. Mulai sapa sekarang!', style: TextStyle(color: Colors.black54)));
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, 
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var msgData = messages[index].data() as Map<String, dynamic>;
                    bool isMe = msgData['senderId'] == currentUser?.uid;

                    return _buildMessageBubble(msgData['text'] ?? '', isMe);
                  },
                );
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primaryPink,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryPink : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14)),
      ),
    );
  }
}