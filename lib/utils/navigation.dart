import 'package:flutter/material.dart';

Route<T> fadeSlideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.05, 0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var fadeAnimation = Tween<double>(begin: 0.9, end: 1).animate(animation);

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: animation.drive(tween),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}
