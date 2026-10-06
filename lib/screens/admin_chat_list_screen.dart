import 'package:flutter/material.dart';
import '../admin/admin_navigation_drawer.dart';
import '../admin/admin_theme.dart';
import '../customer/services/chat_service.dart';
import '../customer/theme/app_theme.dart';
import 'admin_chat_screen.dart';

/// Admin Chat List Screen: overview dashboard of all customer chat threads.
class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});

  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all' | 'unread' | 'recent'

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final query = _searchController.text.trim().toLowerCase();
      if (query != _searchQuery) {
        setState(() => _searchQuery = query);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatConversation> _filterConversations(List<ChatConversation> all) {
    return all.where((conv) {
      // 1. Tab filter
      if (_selectedFilter == 'unread' && conv.unreadByAdminCount <= 0) {
        return false;
      }
      if (_selectedFilter == 'recent') {
        final now = DateTime.now();
        final isToday = conv.lastMessageTime.year == now.year &&
            conv.lastMessageTime.month == now.month &&
            conv.lastMessageTime.day == now.day;
        if (!isToday) return false;
      }

      // 2. Search query filter
      if (_searchQuery.isNotEmpty) {
        final name = conv.customerName.toLowerCase();
        final email = conv.customerEmail.toLowerCase();
        final lastMsg = conv.lastMessage.toLowerCase();
        if (!name.contains(_searchQuery) &&
            !email.contains(_searchQuery) &&
            !lastMsg.contains(_searchQuery)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: canPop ? null : const AdminNavigationDrawer(),
      appBar: AdminGradientAppBar(
        title: 'Customer Chats',
        subtitle: 'Live 1-on-1 customer service & engineering dispatch.',
        showMenu: !canPop,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<ChatConversation>>(
          stream: _chatService.watchAllChats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(navy),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load customer chats:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final allConversations = snapshot.data ?? [];
            final totalUnread = allConversations.fold<int>(
              0,
              (sum, item) => sum + item.unreadByAdminCount,
            );
            final filteredConversations =
                _filterConversations(allConversations);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Metric Cards Header
                _buildMetricsHeader(
                  totalChats: allConversations.length,
                  totalUnread: totalUnread,
                ),

                // Search & Filter controls
                _buildSearchAndFilters(
                  totalUnread: totalUnread,
                  filteredCount: filteredConversations.length,
                ),

                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // Conversation List
                Expanded(
                  child: filteredConversations.isEmpty
                      ? _buildEmptyState(allConversations.isEmpty)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          itemCount: filteredConversations.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final conv = filteredConversations[index];
                            return _buildConversationCard(conv);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricsHeader({
    required int totalChats,
    required int totalUnread,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              title: 'Active Threads',
              value: '$totalChats',
              icon: Icons.chat_bubble_outline,
              accentColor: navy,
              bgColor: const Color(0xFFF1F5F9),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              title: 'Unread Inquiries',
              value: '$totalUnread',
              icon: Icons.mark_chat_unread_outlined,
              accentColor: totalUnread > 0 ? const Color(0xFFB45309) : navy,
              bgColor: totalUnread > 0
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFFF1F5F9),
              badge: totalUnread > 0 ? 'Needs Attention' : 'All Clear',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.25),
              ),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters({
    required int totalUnread,
    required int filteredCount,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: Colors.white,
      child: Column(
        children: [
          // Search box
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'Search by customer name, email, or message...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF64748B), size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter chips
          Row(
            children: [
              _buildFilterChip('all', 'All Chats'),
              const SizedBox(width: 8),
              _buildFilterChip(
                'unread',
                'Unread ($totalUnread)',
                highlight: totalUnread > 0,
              ),
              const SizedBox(width: 8),
              _buildFilterChip('recent', 'Today'),
              const Spacer(),
              Text(
                '$filteredCount result${filteredCount == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label,
      {bool highlight = false}) {
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filterKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? navy
              : (highlight
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? navy
                : (highlight ? gold : const Color(0xFFCBD5E1)),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (highlight
                    ? const Color(0xFF92400E)
                    : const Color(0xFF334155)),
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildConversationCard(ChatConversation conv) {
    final hasUnread = conv.unreadByAdminCount > 0;
    final initials = conv.customerName.trim().isNotEmpty
        ? conv.customerName.trim().substring(0, 1).toUpperCase()
        : 'C';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AdminChatScreen(
                chatId: conv.chatId,
                customerId: conv.customerId,
                customerName: conv.customerName,
                customerEmail: conv.customerEmail,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasUnread ? gold : const Color(0xFFE2E8F0),
              width: hasUnread ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: hasUnread
                    ? gold.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Avatar with Initials
              Stack(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: hasUnread
                            ? [navy, const Color(0xFF1E5A9C)]
                            : [const Color(0xFF64748B), const Color(0xFF475569)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: hasUnread ? gold : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: gold,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Conversation text & details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            conv.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: navy,
                              fontSize: 15,
                              fontWeight:
                                  hasUnread ? FontWeight.w900 : FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ChatService.formatListTime(conv.lastMessageTime),
                          style: TextStyle(
                            color: hasUnread ? navy : const Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight:
                                hasUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (conv.customerEmail.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        conv.customerEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),

                    // Last message preview
                    Row(
                      children: [
                        if (conv.lastSenderRole == 'admin') ...[
                          const Icon(
                            Icons.reply,
                            size: 14,
                            color: Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'You: ',
                            style: TextStyle(
                              color: Color(0xFF0284C7),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        Expanded(
                          child: Text(
                            conv.lastMessage.isEmpty
                                ? 'No messages yet'
                                : conv.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: hasUnread
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF64748B),
                              fontSize: 13,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [gold, goldLight],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: gold.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              '${conv.unreadByAdminCount} new',
                              style: const TextStyle(
                                color: navy,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCBD5E1),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool trulyEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Icon(
                trulyEmpty
                    ? Icons.forum_outlined
                    : Icons.search_off_outlined,
                color: navy,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              trulyEmpty ? 'No Customer Chats Yet' : 'No Matching Chats Found',
              style: const TextStyle(
                color: navy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trulyEmpty
                  ? 'When customers send messages from the Al Taqwa customer app, their threads will appear here instantly in real-time.'
                  : 'Try changing your search terms or selecting the "All Chats" filter.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
