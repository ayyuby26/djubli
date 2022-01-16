import 'package:flutter/material.dart';

class RippleButtonWidget extends StatelessWidget {
  final bool isBlackRipple;
  final Widget child;
  final Function onTap;
  final BorderRadius borderRadius;

  const RippleButtonWidget({
    Key? key,
    required this.child,
    required this.onTap,
    required this.borderRadius,
    this.isBlackRipple = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: child),
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            splashColor: isBlackRipple ? Colors.black12 : Colors.white30,
            borderRadius: borderRadius,
            onTap: () => onTap(),
          ),
        ),
      ],
    );
  }
}
