// widgets/base/base_scaffold.dart
import 'package:flutter/material.dart';

import '../../views/menu/drawer_widget.dart';

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Color? backgroundColor;  // color de fondo opcional
  final Widget? floatingActionButton; // floatingActionButton opcional

  const BaseScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.backgroundColor,
    this.floatingActionButton, // parámetro opcional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? const Color(0xFFEDEEF1); // predeterminado

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: bgColor,
        elevation: 0, // Esto elimina la sombra/oscurecimiento
        scrolledUnderElevation: 0, // Elimina el efecto al hacer scroll.
        surfaceTintColor: Colors.transparent,
      ),
      drawer: const MenuDrawer(),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: bgColor,
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton, // solo si es no nulo lo muestra
    );
  }
}
