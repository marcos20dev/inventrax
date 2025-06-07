import 'package:flutter/material.dart';

enum NotificationType { success, error, warning }

class NotificationToast extends StatefulWidget {
  final String message;
  final NotificationType type;
  final VoidCallback onDismiss;

  const NotificationToast({
    Key? key,
    required this.message,
    required this.type,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<NotificationToast> createState() => _NotificationToastState();
}

class _NotificationToastState extends State<NotificationToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse();
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get backgroundColor {
    switch (widget.type) {
      case NotificationType.success:
        return const Color(0xffd1fae5);
      case NotificationType.error:
        return const Color(0xfffad1d1);
      case NotificationType.warning:
        return const Color(0xfffffcc7);
    }
  }

  Color get textColor {
    switch (widget.type) {
      case NotificationType.success:
        return const Color(0xff258c6e);
      case NotificationType.error:
        return const Color(0xff991b1b);
      case NotificationType.warning:
        return const Color(0xffff9900);
    }
  }

  IconData get icon {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        color: backgroundColor,
        child: Container(
          width: 240,  // ancho más pequeño
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // padding más compacto
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 20),  // ícono más pequeño
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,  // texto más pequeño
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _controller.reverse();
                },
                child: Icon(Icons.close, color: textColor, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Función helper para mostrar la notificación desde cualquier widget
void showNotificationToast(
    BuildContext context, {
      required String message,
      required NotificationType type,
      double verticalPositionFactor = 0.08,
    }) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  final topOffset = MediaQuery.of(context).size.height * verticalPositionFactor;

  entry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: topOffset,
        right: 8,
        child: NotificationToast(
          message: message,
          type: type,
          onDismiss: () {
            entry.remove();
          },
        ),
      );
    },
  );

  overlay?.insert(entry);
}
