import 'package:flutter/material.dart';

class GestionRolesForm extends StatelessWidget {
  final bool isEditing;
  final String? roleName;

  const GestionRolesForm({
    super.key,
    required this.isEditing,
    this.roleName,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController =
    TextEditingController(text: isEditing ? roleName : '');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Rol' : 'Nuevo Rol'),
        backgroundColor: Colors.blue, // Usa tu primaryColor
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Rol',
                prefixIcon: Icon(Icons.manage_accounts),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Lógica para guardar
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Usa tu primaryColor
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(isEditing ? 'Actualizar Rol' : 'Crear Rol'),
            ),
          ],
        ),
      ),
    );
  }
}