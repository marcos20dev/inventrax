import 'package:flutter/material.dart';

class CustomExpansionTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<Widget> children;

  const CustomExpansionTileWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        leading: Icon(icon, size: 22, color: color),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        childrenPadding: const EdgeInsets.only(left: 12),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        collapsedIconColor: color.withOpacity(0.6),
        iconColor: color,
        children: children,
      ),
    );
  }
}
