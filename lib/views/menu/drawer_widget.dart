import 'package:flutter/material.dart';
import 'package:inventrax/views/clientes/clientes_form.dart';
import 'package:inventrax/views/clientes/clientes_list.dart';

import '../../test.dart';
import '../../widgets/widget_drawer/Custom_Expansion_Widget.dart';
import '../../widgets/widget_drawer/MenuItemWidget.dart';
import '../../widgets/widget_drawer/Section_Title_Widget.dart';
import '../categorias/categorias_form.dart';
import '../categorias/categorias_list.dart';
import '../catologo/productos_form.dart';
import '../catologo/productos_list.dart';
import '../entradas_producto/entradas_form.dart';
import '../provedores/provedor_form.dart';
import '../provedores/provedor_list.dart';
import '../salida_producto/salida_list.dart';
import '../ventas/ventas_form.dart';
import '../ventas/ventas_list.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark
        ? Colors.tealAccent.shade400
        : Colors.teal.shade700;
    final surfaceColor = isDark
        ? Colors.grey.shade900.withOpacity(0.8)
        : Colors.white;
    final onSurfaceColor = isDark ? Colors.white : Colors.black;

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
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: Icon(
                        Icons.person_outline,
                        color: primaryColor,
                        size: 24,
                      ),
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
                      'Administración del sistema',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onSurfaceColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Secciones del menú
          SliverPadding(
            padding: const EdgeInsets.only(top: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SectionTitleWidget(
                  title: 'Gestión Comercial',
                  color: primaryColor,
                ),
                CustomExpansionTileWidget(
                  icon: Icons.point_of_sale_outlined,
                  title: 'Ventas',
                  color: primaryColor,
                  children: [
                    MenuItemWidget(
                      icon: Icons.receipt_long,
                      title: 'Registro de Ventas',
                      color: primaryColor,
                      onTap: () {
                        Navigator.pop(context); // Cierra el drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => VentasFormScreen()),
                        );
                      },
                    ),
                    MenuItemWidget(
                      icon: Icons.list_alt,
                      title: 'Detalle de Ventas',
                      color: primaryColor,
                      onTap: () {
                        Navigator.pop(context); // Cierra el drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => VentaListScreen()),
                        );
                      },
                    ),
                    MenuItemWidget(
                      icon: Icons.people_outlined,
                      title: 'Clientes',
                      color: primaryColor,
                      onTap: () {
                        Navigator.pop(context); // Cierra el drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClientesListScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                SectionTitleWidget(
                  title: 'Gestión de Inventario',
                  color: primaryColor,
                ),
                CustomExpansionTileWidget(
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventario',
                  color: primaryColor,
                  children: [
                    //MenuItemWidget(
    //icon: Icons.compare_arrows,
    //title: 'Movimientos',
    // color: primaryColor,
                    //),
                    MenuItemWidget(
                      icon: Icons.input,
                      title: 'Entradas',
                      color: primaryColor,
                      onTap: () {
                        Navigator.pop(context); // Cierra el drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => InventarioScreen()),
                        );
                      },
                    ),
                    MenuItemWidget(
                      icon: Icons.output,
                      title: 'Salidas',
                      color: primaryColor,
                      onTap: () {
                        Navigator.pop(context); // Cierra el drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => VentasScreen()),
                        );
                      },
                    ),

                  ],
                ),

                CustomExpansionTileWidget(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Productos',
                  color: primaryColor,
                  children: [
                    MenuItemWidget(
                      icon: Icons.grid_view,
                      title: 'Productos',
                      color: primaryColor,
                      onTap: () {
                        Navigator.pop(context); // Cierra el drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductoListScreen(),
                          ),
                        );
                      },
                    ),
                    MenuItemWidget(
                      icon: Icons.category,
                      title: 'Categorías',
                      color: primaryColor,
                      onTap: () {
                        Navigator.pop(context); // Cierra el drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoriaListScreen(),
                          ),
                        );
                      },
                    ),
              // MenuItemWidget(
              // icon: Icons.label,
              //     title: 'Marcas',
              //   color: primaryColor,
    //   onTap: () {
    //     Navigator.pop(context); // Cierra el drawer
    //     Navigator.push(
    //       context,
    //      MaterialPageRoute(builder: (_) => TestDashboard()),
    //    );
              //  },
                    //  ),
                  ],
                ),

                SectionTitleWidget(
                  title: 'Administración',
                  color: primaryColor,
                ),
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
                        Navigator.pop(context); // Cierra el drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProveedorListScreen(),
                          ),
                        );
                      },
                    ),
              //  MenuItemWidget(
              //   icon: Icons.shopping_cart,
              //    title: 'Órdenes de Compra',
              //    color: primaryColor,
                    //  ),
                  ],
                ),

                CustomExpansionTileWidget(
                  icon: Icons.manage_accounts,
                  title: 'Usuarios',
                  color: primaryColor,
                  children: [
                    MenuItemWidget(
                      icon: Icons.person_add,
                      title: 'Registro',
                      color: primaryColor,
                    ),
                    MenuItemWidget(
                      icon: Icons.security,
                      title: 'Permisos',
                      color: primaryColor,
                    ),
                  ],
                ),
              ]),
            ),
          ),

          /// Sección secundaria
          SliverPadding(
            padding: const EdgeInsets.only(top: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SectionTitleWidget(title: 'Configuración', color: primaryColor),
                MenuItemWidget(
                  icon: Icons.settings_outlined,
                  title: 'Ajustes del sistema',
                  color: primaryColor,
                ),
                MenuItemWidget(
                  icon: Icons.people_outlined,
                  title: 'Usuarios',
                  color: primaryColor,
                ),
                MenuItemWidget(
                  icon: Icons.help_outline,
                  title: 'Ayuda y soporte',
                  color: primaryColor,
                ),
              ]),
            ),
          ),

          /// Pie de página
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      icon: Icon(
                        Icons.logout,
                        size: 20,
                        color: Colors.red.shade400,
                      ),
                      label: Text(
                        'Cerrar sesión',
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'v2.4.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onSurfaceColor.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
