import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bina_dokter/service/api_service.dart';

class Chatwithpatient extends StatefulWidget {
  final String patientId;
  const Chatwithpatient({Key? key, required this.patientId}) : super(key: key);

  @override
  State<Chatwithpatient> createState() => _ChatwithpatientState();
}

class _ChatwithpatientState extends State<Chatwithpatient> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  final ApiService _apiService = ApiService();


  @override
  void initState() {
    super.initState();
    _fetchChatHistory();
  }

  Future<void> _fetchChatHistory() async {
    while (true) {
      setState(() {
      });
      // debugPrint('Memulai fetch chat history');
      try {
        final chatHistory = await _apiService.getChatHistory(widget.patientId);
        setState(() {
          _messages = chatHistory;
        });
        // debugPrint('Chat history berhasil diambil');
      } catch (e) {
        // debugPrint('Error fetching chat history: $e');
        // Tambahkan penanganan error di sini, misalnya menampilkan snackbar
      } finally {
        setState(() {
        });
        // debugPrint('Selesai fetch chat history');
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final message = _messageController.text;
      _messageController.clear();
      setState(() {
        _messages.add({
          'sender_id': 'user', 
          'message': message,
          'sent_at': DateTime.now().toIso8601String(),
          'sender_role': 'Doctor',
          'sender_name': 'Nama Pengguna',
        });
      });
      try {
        final response = await _apiService.sendMessageDoctor(widget.patientId, message);
        if (response['success'] == true) {
          // print('Message sent successfully');
        } else {
          // print('Failed to send message: ${response['message']}');
          // Tambahkan penanganan error di sini, misalnya menampilkan snackbar
        }
      } catch (e) {
        // print('Error sending message: $e');
        // Tambahkan penanganan error di sini, misalnya menampilkan snackbar
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Chat with Patient',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender_role'] == 'Doctor';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['sender_name'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          message['message'],
                          style: GoogleFonts.poppins(),
                        ),
                        Text(
                          _formatTimestamp(message['sent_at']),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
