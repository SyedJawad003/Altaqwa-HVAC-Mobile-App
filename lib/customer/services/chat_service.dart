import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a single chat message.
class ChatMessage {
  final String id;
  final String senderId;
  final String senderRole; // "customer" | "admin"
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.text,
    required this.timestamp,
    required this.isRead,
  });

  bool get isCustomer => senderRole.toLowerCase() == 'customer';
  bool get isAdmin => senderRole.toLowerCase() == 'admin';

  factory ChatMessage.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawTimestamp = data['timestamp'];
    DateTime parsedTime;
    if (rawTimestamp is Timestamp) {
      parsedTime = rawTimestamp.toDate();
    } else if (rawTimestamp is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    } else {
      parsedTime = DateTime.now();
    }

    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderRole: data['senderRole'] as String? ?? 'customer',
      text: data['text'] as String? ?? '',
      timestamp: parsedTime,
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderRole': senderRole,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}

/// Model representing a customer chat thread for Admin overview.
class ChatConversation {
  final String chatId;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastSenderRole;
  final int unreadByAdminCount;
  final int unreadByCustomerCount;

  const ChatConversation({
    required this.chatId,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastSenderRole,
    required this.unreadByAdminCount,
    required this.unreadByCustomerCount,
  });

  factory ChatConversation.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawTime = data['lastMessageTime'] ?? data['updatedAt'];
    DateTime parsedTime;
    if (rawTime is Timestamp) {
      parsedTime = rawTime.toDate();
    } else {
      parsedTime = DateTime.now();
    }

    return ChatConversation(
      chatId: doc.id,
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? 'Customer',
      customerEmail: data['customerEmail'] as String? ?? '',
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageTime: parsedTime,
      lastSenderRole: data['lastSenderRole'] as String? ?? 'customer',
      unreadByAdminCount: (data['unreadByAdminCount'] as num?)?.toInt() ?? 0,
      unreadByCustomerCount: (data['unreadByCustomerCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Service handling all real-time 1-on-1 Customer <-> Admin chat operations.
class ChatService {
  final FirebaseFirestore _firestore;

  ChatService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _chatsCollection =>
      _firestore.collection('chats');

  /// Formats the standard document ID for a customer chat: `chat_<customerId>`.
  static String getChatId(String customerId) => 'chat_$customerId';

  /// Ensures a chat thread document exists in Firestore.
  Future<void> ensureChatExists({
    required String customerId,
    required String customerName,
    String customerEmail = '',
  }) async {
    final chatId = getChatId(customerId);
    final docRef = _chatsCollection.doc(chatId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'customerId': customerId,
        'customerName': customerName.trim().isEmpty ? 'Customer' : customerName.trim(),
        'customerEmail': customerEmail.trim().toLowerCase(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderRole': '',
        'unreadByAdminCount': 0,
        'unreadByCustomerCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Update customer name/email if missing or newer
      final data = snapshot.data() ?? {};
      if ((data['customerName'] == null || data['customerName'] == 'Customer') &&
          customerName.trim().isNotEmpty) {
        await docRef.update({
          'customerName': customerName.trim(),
          'customerEmail': customerEmail.trim().toLowerCase(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  /// Sends a message from the Customer to Admin.
  Future<void> sendCustomerMessage({
    required String customerId,
    required String customerName,
    required String text,
    String customerEmail = '',
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    final chatId = getChatId(customerId);
    final chatDocRef = _chatsCollection.doc(chatId);
    final messagesRef = chatDocRef.collection('messages');

    // Make sure chat document exists
    await ensureChatExists(
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
    );

    // Add new message
    await messagesRef.add({
      'senderId': customerId,
      'senderRole': 'customer',
      'text': cleanText,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Update parent conversation summary
    await chatDocRef.set({
      'customerId': customerId,
      'customerName': customerName.trim().isEmpty ? 'Customer' : customerName.trim(),
      'customerEmail': customerEmail.trim().toLowerCase(),
      'lastMessage': cleanText,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSenderRole': 'customer',
      'unreadByAdminCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Sends a message from the Admin to the Customer.
  Future<void> sendAdminMessage({
    required String chatId,
    required String adminId,
    required String text,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    final chatDocRef = _chatsCollection.doc(chatId);
    final messagesRef = chatDocRef.collection('messages');

    // Add new message
    await messagesRef.add({
      'senderId': adminId,
      'senderRole': 'admin',
      'text': cleanText,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Update parent conversation summary
    await chatDocRef.set({
      'lastMessage': cleanText,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSenderRole': 'admin',
      'unreadByCustomerCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Real-time stream of all messages in a specific chat, ordered by timestamp descending.
  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }

  /// Real-time stream of all customer chats for Admin, ordered by lastMessageTime descending.
  Stream<List<ChatConversation>> watchAllChats() {
    return _chatsCollection
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatConversation.fromFirestore(doc))
            .where((c) => c.lastMessage.isNotEmpty || c.customerId.isNotEmpty)
            .toList());
  }

  /// Real-time stream for a single chat document (to watch unread counts and status).
  Stream<ChatConversation?> watchChatConversation(String chatId) {
    return _chatsCollection.doc(chatId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return ChatConversation.fromFirestore(snapshot);
    });
  }

  /// Marks all admin messages in the chat as read by the customer.
  Future<void> markAsReadByCustomer(String chatId) async {
    try {
      final chatDocRef = _chatsCollection.doc(chatId);

      // Reset customer unread badge
      await chatDocRef.set({
        'unreadByCustomerCount': 0,
      }, SetOptions(merge: true));

      // Mark unread admin messages as read
      final unreadAdminMessages = await chatDocRef
          .collection('messages')
          .where('senderRole', isEqualTo: 'admin')
          .where('isRead', isEqualTo: false)
          .limit(40)
          .get();

      if (unreadAdminMessages.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in unreadAdminMessages.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      }
    } catch (_) {}
  }

  /// Marks all customer messages in the chat as read by the admin.
  Future<void> markAsReadByAdmin(String chatId) async {
    try {
      final chatDocRef = _chatsCollection.doc(chatId);

      // Reset admin unread badge
      await chatDocRef.set({
        'unreadByAdminCount': 0,
      }, SetOptions(merge: true));

      // Mark unread customer messages as read
      final unreadCustomerMessages = await chatDocRef
          .collection('messages')
          .where('senderRole', isEqualTo: 'customer')
          .where('isRead', isEqualTo: false)
          .limit(40)
          .get();

      if (unreadCustomerMessages.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in unreadCustomerMessages.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      }
    } catch (_) {}
  }

  /// Helper to format timestamps cleanly for chat bubbles & lists.
  static String formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    final hour = dateTime.hour == 0
        ? 12
        : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dateTime.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minuteStr $period';

    if (difference.inDays == 0 && now.day == dateTime.day) {
      return timeStr;
    } else if (difference.inDays <= 1 ||
        (now.day - dateTime.day == 1 && difference.inHours < 48)) {
      return 'Yesterday, $timeStr';
    } else if (now.year == dateTime.year) {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}, $timeStr';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// Relative short format for conversation list previews.
  static String formatListTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays == 0 && now.day == dateTime.day) {
      final hour = dateTime.hour == 0
          ? 12
          : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final minuteStr = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minuteStr $period';
    } else if (diff.inDays <= 1 || (now.day - dateTime.day == 1 && diff.inHours < 48)) {
      return 'Yesterday';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}';
    }
  }
}
