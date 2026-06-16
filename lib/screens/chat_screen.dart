import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'chat_room_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        title: const Text('Pesan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: const CircleAvatar(radius: 25, backgroundColor: Color(0xFFF7EBEF), child: Icon(Icons.store, color: Color(0xFFE56B8B))),
            title: const Text('Nama Vendor EO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: const Text('Halo, untuk tanggal tersebut apakah...', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black54)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('10:30', style: TextStyle(color: Colors.black38, fontSize: 12)),
                const SizedBox(height: 4),
                Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFFE56B8B), shape: BoxShape.circle), child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
              ],
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatRoomScreen()));
            },
          );
        },
      ),
    );
  }
}