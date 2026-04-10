import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final String username;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.username,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _messageController = TextEditingController();

  List messages = [];
  bool isLoading = true;
  bool isSending = false;

  Future<void> fetchMessages() async {
    try {
      final token = context.read<AuthProvider>().token!;
      final response = await _api.getMessages(token, widget.conversationId);

      setState(() {
        messages = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching messages: $e");
    }
  }

  Future<void> sendMessage() async {
    final content = _messageController.text.trim();

    if (content.isEmpty) return;

    setState(() {
      isSending = true;
    });

    try {
      final token = context.read<AuthProvider>().token!;
      await _api.sendMessage(token, widget.conversationId, content);

      _messageController.clear();
      await fetchMessages();
    } catch (e) {
      debugPrint("Error sending message: $e");
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Widget buildMessageBubble(Map message) {
    final currentUserId = context.read<AuthProvider>().token;
    final senderName = message['sender']['username'] ?? 'User';
    final content = message['content'] ?? '';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              senderName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(content),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.username)),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? const Center(child: Text("No messages yet"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return buildMessageBubble(messages[index]);
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type a message",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: isSending ? null : sendMessage,
                    icon: isSending
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
