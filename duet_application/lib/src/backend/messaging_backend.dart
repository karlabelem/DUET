import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duet_application/src/backend/userProfile.dart';
import 'firestore_instance.dart';

/// A class that manages the direct message (DM) conversations between two users.
class Messagingbackend {
  /// The UUIDs of the two users involved in this conversation.
  final String uuid1, uuid2;

  /// List of messages between both users.
  List<Message> conversation;

  /// Unique conversation ID composed of uuid1 appended with uuid2.
  late final String cid;

  /// Unique name-based conversation ID composed of the names of the two users.
  late String nameCid;

  /// Constructor that initializes the Messagingbackend with the given UUIDs and optional conversation and nameCid.
  Messagingbackend(
      {required this.uuid1,
      required this.uuid2,
      List<Message>? conversation,
      String? nameCid})
      : conversation = conversation ?? [],
        cid = makeCid(uuid1, uuid2),
        nameCid = nameCid ?? "";

  /// Converts the Messagingbackend instance to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'cid': cid,
      'uuid1': uuid1,
      'uuid2': uuid2,
      'conversation': conversation.map((msg) => msg.toMap()).toList(),
      'nameCid': nameCid,
    };
  }

  /// Factory constructor that creates a Messagingbackend instance from a map.
  factory Messagingbackend.fromMap(Map<String, dynamic> data) {
    List<Message> newConversation = [];
    for (var msg in data['conversation']) {
      newConversation.add(Message.fromMap(msg));
    }
    return Messagingbackend(
        uuid1: data['uuid1'],
        uuid2: data['uuid2'],
        conversation: newConversation,
        nameCid: data['nameCid']);
  }

  /// Saves this conversation to Firestore.
  Future<int> saveToFirestore() async {
    try {
      nameCid = await makeNameCid(uuid1, uuid2);
      await firestoreInstance!.instance
          .collection('messages')
          .doc(cid)
          .set(toMap());
      return 0;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return 1;
    }
  }

  /// Updates Firestore on the backend side when a user sends a message.
  /// Returns 0 if successful, 1 if not.
  Future<int> sendMessage(Message msg) async {
    try {
      // Get current conversation.
      var convRef = firestoreInstance!.instance.collection('messages').doc(cid);

      // Update conversation on Firestore.
      conversation.add(msg);
      List<dynamic> jsonConversation = [];
      for (var msg in conversation) {
        jsonConversation.add(msg.toMap());
      }
      await convRef.update({'conversation': jsonConversation});
      return 0;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return 1;
    }
  }
}

/// Generates a unique conversation ID based on the UUIDs of the two users.
String makeCid(String user1, String user2) {
  if (user1.compareTo(user2) > 0) {
    return "${user2}_$user1";
  }
  return "${user1}_$user2";
}

/// Generates a unique name-based conversation ID based on the names of the two users.
Future<String> makeNameCid(String user1, String user2) async {
  UserProfileData? profile1 = await UserProfileData.getUserProfile(user1);
  UserProfileData? profile2 = await UserProfileData.getUserProfile(user2);
  if (user1.compareTo(user2) > 0) {
    return "${profile2!.name}_${profile1!.name}";
  }
  return "${profile1!.name}_${profile2!.name}";
}

/// Gets a conversation between two users from Firestore.
Future<Messagingbackend?> getConversation(String user1, String user2) async {
  try {
    var convRef = firestoreInstance!.instance
        .collection('messages')
        .doc(makeCid(user1, user2));
    var convSnapshot = await convRef.get();
    if (convSnapshot.exists) {
      print("Found conversation with ID: ${user1}_$user2");
      return Messagingbackend.fromMap(convSnapshot.data()!);
    }
    print("No conversation found for users: $user1 and $user2");
    return null;
  } catch (e) {
    print("Error in getConversation: $e");
    return null;
  }
}

/// A class representing a message with the necessary information to process the object.
class Message {
  const Message(this.sender, this.receiver, this.text);

  final String sender;
  final String receiver;
  final String text;

  /// Factory constructor that creates a Message instance from a map.
  factory Message.fromMap(Map<String, dynamic> data) {
    return Message(data['sender'], data['receiver'], data['text']);
  }

  /// Converts the Message instance to a map.
  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'receiver': receiver,
      'text': text,
    };
  }
}
