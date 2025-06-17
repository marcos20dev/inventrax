import 'package:flutter/material.dart';
import '../../../widgets/widget_drawer/base_scaffold.dart';
import '../../../widgets/widget_notification/Notification_Toast.dart';
import '../../usuarios_auth/register_screen.dart';
import '../../../repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsuariosList extends StatefulWidget {
  const UsuariosList({super.key});

  @override
  State<UsuariosList> createState() => _UsuariosListState();
}

class _UsuariosListState extends State<UsuariosList> {
  final UserRepository _userRepository = UserRepository(Supabase.instance.client);
  final TextEditingController _searchController = TextEditingController();

  final Color primaryColor = const Color(0xFF00BFA5);
  final Color backgroundColor = Colors.white;
  final Color surfaceColor = const Color(0xFFF5F7FA);
  final Color textPrimary = const Color(0xFF263238);
  final Color textSecondary = const Color(0xFF607D8B);

  List<Map<String, dynamic>> usuarios = [];
  List<Map<String, dynamic>> filteredUsuarios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
    _searchController.addListener(_filterUsuarios);
  }

  Future<void> cargarUsuarios() async {
    setState(() => isLoading = true);
    try {
      usuarios = await _userRepository.obtenerUsuarios();
      filteredUsuarios = usuarios;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterUsuarios() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsuarios = usuarios.where((usuario) {
        final nombre = usuario['nombre']?.toString().toLowerCase() ?? '';
        final correo = usuario['correo']?.toString().toLowerCase() ?? '';
        final dni = usuario['dni']?.toString().toLowerCase() ?? '';
        return nombre.contains(query) || correo.contains(query) || dni.contains(query);
      }).toList();
    });
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Gestión de Usuarios',
      backgroundColor: surfaceColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        ),
        backgroundColor: primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          // Barra de búsqueda moderna con efecto de vidrio
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, correo o DNI...',
                  hintStyle: TextStyle(color: textSecondary.withOpacity(0.7)),
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: textSecondary),
                    onPressed: () => _searchController.clear(),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
                style: TextStyle(color: textPrimary, fontSize: 15),
              ),
            ),
          ),

          // Contador de resultados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filteredUsuarios.length} ${filteredUsuarios.length == 1 ? 'usuario' : 'usuarios'} encontrados',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF00BFA5)),
              ),
            )
                : RefreshIndicator(
              onRefresh: cargarUsuarios,
              color: primaryColor,
              backgroundColor: Colors.white,
              displacement: 32, // opcional, baja el punto de activación
              child: filteredUsuarios.isEmpty
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(), // obligatorio si está vacío
                children: [_buildEmptyState()],
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: filteredUsuarios.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final usuario = filteredUsuarios[index];
                  return _buildUserCard(usuario);
                },
              ),
            ),
          )

        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            usuarios.isEmpty ? Icons.group_off : Icons.search_off,
            size: 64,
            color: textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            usuarios.isEmpty ? 'No hay usuarios registrados' : 'No se encontraron resultados',
            style: TextStyle(
              color: textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _searchController.clear(),
              child: const Text('Limpiar búsqueda'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> usuario) {
    final rol = usuario['rol'] ?? 'Usuario';
    final rolColor = switch (rol.toString().toLowerCase()) {
      'administrador' => const Color(0xFF00BFA5),
      'editor' => const Color(0xFFFF9100),
      _ => const Color(0xFF2962FF),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        highlightColor: primaryColor.withOpacity(0.05),
        splashColor: primaryColor.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
          BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar con iniciales
              _buildUserAvatar(usuario['nombre']?.toString() ?? 'SN'),

              const SizedBox(width: 16),

              // Información del usuario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            usuario['nombre'] ?? 'Sin nombre',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildRoleBadge(rol, rolColor),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 14, color: textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            usuario['correo'] ?? 'Sin correo',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.badge_outlined, size: 14, color: textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'DNI: ${usuario['dni'] ?? '--'}',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menú de acciones
              _buildActionMenu(usuario),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildUserAvatar(String nombre) {
    final initials = nombre.isNotEmpty
        ? nombre.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'SN';

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String rol, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        rol.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionMenu(Map<String, dynamic> usuario) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: textSecondary.withOpacity(0.6)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: textSecondary),
              const SizedBox(width: 8),
              const Text('Editar usuario'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red[400]),
              const SizedBox(width: 8),
              const Text('Eliminar usuario'),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        // En la parte del diálogo de edición (dentro de _buildActionMenu):
        if (value == 'edit') {
          final roles = await _userRepository.getAllRoles();
          final TextEditingController correoController = TextEditingController(text: usuario['correo']);

          // 1. Obtener el NOMBRE del rol actual del usuario
          final currentRolName = usuario['rol']?.toString();
          debugPrint('Nombre del rol actual: $currentRolName');

          // 2. Buscar el rol por NOMBRE en vez de por ID
          var initialRol = roles.firstWhere(
                (r) => r.nombre?.toLowerCase() == currentRolName?.toLowerCase(),
            orElse: () => roles.firstWhere((r) => r.idRoles != null), // Asegurar que tenga ID
          );

          debugPrint('Rol inicial seleccionado: ${initialRol.nombre} (ID: ${initialRol.idRoles})');

          await showDialog(
            context: context,
            builder: (context) {
              String? selectedRolId = initialRol.idRoles?.toString();

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Editar Usuario'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Nombre'),
                            initialValue: usuario['nombre'],
                            readOnly: true,
                          ),

                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: selectedRolId,
                            decoration: const InputDecoration(labelText: 'Rol'),
                            items: roles.where((r) => r.idRoles != null).map((role) {
                              return DropdownMenuItem<String>(
                                value: role.idRoles!.toString(),
                                child: Text(role.nombre ?? 'Sin nombre'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedRolId = value);
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (selectedRolId == null) {
                            showNotificationToast(
                              context,
                              message: 'Seleccione un rol válido',
                              type: NotificationType.warning,
                            );
                            return;
                          }

                          try {
                            final userId = usuario['id_usuario'] as String;
                            final rolId = int.parse(selectedRolId!);

                            await _userRepository.actualizarUsuario(
                              id: userId,
                              rolId: rolId,
                            );

                            Navigator.pop(context);
                            cargarUsuarios();

                            showNotificationToast(
                              context,
                              message: 'Rol actualizado correctamente',
                              type: NotificationType.success,
                            );
                          } catch (e) {
                            debugPrint('Error completo al guardar: $e');

                            showNotificationToast(
                              context,
                              message: 'Error: ${e.toString()}',
                              type: NotificationType.error,
                            );
                          }
                        },
                        child: const Text('Guardar'),
                      ),


                    ],
                  );
                },
              );
            },
          );
        }

        else if (value == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: Text('¿Estás seguro de eliminar a ${usuario['nombre'] ?? 'este usuario'}?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red[400]),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            try {
              await _userRepository.eliminarUsuario(usuario['id_usuario']);
              cargarUsuarios();

              showNotificationToast(
                context,
                message: 'Usuario eliminado correctamente',
                type: NotificationType.success,
              );
            } catch (e) {
              showNotificationToast(
                context,
                message: 'Error al eliminar: $e',
                type: NotificationType.error,
              );
            }
          }
        }
      },
    );
  }



}