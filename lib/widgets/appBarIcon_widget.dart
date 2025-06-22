import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBarIconWidget extends StatelessWidget {
  final String? imageUrl;
  final IconData? icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double iconSize;

  const AppBarIconWidget({
    Key? key,
    this.imageUrl,
    this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.iconSize = 30,
  }) : assert(imageUrl != null || icon != null, 'Either imageUrl or icon must be provided'),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10.h,),
          imageUrl != null
              ? Image.asset(
                  imageUrl!,
                  width: iconSize,
                  height: iconSize,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                )
              : Icon(
                  icon!,
                  size: iconSize,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}