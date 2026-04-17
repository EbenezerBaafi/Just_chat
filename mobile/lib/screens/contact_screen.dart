import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with TickerProviderStateMixin {
  static const Color kBackgroundColor = Color(0xFF0E0E0E);
  static const Color kPrimaryColor = Color(0xFFBBC3FF);
  static const Color kOnSurface = Color(0xFFE7E5E4);
  static const Color kOnSurfaceVariant = Color(0xFFACABAA);
  static const Color kOutline = Color(0xFF767575);
  static const Color kSurfaceContainerLowest = Color(0xFF000000);
  static const Color kSurfaceContainerLow = Color(0xFF131313);
  static const Color kSurface = Color(0xFF0E0E0E);

  final TextEditingController _searchController = TextEditingController();
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final name = (user['username'] ?? '').toLowerCase();
        final email = (user['email'] ?? '').toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchUsers() async {
    try {
      final token =
          Provider.of<AuthProvider>(context, listen: false).token ?? '';
      final response = await _api.getUsers(token);
      setState(() {
        _users = List<Map<String, dynamic>>.from(response.data);
        _filteredUsers = _users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load contacts';
        _isLoading = false;
      });
    }
  }

  Future<void> _openChat(Map<String, dynamic> user) async {
    try {
      final token =
          Provider.of<AuthProvider>(context, listen: false).token ?? '';
      final response = await _api.startConversation(token, user['id']);
      final conversation = response.data;

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversation['id'],
            otherUserName: user['username'] ?? user['email'],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open conversation')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 80,
            backgroundColor: kSurface.withValues(alpha: 0.8),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 72, bottom: 16),
              title: Text(
                'just_chat',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: kPrimaryColor,
                  letterSpacing: -0.8,
                ),
              ),
              background: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bubble_chart_outlined,
                          color: kPrimaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.search, color: kPrimaryColor, size: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 128),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contacts',
                    style: GoogleFonts.manrope(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: kOnSurface,
                      letterSpacing: -1.2,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start a new conversation with your inner circle.',
                    style: GoogleFonts.inter(
                      color: kOnSurfaceVariant,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kSurfaceContainerLowest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.inter(color: kOnSurface, fontSize: 14),
                      cursorColor: kPrimaryColor,
                      decoration: InputDecoration(
                        hintText: 'Search contacts...',
                        hintStyle: GoogleFonts.inter(
                          color: kOutline,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: kOutline,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    )
                  else if (_error != null)
                    Center(
                      child: Column(
                        children: [
                          Text(
                            _error!,
                            style: GoogleFonts.inter(color: kOnSurfaceVariant),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _error = null;
                              });
                              _fetchUsers();
                            },
                            child: Text(
                              'Retry',
                              style: GoogleFonts.inter(color: kPrimaryColor),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_filteredUsers.isEmpty)
                    Center(
                      child: Text(
                        'No contacts found',
                        style: GoogleFonts.inter(color: kOnSurfaceVariant),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredUsers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return ContactListItem(
                          name: user['username'] ?? '',
                          subtitle: user['email'] ?? '',
                          isActive: user['is_online'] ?? false,
                          onTap: () => _openChat(user),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(color: kSurfaceContainerLow),
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavBarItem(
              icon: Icons.chat_bubble_outline,
              label: 'Chats',
              isActive: false,
              onTap: () {},
            ),
            NavBarItem(
              icon: Icons.contacts,
              label: 'Contacts',
              isActive: true,
              onTap: () {},
            ),
            NavBarItem(
              icon: Icons.person_outline,
              label: 'Profile',
              isActive: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class ContactListItem extends StatefulWidget {
  final String name;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;

  const ContactListItem({
    super.key,
    required this.name,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<ContactListItem> createState() => _ContactListItemState();
}

class _ContactListItemState extends State<ContactListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isHovered ? _scaleAnimation.value : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _ContactsScreenState.kPrimaryColor
                                .withValues(alpha: 0.2),
                          ),
                          child: Icon(
                            Icons.person,
                            color: _ContactsScreenState.kPrimaryColor,
                            size: _isHovered ? 30 : 28,
                          ),
                        ),
                        if (widget.isActive)
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _ContactsScreenState.kPrimaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _ContactsScreenState.kSurface,
                                  width: 4,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: GoogleFonts.manrope(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _isHovered
                                  ? _ContactsScreenState.kPrimaryColor
                                  : _ContactsScreenState.kOnSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _ContactsScreenState.kOnSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: _ContactsScreenState.kOutline,
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? _ContactsScreenState.kPrimaryColor
                : _ContactsScreenState.kOnSurfaceVariant,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? _ContactsScreenState.kPrimaryColor
                  : _ContactsScreenState.kOnSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
