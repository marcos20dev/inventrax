import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/Permisos.dart';
import '../../../models/RolPermisos.dart';
import '../../../repositories/permisos_repository.dart';
import '../../../widgets/widget_drawer/base_scaffold.dart';
import '../../../widgets/widget_notification/Notification_Toast.dart';


class PermisosRolView extends StatefulWidget {
  final String rolNombre;

  const PermisosRolView({
    super.key,
    required this.rolNombre,
  });

  @override
  State<PermisosRolView> createState() => _PermisosRolViewState();
}

class _PermisosRolViewState extends State<PermisosRolView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  final Color _primaryColor = const Color(0xFF26A69A);
  final Color _surfaceColor = const Color(0xFFF8F9FA);
  final Color _onSurfaceColor = const Color(0xFF212529);
  final Color _successColor = const Color(0xFF4AD66D);
  final Color _borderColor = const Color(0xFFE9ECEF);
  bool _isSaving = false;
  List<PermisoModel> _todosLosPermisos = [];

  final PermisoRepository _permisoRepository = PermisoRepository();
  Map<String, List<PermisoModel>> _permisosAgrupados = {};
  final Map<String, bool> _permisosSeleccionados = {};

  @override
  void initState() {
    super.initState();
    _cargarPermisos();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animationController.forward(from: 0);
      _cargarPermisos();
    });
  }
  Map<String, List<PermisoModel>> _agruparPorModulo(List<PermisoModel> permisos) {
    final Map<String, List<PermisoModel>> agrupados = {};

    for (var permiso in permisos) {
      final modulo = permiso.modulo.trim(); // Asegura que no haya espacios
      if (!agrupados.containsKey(modulo)) {
        agrupados[modulo] = [];
      }
      agrupados[modulo]!.add(permiso);
    }

    return agrupados;
  }

  Future<void> _cargarPermisos() async {
    final rolId = await _obtenerRolIdDesdeNombre(widget.rolNombre);
    final permisos = await _permisoRepository.getAll();
    final permisosAsignados = await _permisoRepository.obtenerPermisosDeRol(rolId);

    setState(() {
      _todosLosPermisos = permisos;
      _permisosAgrupados = _agruparPorModulo(permisos);
      for (var permiso in permisos) {
        _permisosSeleccionados[permiso.nombre] =
            permisosAsignados.contains(permiso.id);
      }
    });
  }



  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Permisos: ${widget.rolNombre}',
      body: CustomScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderSection()),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildPermissionSections(),
              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
      floatingActionButton: _buildSaveButton(),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asignar permisos al rol',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _onSurfaceColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Activa/desactiva los módulos necesarios',
            style: TextStyle(
              fontSize: 14,
              color: _onSurfaceColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: _borderColor),
        ],
      ),
    );
  }

  Widget _buildPermissionSections() {
    if (_permisosAgrupados.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    int index = 0;
    return Column(
      children: _permisosAgrupados.entries.map((entry) {
        final modulo = entry.key;
        final permisos = entry.value;
        final delay = Duration(milliseconds: 100 + index++ * 100);
        final icon = _iconoPorModulo(modulo);

        return _buildSection(
          title: modulo,
          icon: icon,
          items: permisos.map((p) => p.nombre).toList(),
        ).animate(delay: delay).fadeIn().slideX(begin: -0.05);
      }).toList(),
    );
  }

  IconData _iconoPorModulo(String modulo) {
    switch (modulo.toLowerCase()) {
      case 'gestión comercial':
        return Icons.shopping_cart_rounded;
      case 'gestión de inventario':
        return Icons.inventory_rounded;
      case 'productos / entradas':
        return Icons.category_rounded;
      case 'administración':
        return Icons.admin_panel_settings_rounded;
      case 'configuración':
        return Icons.settings_rounded;
      default:
        return Icons.extension;
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                Icon(icon, color: _primaryColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: _onSurfaceColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: _borderColor, width: 1),
            ),
            child: Column(
              children:
              items.map((nombre) => _buildPermissionTile(nombre)).toList(),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPermissionTile(String title) {
    final isActive = _permisosSeleccionados[title] ?? false;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        title,
        style: TextStyle(
          color: _onSurfaceColor,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      leading: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? _primaryColor : Colors.transparent,
          border: Border.all(
            color: isActive ? _primaryColor : _borderColor,
            width: 2,
          ),
        ),
        child: isActive
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : null,
      ),
      trailing: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? _successColor.withOpacity(0.2) : Colors.transparent,
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? _successColor : Colors.grey.withOpacity(0.4),
            ),
          ),
        ),
      ),
      onTap: () {
        setState(() => _permisosSeleccionados[title] = !isActive);
        Feedback.forTap(context);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }


  Future<int> _obtenerRolIdDesdeNombre(String nombre) async {
    final data = await Supabase.instance.client
        .from('roles')
        .select('id_roles')
        .eq('nombre', nombre)
        .maybeSingle();

    if (data == null || data['id_roles'] == null) {
      throw Exception('Rol no encontrado');
    }

    return data['id_roles'] as int;
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: FloatingActionButton.extended(
        onPressed: _isSaving
            ? null
            : () async {
          setState(() => _isSaving = true);

          try {
            final permisos = await _permisoRepository.getAll();
            final rolId = await _obtenerRolIdDesdeNombre(widget.rolNombre);

            final permisosParaGuardar = permisos
                .where((permiso) =>
            _permisosSeleccionados[permiso.nombre] == true)
                .map((permiso) => RolPermisoModel(
              rolId: rolId,
              permisoId: permiso.id,
              estado: true,
            ))
                .toList();

            await _permisoRepository.guardarPermisosDeRol(
                rolId, permisosParaGuardar);

            if (mounted) {
              showNotificationToast(
                context,
                message: 'Permisos concedidos',
                type: NotificationType.success,
              );
              Navigator.pop(context);
            }
          } catch (e) {
            if (mounted) {
              showNotificationToast(
                context,
                message: 'Error al guardar permisos',
                type: NotificationType.error,
              );
            }
          } finally {
            if (mounted) setState(() => _isSaving = false);
          }
        },
        backgroundColor: _primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: _isSaving
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Icon(Icons.save_rounded, color: Colors.white),
        label: Text(
          _isSaving ? 'Guardando...' : 'Guardar cambios',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        heroTag: 'savePermissionsButton',
      ).animate(controller: _animationController).scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1, 1),
        curve: Curves.elasticOut,
      ),
    );
  }




}
