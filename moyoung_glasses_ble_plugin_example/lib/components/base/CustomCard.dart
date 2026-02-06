import 'package:flutter/material.dart';

//使用：
//CustomCard(
//child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[])),

class CustomCard extends StatelessWidget {
  final List<Widget> children;

  const CustomCard({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        clipBehavior: Clip.antiAlias,
        elevation: 8.0,
        shadowColor: Colors.black,
        child: Padding(
            padding: const EdgeInsets.all(16.0), // 内边距，可以根据需要调整
            child: Align(
                alignment: Alignment.bottomLeft, // 或者Alignment.centerLeft
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: children))));
  }
}
