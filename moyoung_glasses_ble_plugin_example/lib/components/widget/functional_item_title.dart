import 'package:flutter/material.dart';

class FunctionalItemTitle extends StatefulWidget {
  final String title;

  const FunctionalItemTitle({Key? key, required this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FunctionalItemTitle();
  }
}

class _FunctionalItemTitle extends State<FunctionalItemTitle> {
  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ConstrainedBox(
            constraints: const BoxConstraints.expand(width: 20, height: 20),
            child: Stack(
              children: [
                Positioned(
                    left: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      color: const Color(0xffCAE4FB),
                    )),
                Positioned(
                    left: 4,
                    top: 4,
                    child: Container(
                      width: 18,
                      height: 18,
                      color: const Color(0xff0188FF),
                    )),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xff232426)),
          ),
        ),
      ],
    );
  }
}
