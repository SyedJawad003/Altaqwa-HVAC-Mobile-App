import 'package:flutter_test/flutter_test.dart';
import 'package:altaqwa_app/customer/services/chat_service.dart';

void main() {
  group('Chat Models & Service Tests', () {
    test('ChatMessage properties and role checks', () {
      final customerMessage = ChatMessage(
        id: 'msg_1',
        senderId: 'user_123',
        senderRole: 'customer',
        text: 'Hello Al Taqwa support, need AC service',
        timestamp: DateTime(2026, 10, 1, 14, 30),
        isRead: false,
      );

      expect(customerMessage.isCustomer, isTrue);
      expect(customerMessage.isAdmin, isFalse);
      expect(customerMessage.text, 'Hello Al Taqwa support, need AC service');

      final adminMessage = ChatMessage(
        id: 'msg_2',
        senderId: 'admin_456',
        senderRole: 'admin',
        text: 'A technician is on the way!',
        timestamp: DateTime(2026, 10, 1, 14, 35),
        isRead: true,
      );

      expect(adminMessage.isCustomer, isFalse);
      expect(adminMessage.isAdmin, isTrue);
      expect(adminMessage.isRead, isTrue);
    });

    test('ChatService.getChatId formats customer chat document ID correctly', () {
      expect(ChatService.getChatId('user_789'), 'chat_user_789');
      expect(ChatService.getChatId('xyz'), 'chat_xyz');
    });

    test('ChatService.formatTimestamp formats timestamps properly', () {
      final now = DateTime.now();
      final formattedNow = ChatService.formatTimestamp(now);
      expect(formattedNow.isNotEmpty, isTrue);

      final pastDate = DateTime(2025, 5, 20, 10, 15);
      final formattedPast = ChatService.formatTimestamp(pastDate);
      expect(formattedPast, contains('2025'));
    });

    test('ChatService.formatListTime formats relative times cleanly', () {
      final now = DateTime.now();
      final formattedNow = ChatService.formatListTime(now);
      expect(formattedNow, 'Just now');

      final fiveMinsAgo = now.subtract(const Duration(minutes: 5));
      final formattedRecent = ChatService.formatListTime(fiveMinsAgo);
      expect(formattedRecent, '5m ago');
    });
  });
}
