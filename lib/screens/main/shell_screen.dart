import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'write_screen.dart';
import 'bookmark_screen.dart';
import 'profile_screen.dart';

class ShellScreen extends StatefulWidget {
  final int initialTab;
  final bool openDraftTab;
  const ShellScreen({super.key, this.initialTab = 0, this.openDraftTab = false});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
<<<<<<< HEAD
  late int _currentIndex;
=======
  int _currentIndex = 0;
>>>>>>> Back-End

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

<<<<<<< HEAD
=======
  @override
  void didUpdateWidget(ShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _currentIndex = widget.initialTab;
      });
    }
  }

>>>>>>> Back-End
  List<Widget> get _screens => [
    const HomeScreen(),
    const ExploreScreen(),
    const WriteScreen(),
    const BookmarkScreen(),
    ProfileScreen(openDraftTab: widget.openDraftTab),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _NulisinBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          // Write tab opens as modal bottom sheet
          if (i == 2) {
            _showWriteSheet(context);
            return;
          }
          setState(() => _currentIndex = i);
        },
      ),
    );
  }

  void _showWriteSheet(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const WriteScreen()));
  }
}

class _NulisinBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NulisinBottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Beranda'),
    _NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Jelajahi'),
    _NavItem(icon: Icons.edit_outlined, activeIcon: Icons.edit_rounded, label: 'Tulis'),
    _NavItem(icon: Icons.bookmark_outline, activeIcon: Icons.bookmark_rounded, label: 'Simpan'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceBright,
        border: Border(top: BorderSide(color: AppColors.outline, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.sage : Colors.transparent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          size: 24,
                          color: isActive ? AppColors.primary : AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? AppColors.primary : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
