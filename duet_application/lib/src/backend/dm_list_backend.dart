import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duet_application/src/backend/userProfile.dart';
import 'firestore_instance.dart';

/// A class that manages the list of direct message (DM) conversations for a user.
class DmListBackend {
  /// The UUID of the logged-in user.
  final String uuid1;

  /// List of conversation IDs.
  List<String> conversations;

  /// List of maps containing user UUIDs and their corresponding names.
  List<Map<String, String>> names;

  /// Constructor that initializes the DmListBackend with the given UUID and optional lists of conversations and names.
  DmListBackend({required this.uuid1, List<String>? conversations, List<Map<String, String>>? names})
      : conversations = conversations ?? [],
        names = names ?? [];

  /// Factory constructor that creates a DmListBackend instance from a map.
  factory DmListBackend.fromMap(Map<String, dynamic> data) {
    return DmListBackend(
      uuid1: data['uuid1'],
      conversations: List<String>.from(data['conversations']),
      names: List<Map<String, String>>.from(data['names']),
    );
  }

  /// Converts the DmListBackend instance to a map.
  Map<String, dynamic> toMap() {
    return {
      'uuid1': uuid1,
      'conversations': conversations,
      'names': names,
    };
  }

  /// Saves the DmListBackend instance to Firestore.
  Future<int> saveToFirestore() async {
    try {
      await firestoreInstance!.instance
          .collection('dm_list')
          .doc(uuid1)
          .set(toMap());
      return 0;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return 1;
    }
  }

  /// Fetches all documents in the messaging collection that contain the UUID substring.
  Future<void> getDocumentsWithUuidSubstring(String uuid) async {
    List<String> documentNames = [];
    List<Map<String, String>> userNames = [];
    try {
      final QuerySnapshot querySnapshot = await firestoreInstance!.instance
          .collection('messages')
          .get();
      for (var doc in querySnapshot.docs) {
        if (doc.id.contains(uuid)) {
          documentNames.add(doc.id);
          List<String> profiles = doc.id.split("_");
          UserProfileData? profile1 = await UserProfileData.getUserProfile(profiles[0]);
          UserProfileData? profile2 = await UserProfileData.getUserProfile(profiles[1]);
          if (profile1 != null && profile2 != null) {
            userNames.add({profile1.uuid: profile1.name, profile2.uuid: profile2.name});
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
    conversations = documentNames;
    names = userNames;
  }

  /// Fetches conversations from Firestore.
  Future<void> fetchConversations() async {
    try {
      final DocumentSnapshot doc = await firestoreInstance!.instance
          .collection('dm_list')
          .doc(uuid1)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        conversations = List<String>.from(data['conversations']);
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
}

/// Gets the list of conversations a user has from Firestore.
Future<DmListBackend?> getConversation(String uuid1) async {
  try {
    final DocumentSnapshot doc = await firestoreInstance!.instance
        .collection('dm_list')
        .doc(uuid1)
        .get();
    if (doc.exists) {
      return DmListBackend.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  } catch (e) {
    // ignore: avoid_print
    print(e);
    return null;
  }
}

