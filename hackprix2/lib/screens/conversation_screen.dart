import 'package:ecosnap_1/models/conversation.dart';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
// Note: You may need to create this colors.dart file or replace 'blue' with Colors.blue
import '../common/colors.dart'; 

class ConversationScreen extends StatefulWidget {
  // Pass the full Conversation object for better context
  final Conversation conversation;

  const ConversationScreen({Key? key, required this.conversation}) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _messageController = TextEditingController();
  late Future<List<Message>> _messagesFuture;

  @override
  void initState() {
    super.initState();
    // Fetch messages when the screen loads
    _messagesFuture = _apiService.getMessages(widget.conversation.otherUserId);
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // Clear the input field immediately
    _messageController.clear();

    try {
      // Call the API to send the message
      await _apiService.sendMessage(widget.conversation.otherUserId, content);
      
      // Refresh the messages list to show the new message
      setState(() {
        _messagesFuture = _apiService.getMessages(widget.conversation.otherUserId);
      });
    } catch (e) {
      // Handle error, e.g., show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Message>>(
              future: _messagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No messages yet. Say hi!"));
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true, // To show the latest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    // FIXED: Use the public getter 'currentUserId' instead of the private '_mockUserId'
                    final isMe = message.senderId == _apiService.currentUserId;
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CircleAvatar(
            // Use a placeholder if no image is available
            // backgroundImage: NetworkImage(widget.conversation.otherUserImage),
            child: Text(widget.conversation.otherUsername[0].toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.conversation.otherUsername, // This will now show the correct username
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined, color: Colors.black54, size: 28),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call_outlined, color: Colors.black54, size: 24),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      color: Colors.grey.shade100,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message...',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: blue),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
