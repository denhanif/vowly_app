import 'package:flutter/material.dart';
import '../utils/colors.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({super.key});

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
        title: Row(
          children: const [
            CircleAvatar(radius: 16, backgroundColor: Colors.grey, child: Icon(Icons.store, color: Colors.white, size: 16)),
            SizedBox(width: 10),
            Text('Nama Vendor', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildMessageBubble('Halo! Ada yang bisa kami bantu untuk acara Anda?', false),
                _buildMessageBubble('Halo, saya ingin bertanya tentang Paket Silver, apakah masih tersedia?', true),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
            child: SafeArea(
              child: Row(
                children: [
                  const Icon(Icons.attach_file, color: Colors.black54),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(backgroundColor: const Color(0xFFE56B8B), child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: () {})),
                ],
              ),
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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFE56B8B) : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}