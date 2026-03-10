import 'package:flutter/material.dart';

class BottomMediaBar extends StatelessWidget {
  const BottomMediaBar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(150, 0, 0, 0),
          border: Border(top: BorderSide(color: Colors.white24, width: 0.5)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Row(children: children),
      ),
    );
  }
}
