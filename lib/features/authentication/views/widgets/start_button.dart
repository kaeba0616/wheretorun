import 'package:flutter/material.dart';
import 'package:wheretorun/constants/sizes.dart';

class HomeButton extends StatefulWidget {
  final String text;

  final Function()? onTap;
  const HomeButton({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  State<HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<HomeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() {
        _isPressed = true;
      }),
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onTap!();
      },
      onTapCancel: () => setState(() {
        _isPressed = false;
      }),
      child: Transform.scale(
        scale: _isPressed ? 0.90 : 0.95,
        alignment: Alignment.center,
        child: AnimatedContainer(
          width: Sizes.size96 + Sizes.size96,
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isPressed
                ? Colors.green.shade600
                : Colors.green.shade300.withOpacity(0.5),
            borderRadius: BorderRadius.circular(
              Sizes.size5,
            ),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      blurRadius: Sizes.size2,
                      color: Colors.grey.shade200,
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Sizes.size16,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: Sizes.size24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
