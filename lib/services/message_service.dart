import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to get unique chat participants for a specific user
  Future<List<Map<String, dynamic>>> getChatParticipants(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('messages')
          .where('participants', arrayContains: userId)
          .orderBy('timestamp', descending: true)
          .get();

      Map<String, Map<String, dynamic>> participants = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final otherUserId = data['sender'] == userId ? data['receiver'] : data['sender'];
        if (!participants.containsKey(otherUserId)) {
          participants[otherUserId] = data;
        }
      }
      return participants.values.toList();
    } catch (e) {
      print('Error getting chat participants: $e');
      return [];
    }
  }

  // Method to post a new message
  Future<void> postMessage(Map<String, dynamic> messageData) async {
    try {
      await _firestore.collection('messages').add(messageData);
    } catch (e) {
      print('Error posting message: $e');
    }
  }
}