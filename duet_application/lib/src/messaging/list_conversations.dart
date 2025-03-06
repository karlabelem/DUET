import 'package:duet_application/src/backend/dm_list_backend.dart';
import 'package:flutter/material.dart';

class ConversationList extends StatefulWidget {
  ConversationList(
      {super.key,
      required this.loggedInUser,
      required this.onConversationSelected});

  final String loggedInUser;
  final Function(String, String) onConversationSelected;

  @override
  State<ConversationList> createState() => _ConversationListState();
}

/// Widget that displays the list of conversations a user has
class _ConversationListState extends State<ConversationList> {
  late DmListBackend dmlist;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _initializeConversations();
  }

  /// Initialize the conversations from backend
  Future<void> _initializeConversations() async {
    setState(() {
      loading = true;
    });
    DmListBackend? convos = await getConversation(widget.loggedInUser) ??
        DmListBackend(uuid1: widget.loggedInUser);
    await convos.getDocumentsWithUuidSubstring(widget.loggedInUser);
    await convos.saveToFirestore();
    print(convos.conversations);
    setState(() {
      dmlist = convos;
      loading = false;
    });
  }

  String extractOtherUser(String cid) {
    List<String> users = cid.split("_");
    if (users[0] == widget.loggedInUser) {
      return users[1];
    } else {
      return users[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C469C),
        title: Text("Conversations"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _initializeConversations,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE6E6FA), // Background color
      body: _buildConversationList(dmlist),
    );
  }

  Widget _buildConversationList(DmListBackend dmlist) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: dmlist.conversations.length,
            shrinkWrap: true,
            padding: EdgeInsets.all(10),
            itemBuilder: (BuildContext context, int index) {
              String otherUser = extractOtherUser(dmlist.conversations[index]);
              return GestureDetector(
                onTap: () {
                  widget.onConversationSelected(
                      otherUser, dmlist.names[index][otherUser]!);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    dmlist.names[index][otherUser]!,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF5C469C), // Text color
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
