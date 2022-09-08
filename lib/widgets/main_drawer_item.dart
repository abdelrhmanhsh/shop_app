import 'package:flutter/material.dart';

class MainDrawerItem extends StatelessWidget {

  final IconData icon;
  final String label;
  final Function handler;

  const MainDrawerItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.handler
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,),
      title: Text(label,),
      onTap: () => handler(),
    );
  }
}
