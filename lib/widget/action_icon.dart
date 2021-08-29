import 'package:flutter/material.dart';

class ActionIcon extends StatelessWidget {
  const ActionIcon({
    Key? key,
    this.onClick,
    required this.icon,
  }) : super(key: key);

  final Function()? onClick;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
          border: Border.all(color: Color.fromRGBO(62, 62, 62, 1)),
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: icon,
        ),
      ),
    );
  }
}
