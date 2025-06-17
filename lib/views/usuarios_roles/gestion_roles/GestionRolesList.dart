import 'package:flutter/material.dart';
import '../../../models/roles.dart';
import '../../../repositories/roles_repository.dart';
import '../../../widgets/widget_drawer/base_scaffold.dart';
import '../../../widgets/widget_notification/Notification_Toast.dart';
import 'GestionRolesForm.dart';
import 'PermisosRolView.dart';

class GestionRolesList extends StatefulWidget {
  const GestionRolesList({super.key});

  @override
  State<GestionRolesList> createState() => _GestionRolesListState();
}

class _GestionRolesListState extends State<GestionRolesList> {
  final RoleRepository _repo = RoleRepository();
  late Future<List<Role>> _rolesFuture;

  final primaryColor = const Color(0xFF26A69A);
  final accentColor = const Color(0xFF4DB6AC);
  final backgroundColor = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _rolesFuture = _repo.fetchRoles();
  }

  void _refreshRoles() {
    setState(() {
      _rolesFuture = _repo.fetchRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Gestión de Roles',
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRoleDialog(context),
        backgroundColor: primaryColor,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  hintText: 'Buscar roles...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // Lista de roles obtenida desde Supabase
          Expanded(
            child: FutureBuilder<List<Role>>(
              future: _rolesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar roles'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay roles registrados.'));
                }

                final roles = snapshot.data!;
                return RefreshIndicator(
                  color: primaryColor, // color del círculo giratorio
                  backgroundColor: Colors.white, // fondo detrás del spinner
                  onRefresh: () async {
                    _refreshRoles();
                    await Future.delayed(const Duration(milliseconds: 300));
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: roles.length,
                    itemBuilder: (context, index) {
                      return _buildRoleCard(context, roles[index], index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, Role role, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          highlightColor: primaryColor.withOpacity(0.05),
          splashColor: primaryColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getRoleColor(index).withOpacity(0.1),
                  ),
                  child: Icon(
                      Icons.manage_accounts, color: _getRoleColor(index)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.nombre ?? 'Rol sin nombre',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Creado: ${role.createdAt.toLocal().toString().split(
                            ' ')[0]}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.vpn_key, color: Colors.grey[600]),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PermisosRolView(
                                  rolNombre: role.nombre ?? '',
                                ),
                          ),
                        );
                      },
                      tooltip: 'Configurar permisos',
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.grey[600]),
                      onPressed: () {
                        _showEditRoleDialog(
                          context,
                          role.nombre ?? '',
                          roleId: role.idRoles,
                          roleRepository: _repo,
                          onSuccess: _refreshRoles,
                        );
                      },

                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(int index) {
    final colors = [
      primaryColor,
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.teal
    ];
    return colors[index % colors.length];
  }

  void _showAddRoleDialog(BuildContext context) {
    final TextEditingController roleNameController = TextEditingController();
    final FocusNode focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con icono
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_moderator, color: primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Crear Nuevo Rol',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Campo de texto con animación
                  Focus(
                    onFocusChange: (hasFocus) {},
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: focusNode.hasFocus ? primaryColor : Colors
                              .grey[300]!,
                          width: focusNode.hasFocus ? 1.5 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: roleNameController,
                          focusNode: focusNode,
                          style: TextStyle(color: Colors.grey[800]),
                          decoration: InputDecoration(
                            labelText: 'Nombre del Rol',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: InputBorder.none,
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ejemplo: "Administrador", "Editor", "Invitado"',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botones con efecto de onda
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(horizontal: 20,
                              vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(horizontal: 24,
                              vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadowColor: primaryColor.withOpacity(0.3),
                        ),
                        onPressed: () async {
                          final roleName = roleNameController.text.trim();

                          if (roleName.isEmpty) {
                            _playShakeAnimation(context);
                            showNotificationToast(
                              context,
                              message: 'Por favor ingresa un nombre de rol',
                              type: NotificationType.warning,
                            );
                            return;
                          }

                          final repo = RoleRepository();
                          final existingRoles = await repo.getAllRoles(); // Asegúrate de que este método existe

                          final alreadyExists = existingRoles.any((role) =>
                          role.nombre?.toLowerCase() == roleName.toLowerCase());

                          if (alreadyExists) {
                            showNotificationToast(
                              context,
                              message: 'Ya existe un rol con el nombre "$roleName"',
                              type: NotificationType.error,
                            );
                            return;
                          }

                          try {
                            final role = Role(
                              idRoles: null,
                              nombre: roleName,
                              createdAt: DateTime.now(),
                            );

                            await repo.insertRole(role);

                            Navigator.pop(context);
                            showNotificationToast(
                              context,
                              message: 'Rol "$roleName" creado con éxito',
                              type: NotificationType.success,
                            );
                          } catch (e) {
                            Navigator.pop(context);
                            showNotificationToast(
                              context,
                              message: 'Error al crear el rol: $e',
                              type: NotificationType.error,
                            );
                          }
                        },

                        child: const Text('Crear Rol'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _playShakeAnimation(BuildContext context) {
    final animation = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: ScaffoldMessenger.of(context),
    );
    final curve = CurvedAnimation(parent: animation, curve: Curves.elasticOut);
    final shake = Tween<double>(begin: 0, end: 10).animate(curve);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animation.reset();
      }
    });

    animation.forward();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            AnimatedBuilder(
              animation: shake,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(shake.value, 0),
                  child: const Icon(Icons.warning_amber, color: Colors.orange),
                );
              },
            ),
            const SizedBox(width: 12),
            const Text('Ingresa un nombre para el rol'),
          ],
        ),
        backgroundColor: Colors.red[50],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEditRoleDialog(
      BuildContext context,
      String roleName, {
        required int? roleId,
        required RoleRepository roleRepository,
        required VoidCallback onSuccess,
      }) {
    final TextEditingController roleNameController =
    TextEditingController(text: roleName);
    final FocusNode focusNode = FocusNode();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        bool isProcessing = false;

        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 32,
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF26A599), Color(0xFF69D8CE)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Editar Rol',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              )),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (roleId != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3), // verde muy suave
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'ID: $roleId',
                              style: const TextStyle(
                                color: Color(0xFF26A69A), // verde vibrante
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        const Text(
                          'Nombre del Rol',
                          style: TextStyle(
                            color: Color(0xFF4E4E4E),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: roleNameController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFE1F1F0), // verde-grisáceo claro

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE1F1F0), // verde pastel suave
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE1F1F0), // verde más fuerte al enfocar
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              hintText: 'Ingresa el nombre del rol',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 17,
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF202020),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Delete Button
                        TextButton(
                          onPressed: roleId == null || isProcessing
                              ? null
                              : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) =>
                                  _buildDeleteConfirmationDialog(context, roleName),
                            );

                            if (confirm == true) {
                              setState(() => isProcessing = true);
                              try {
                                await roleRepository.deleteRole(roleId!);
                                Navigator.pop(context);
                                showNotificationToast(
                                  context,
                                  message: 'Rol eliminado correctamente',
                                  type: NotificationType.success,
                                );
                                onSuccess();
                              } catch (e) {
                                setState(() => isProcessing = false);
                                showNotificationToast(
                                  context,
                                  message: 'Error al eliminar el rol',
                                  type: NotificationType.error,
                                );
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red[400],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Eliminar',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ),

                        // Save Button
                        ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () async {
                            if (roleNameController.text.trim().isEmpty) {
                              showNotificationToast(
                                context,
                                message: 'El nombre no puede estar vacío',
                                type: NotificationType.error,
                              );
                              return;
                            }
                            setState(() => isProcessing = true);
                            try {
                              final updatedRole = Role(
                                idRoles: roleId,
                                nombre: roleNameController.text.trim(),
                                createdAt: DateTime.now(),
                              );
                              await roleRepository.updateRole(updatedRole);
                              Navigator.pop(context);
                              showNotificationToast(
                                context,
                                message: 'Rol actualizado correctamente',
                                type: NotificationType.success,
                              );
                              onSuccess();
                            } catch (e) {
                              setState(() => isProcessing = false);
                              showNotificationToast(
                                context,
                                message: 'Error al actualizar el rol',
                                type: NotificationType.error,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: isProcessing
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                              : const Text('Guardar',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildDeleteConfirmationDialog(BuildContext context, String roleName) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.red[400],
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '¿Eliminar Rol?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'El rol "$roleName" será eliminado permanentemente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Cancelar',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Eliminar',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


}