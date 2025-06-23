import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/ChangeNotifier.dart'; // UserSession
import '../../services/PermisosProvider.dart';
import '../../widgets/widget_drawer/Custom_Expansion_Widget.dart';
import '../../widgets/widget_drawer/MenuItemWidget.dart';
import '../../widgets/widget_drawer/Section_Title_Widget.dart';

import '../ventas/ventas_form.dart';
import '../ventas/ventas_list.dart';
import '../clientes/clientes_list.dart';
import '../entradas_producto/entradas_form.dart';
import '../salida_producto/salida_list.dart';
import '../categorias/categorias_list.dart';
import '../provedores/provedor_list.dart';
import '../usuarios_roles/gestion_roles/GestionRolesList.dart';
import '../usuarios_roles/gestion_usuarios/usuarios_list.dart';
import 'menu_screen.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.tealAccent.shade400 : Colors.teal.shade700;
    final surfaceColor = isDark ? Colors.grey.shade900.withOpacity(0.8) : Colors.white;
    final onSurfaceColor = isDark ? Colors.white : Colors.black;

    final userSession = Provider.of<UserSession>(context);
    final int? rolId = userSession.rolId;

    if (rolId == null) {
      return const Center(child: Text("Cargando sesión..."));
    }

    return FutureBuilder(
      future: Provider.of<PermisosProvider>(context, listen: false).cargarPermisos(rolId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final permisosProvider = Provider.of<PermisosProvider>(context);
        bool tienePermiso(String clave) => permisosProvider.tienePermiso(clave);

        return Drawer(
          width: 340,
          backgroundColor: surfaceColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
          ),
          child: CustomScrollView(
            slivers: [


              SliverToBoxAdapter(
                child: FutureBuilder(
                  future: Supabase.instance.client.rpc('obtener_datos_usuario', params: {
                    'uid': userSession.uid,
                  }),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(height: 160); // altura fija para evitar salto
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const Text("Error al cargar usuario");
                    }

                    final data = (snapshot.data as List).first;
                    final nombre = data['nombre'];
                    final apellido = data['apellido'];
                    final rol = data['nombre_rol'];

                    return Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24, bottom: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryColor.withOpacity(0.2),
                                    border: Border.all(
                                      color: primaryColor.withOpacity(0.5),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(Icons.person_outline, color: primaryColor, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '$nombre $apellido',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: onSurfaceColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Menú Principal',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: onSurfaceColor,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Rol: $rol',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: onSurfaceColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.only(top: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SectionTitleWidget(title: 'Dashboard', color: primaryColor),
                    MenuItemWidget(
                      icon: Icons.dashboard,
                      title: 'Ir al Dashboard',
                      color: primaryColor,
                      onTap: () {
                        final user = Provider.of<UserSession>(context, listen: false);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MenuScreen(
                              uid: user.uid ?? '',
                              rolId: user.rolId ?? 0,
                            ),
                          ),
                        );
                      },
                    ),

                    // GESTIÓN COMERCIAL
                    if (tienePermiso('Registro de Ventas') || tienePermiso('Detalle de Ventas') || tienePermiso('Clientes')) ...[
                      SectionTitleWidget(title: 'Gestión Comercial', color: primaryColor),
                      CustomExpansionTileWidget(
                        icon: Icons.point_of_sale_outlined,
                        title: 'Ventas / Salida',
                        color: primaryColor,
                        children: [
                          if (tienePermiso('Registro de Ventas'))
                            MenuItemWidget(
                              icon: Icons.receipt_long,
                              title: 'Registro de Ventas',
                              color: primaryColor,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => VentasFormScreen()));
                              },
                            ),
                          if (tienePermiso('Detalle de Ventas'))
                            MenuItemWidget(
                              icon: Icons.list_alt,
                              title: 'Detalle de Ventas',
                              color: primaryColor,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => VentaListScreen()));
                              },
                            ),
                          if (tienePermiso('Clientes'))
                            MenuItemWidget(
                              icon: Icons.people_outlined,
                              title: 'Clientes',
                              color: primaryColor,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ClientesListScreen()));
                              },
                            ),
                        ],
                      ),
                    ],

                    // INVENTARIO
                    // GESTIÓN DE INVENTARIO
                    if (tienePermiso('Entradas') || tienePermiso('Salidas') || tienePermiso('Productos')) ...[
                      SectionTitleWidget(title: 'Gestión de Inventario', color: primaryColor),

                      // Subgrupo: Inventario (Entradas + Salidas)
                      if (tienePermiso('Entradas') || tienePermiso('Salidas'))
                        CustomExpansionTileWidget(
                          icon: Icons.inventory_2_outlined,
                          title: 'Inventario',
                          color: primaryColor,
                          children: [
                            if (tienePermiso('Entradas'))
                              MenuItemWidget(
                                icon: Icons.input,
                                title: 'Entradas',
                                color: primaryColor,
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => InventarioScreen()));
                                },
                              ),
                            if (tienePermiso('Salidas'))
                              MenuItemWidget(
                                icon: Icons.output,
                                title: 'Salidas',
                                color: primaryColor,

                              ),
                          ],
                        ),

                      // Subgrupo: Productos / Entradas
                      if (tienePermiso('Productos') || tienePermiso('Categorías'))
                        CustomExpansionTileWidget(
                          icon: Icons.shopping_bag_outlined,
                          title: 'Productos / Entradas',
                          color: primaryColor,
                          children: [
                            if (tienePermiso('Productos'))
                              MenuItemWidget(
                                icon: Icons.grid_view,
                                title: 'Productos',
                                color: primaryColor,
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => InventarioScreen()));
                                },
                              ),
                            if (tienePermiso('Categorías'))
                              MenuItemWidget(
                                icon: Icons.category,
                                title: 'Categorías',
                                color: primaryColor,
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => CategoriaListScreen()));
                                },
                              ),
                          ],
                        ),

                    ],

                    // ADMINISTRACIÓN
                    if (tienePermiso('Proveedores - Listado') || tienePermiso('Gestión de Roles') || tienePermiso('Usuarios')) ...[
                      SectionTitleWidget(title: 'Administración', color: primaryColor),

                      if (tienePermiso('Proveedores - Listado'))
                        CustomExpansionTileWidget(
                          icon: Icons.local_shipping_outlined,
                          title: 'Proveedores',
                          color: primaryColor,
                          children: [
                            MenuItemWidget(
                              icon: Icons.business,
                              title: 'Listado',
                              color: primaryColor,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ProveedorListScreen()));
                              },
                            ),
                          ],
                        ),

                      if (tienePermiso('Gestión de Roles') || tienePermiso('Usuarios'))
                        CustomExpansionTileWidget(
                          icon: Icons.manage_accounts,
                          title: 'Usuarios',
                          color: primaryColor,
                          children: [
                            if (tienePermiso('Gestión de Roles'))
                              MenuItemWidget(
                                icon: Icons.admin_panel_settings,
                                title: 'Gestión de roles',
                                color: primaryColor,
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => GestionRolesList()));
                                },
                              ),
                            if (tienePermiso('Usuarios'))
                              MenuItemWidget(
                                icon: Icons.group,
                                title: 'Usuarios',
                                color: primaryColor,
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => UsuariosList()));
                                },
                              ),
                          ],
                        ),
                    ],

                    // CONFIGURACIÓN
                    if (tienePermiso('Ajustes del sistema') || tienePermiso('Usuarios (Configuración)') || tienePermiso('Ayuda y soporte')) ...[
                      SectionTitleWidget(title: 'Configuración', color: primaryColor),
                      if (tienePermiso('Ajustes del sistema'))
                        MenuItemWidget(
                          icon: Icons.settings_outlined,
                          title: 'Ajustes del sistema',
                          color: primaryColor,
                        ),
                      if (tienePermiso('Usuarios (Configuración)'))
                        MenuItemWidget(
                          icon: Icons.people_outlined,
                          title: 'Usuarios (Configuración)',
                          color: primaryColor,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => UsuariosList()));
                          },
                        ),
                      if (tienePermiso('Ayuda y soporte'))
                        MenuItemWidget(
                          icon: Icons.help_outline,
                          title: 'Ayuda y soporte',
                          color: primaryColor,
                        ),
                    ],
                  ]),
                ),
              ),

              // FOOTER
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          icon: Icon(Icons.logout, size: 20, color: Colors.red.shade400),
                          label: Text('Cerrar sesión', style: TextStyle(color: Colors.red.shade400)),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Cierra el Drawer primero
                            Provider.of<UserSession>(context, listen: false).cerrarSesion(context);
                          },

                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'v1.0.0',
                        style: theme.textTheme.bodySmall?.copyWith(color: onSurfaceColor.withOpacity(0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
