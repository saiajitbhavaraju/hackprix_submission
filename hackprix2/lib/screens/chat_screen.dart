import 'package:flutter/material.dart';
import 'package:ecosnap_1/common/colors.dart';
import 'package:ecosnap_1/models/conversation.dart';
import 'package:ecosnap_1/services/api_service.dart';
import 'conversation_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Use ApiService to fetch live data
  final ApiService _apiService = ApiService();
  late Future<List<Conversation>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch conversations when the screen loads
    _conversationsFuture = _apiService.getConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0.0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildAppBarIcon(Icons.person_outline, color: primary),
              const SizedBox(width: 10),
              _buildAppBarIcon(Icons.search),
            ],
          ),
          const Text("Chat", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
          Row(
            children: [
              _buildAppBarIcon(Icons.person_add_alt_1_outlined),
              const SizedBox(width: 10),
              _buildAppBarIcon(Icons.more_horiz),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, {Color? color}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.08)),
      child: Icon(icon, color: color ?? darkGrey, size: 22),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        color: Colors.white,
      ),
      // Use FutureBuilder to handle the asynchronous API call
      child: FutureBuilder<List<Conversation>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No chats found."));
          }

          final conversations = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.only(top: 10),
            children: [
              _buildSectionHeader("All Chats"),
              const SizedBox(height: 5),
              ...List.generate(conversations.length, (index) {
                // Build each item from the live conversation data
                return _buildChatItem(conversations[index]);
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(title, style: const TextStyle(color: blue, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  // This widget now takes a Conversation object
  Widget _buildChatItem(Conversation conversation) {
    return InkWell(
      onTap: () {
        // Navigate with the Conversation object
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConversationScreen(conversation: conversation)),
        ).then((_) {
          // Optional: Refresh the list when returning
          setState(() {
             _conversationsFuture = _apiService.getConversations();
          });
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              // Using a placeholder for the image
              child: Text(conversation.otherUsername.isNotEmpty ? conversation.otherUsername[0].toUpperCase() : 'U'),
              radius: 28
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conversation.otherUsername, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(
                    conversation.lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.7),
                      fontWeight: FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.grey.shade300,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
