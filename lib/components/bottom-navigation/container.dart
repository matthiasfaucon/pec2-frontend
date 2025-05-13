import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firstflutterapp/config/router.dart';

class BottomNavBar extends StatelessWidget {
  final String currentPath;

  const BottomNavBar({required this.currentPath, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home, context),
          _buildNavItem(1, Icons.search_outlined, Icons.search, context),
          _buildAddButton(context),
          _buildNavItem(
            3,
            Icons.local_fire_department_outlined,
            Icons.local_fire_department,
            context,
          ),
          _buildNavItem(4, Icons.person_outline, Icons.person, context),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    BuildContext context,
  ) {
    final bool isSelected = _getIndex(currentPath) == index;
    final Color iconColor =
        isSelected ? Theme.of(context).primaryColor : Colors.grey;

    goTo() {
      switch (index) {
        case 0:
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(homeRoute);
          });
          break;
        case 1:
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(searchRoute);
          });
          break;
        case 2:
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(uploadPhotoRoute);
          });
          break;
        case 3:
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(subFeedRoute);
          });
          break;
        case 4:
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(profileRoute);
          });
          break;
      }
    }

    return InkWell(
      onTap: goTo,
      child: SizedBox(
        width: 50,
        height: 60,
        child: Center(
          child: Icon(
            isSelected ? activeIcon : icon,
            color: iconColor,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    changeView() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(uploadPhotoRoute);
      });
    }

    return SizedBox(
      width: 55,
      height: 55,
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -15), // Move the button upward to protrude
          child: InkWell(
            onTap: changeView,
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }

  int _getIndex(String path) {
    if (path.startsWith(searchRoute)) return 1;
    if (path.startsWith(uploadPhotoRoute)) return 2;
    if (path.startsWith(subFeedRoute)) return 3;
    if (path.startsWith(profileRoute)) return 4;
    return 0;
  }
}
