import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chat")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No messages yet"),
            );
          }
          if (chatSnapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }
          final loadedMessages = chatSnapshot.data!.docs;

          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
              reverse: true,
              itemCount: loadedMessages.length,
              itemBuilder: (context, index) {
                return Text(loadedMessages[index].data()["text"]);
              });
        });
  }
}
