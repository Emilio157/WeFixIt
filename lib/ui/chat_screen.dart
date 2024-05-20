import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatUserScreen extends StatefulWidget {
  final String receiverId;
  final String problemId;

  ChatUserScreen({required this.receiverId, required this.problemId});

  @override
  _ChatUserScreenState createState() => _ChatUserScreenState();
}

class _ChatUserScreenState extends State<ChatUserScreen> {
  final TextEditingController _messageController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  String _generateChatId(String senderId, String receiverId, String problemId) {
    List<String> ids = [senderId, receiverId];
    ids.sort(); 
    return '${ids[0]}_${ids[1]}_$problemId';
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty && user != null) {
      String chatId = _generateChatId(user!.uid, widget.receiverId, widget.problemId);

      final chatMessage = {
        'senderId': user!.uid,
        'receiverId': widget.receiverId,
        'problemId': widget.problemId,
        'message': _messageController.text,
        'timestamp': Timestamp.now(),
      };

      try {
        await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
          'senderId': user!.uid,
          'receiverId': widget.receiverId,
          'problemId': widget.problemId,
        });

        await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add(chatMessage);
        _messageController.clear();
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String chatId = _generateChatId(user!.uid, widget.receiverId, widget.problemId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == user!.uid;

                    return ListTile(
                      title: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message['message'],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
