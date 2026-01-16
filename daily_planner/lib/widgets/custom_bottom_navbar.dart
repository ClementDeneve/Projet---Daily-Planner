import 'dart:ui';

import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final primary = theme.colorScheme.primary;
    final double bottomInset = MediaQuery.of(context).padding.bottom; // account for system nav
    const double baseHeight = 68.0;
    final double totalHeight = baseHeight + bottomInset;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Stack(
          children: [
            // Soft blur + subtle gradient for a premium look
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                height: totalHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [surface.withOpacity(0.98), surface.withOpacity(0.9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: totalHeight,
              child: BottomNavigationBar(
                // give a little internal padding so items don't stick to the bottom
                // (BottomNavigationBar handles safe area for labels/icons, but we ensure space)
                // Note: the SizedBox already includes bottom inset
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list_outlined),
                    activeIcon: Icon(Icons.list),
                    label: 'To Do',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today_outlined),
                    activeIcon: Icon(Icons.calendar_today),
                    label: 'Daily',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
                currentIndex: currentIndex,
                selectedItemColor: primary,
                unselectedItemColor: Colors.grey.shade600,
                showUnselectedLabels: true,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
                iconSize: 24.0,
                onTap: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
