import 'package:duet_application/src/backend/firestore_instance.dart';
import 'package:duet_application/src/backend/messaging_backend.dart';
import 'package:duet_application/src/messaging/conversation.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextBubble Widget', () {
    testWidgets('displays message text correctly', (WidgetTester tester) async {
      // Arrange
      final message = Message('sender', 'receiver', 'Hello, World!');
      final widget = MaterialApp(
        home: Scaffold(
          body: TextBubble(msg: message, sender: 'sender'),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('Hello, World!'), findsOneWidget);
    });

    testWidgets('aligns message to the right for sender', (WidgetTester tester) async {
      // Arrange
      final message = Message('sender', 'receiver', 'Hello, World!');
      final widget = MaterialApp(
        home: Scaffold(
          body: TextBubble(msg: message, sender: 'sender'),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      final container = tester.widget<Container>(find.byType(Container).first);
      final align = container.child as Align;
      expect(align.alignment, Alignment.topRight);
    });

    testWidgets('aligns message to the left for receiver', (WidgetTester tester) async {
      // Arrange
      final message = Message('receiver', 'sender', 'Hello, World!');
      final widget = MaterialApp(
        home: Scaffold(
          body: TextBubble(msg: message, sender: 'sender'),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      final container = tester.widget<Container>(find.byType(Container).first);
      final align = container.child as Align;
      expect(align.alignment, Alignment.topLeft);
    });
  });

  group('SendButton Widget', () {
    testWidgets('calls send function when pressed', (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      final widget = MaterialApp(
        home: Scaffold(
          body: SendButton(
            send: () {
              wasPressed = true;
            },
            typedText: TextEditingController(),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('displays send icon', (WidgetTester tester) async {
      // Arrange
      final widget = MaterialApp(
        home: Scaffold(
          body: SendButton(
            send: () {},
            typedText: TextEditingController(),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });

  group("Messaging Functionalities Test", () {
    testWidgets("Sending a message", (WidgetTester tester) async {
      final firestore = FakeFirebaseFirestore();
      makeFirestoreInstance(instance: firestore);
      firestoreInstance!.instance.collection("messages").doc("user1_user2").set({
        "cid": "user1_user2",
        "uuid1": "user1",
        "uuid2": "user2",
        "conversation": [
          {
            "sender": "user1",
            "receiver": "user2",
            "text": "Hello, man!"
          },
          {
            "sender": "user2",
            "receiver": "user1",
            "text": "Hey, what's up?"
          },
        ],
        "nameCid": "user1_user2"
      });


      final conversation = IndividualDMPage(loggedInUser: "user2", otherUser: "user1", goBack: (){}, otherUserName: "user1");
      final widget = MaterialApp(
        home: conversation,
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      final textBubble = find.byType(TextBubble);
      expect(textBubble, findsNWidgets(2));

      final helloText = find.text("Hello, man!");
      expect(helloText, findsOneWidget);

      final wassupText = find.text("Hey, what's up?");
      expect(wassupText, findsOneWidget);

      // Write a message to the text controller
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'New message');
      await tester.pump();

      // Tap the send button
      final sendButton = find.byType(SendButton);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Verify the new message is displayed
      final newMessage = find.text('New message');
      expect(newMessage, findsOneWidget);
      expect(textBubble, findsNWidgets(3));
    });
  });
}