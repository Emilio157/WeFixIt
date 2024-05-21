import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bubble/bubble.dart';

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
  
  /* Future<String> _getUserName(String receiverid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Usuarios').doc(receiverid).get();
      if (userDoc.exists) {
        return userDoc['Name'];
      } else {
        return 'No Name Found';
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Error';
    }
  } */

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
        toolbarHeight: 75,
        title: Text('Chat', style: TextStyle(fontSize: 28),),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            color: Colors.red,
            thickness: 15,),
        ),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 8,),
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
                        child: Bubble(
                          color: isMe ? Color.fromARGB(255, 253, 95, 84) : Color.fromARGB(255, 160, 160, 160), 
                          nip: isMe ? BubbleNip.rightTop : BubbleNip.leftTop,
                          radius: Radius.circular(8),
                          child: Text(
                            message['message'],
                            style: const TextStyle(color: Colors.white, fontSize: 20),
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
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 22),
                        hintText: 'Escribe tu mensaje...',
                      ),
                    ),
                  ),
                ),
                Ink(
                  height: 50,
                  width: 50,
                  decoration: const ShapeDecoration(shape: CircleBorder(), color: Colors.red),
                  child: IconButton(
                    icon: Icon(Icons.send, size: 25, color: Colors.white, ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* 
Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.red : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message['message'],
                            style: TextStyle(color: Colors.white),
                          ),
                        ), */