import 'package:flutter/material.dart';

class ContainerBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  
  const ContainerBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

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
    final bool isSelected = selectedIndex == index;
    final Color iconColor =
        isSelected ? Theme.of(context).primaryColor : Colors.grey;

    return InkWell(
      onTap: () => onItemSelected(index),
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
    return InkWell(
      onTap: () => onItemSelected(2),
      child: Container(
        width: 50,
        height: 50,
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
    );
  }
}