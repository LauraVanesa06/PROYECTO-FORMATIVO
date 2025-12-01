import 'package:ferremateriales/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../model/product_model.dart';
import '../widgets/product_list.dart';
import '../widgets/loading_shimmer.dart'; // Import the shimmer widget

class CategoryProductsView extends StatefulWidget {
  final String categoryName;
  final int categoryId;
  final String displayName;

  const CategoryProductsView({
    super.key,
    required this.categoryName,
    required this.categoryId,
    required this.displayName,
  });

  @override
  State<CategoryProductsView> createState() => _CategoryProductsViewState();
}

class _CategoryProductsViewState extends State<CategoryProductsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Mantener el estado vivo

  String _sortOption = 'none'; // Opción de ordenamiento

  @override
  void initState() {
    super.initState();
    // Esperar a que el frame se renderice y verificar si los productos ya están cargados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final productBloc = context.read<ProductBloc>();
        final currentState = productBloc.state;

        // Si los productos ya están cargados, filtrar por categoría
        if (currentState is ProductLoadSuccess) {
          print(
            "Productos ya cargados, filtrando por categoría ${widget.categoryId}",
          );
          productBloc.add(ProductFilterByCategory(widget.categoryId));
        } else if (currentState is ProductInitial ||
            currentState is ProductLoadInProgress) {
          // Si aún no están cargados, cargar todos los productos primero
          print("Productos no cargados, cargando todos antes de filtrar");
          productBloc.add(CargarTodosLosProductos());
          // El filtro se aplicará automáticamente cuando se completen los productos
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              productBloc.add(ProductFilterByCategory(widget.categoryId));
            }
          });
        } else {
          // En cualquier otro caso, intentar filtrar
          productBloc.add(ProductFilterByCategory(widget.categoryId));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        elevation: 0,
        title: Text(
          widget.displayName,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF222222),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF222222),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determinar si es pantalla pequeña
            final isSmallScreen = constraints.maxWidth < 600;
            final horizontalPadding = isSmallScreen ? 12.0 : 24.0;

            return BlocBuilder<ProductBloc, ProductState>(
              buildWhen: (previous, current) {
                // Solo rebuilder si cambia el estado relevante para esta categoría
                if (current is ProductLoadSuccess &&
                    previous is ProductLoadSuccess) {
                  return current.productos != previous.productos;
                }
                return true;
              },
              builder: (context, state) {
                if (state is ProductLoadInProgress) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: LoadingShimmer(
                      isGrid: true,
                    ), // 👈 Use the new shimmer
                  );
                } else if (state is ProductLoadSuccess) {
                  if (state.productos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 100,
                            color:
                                isDark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.donthaveproductcategory,
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${l10n.productsin} ${widget.displayName}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark
                                            ? Colors.white
                                            : const Color(0xFF222222),
                                  ),
                                ),
                              ),
                              // Botón de filtro
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      _sortOption != 'none'
                                          ? const Color(0xFF2e67a3)
                                          : (isDark
                                              ? Colors.grey.shade800
                                              : Colors.white),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    setState(() {
                                      _sortOption = value;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.filter_list_rounded,
                                    color:
                                        _sortOption != 'none'
                                            ? Colors.white
                                            : (isDark
                                                ? Colors.grey.shade400
                                                : const Color(0xFF2e67a3)),
                                    size: 24,
                                  ),
                                  color:
                                      isDark
                                          ? Colors.grey.shade800
                                          : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  itemBuilder:
                                      (context) => [
                                        PopupMenuItem(
                                          value: 'none',
                                          child: Row(
                                            children: [
                                              Icon(
                                                _sortOption == 'none'
                                                    ? Icons.check_circle
                                                    : Icons.circle_outlined,
                                                color:
                                                    _sortOption == 'none'
                                                        ? const Color(
                                                          0xFF2e67a3,
                                                        )
                                                        : Colors.grey,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Sin ordenar',
                                                style: TextStyle(
                                                  color:
                                                      isDark
                                                          ? Colors.white
                                                          : Colors.black87,
                                                  fontWeight:
                                                      _sortOption == 'none'
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'name_asc',
                                          child: Row(
                                            children: [
                                              Icon(
                                                _sortOption == 'name_asc'
                                                    ? Icons.check_circle
                                                    : Icons.circle_outlined,
                                                color:
                                                    _sortOption == 'name_asc'
                                                        ? const Color(
                                                          0xFF2e67a3,
                                                        )
                                                        : Colors.grey,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Nombre A-Z',
                                                style: TextStyle(
                                                  color:
                                                      isDark
                                                          ? Colors.white
                                                          : Colors.black87,
                                                  fontWeight:
                                                      _sortOption == 'name_asc'
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'name_desc',
                                          child: Row(
                                            children: [
                                              Icon(
                                                _sortOption == 'name_desc'
                                                    ? Icons.check_circle
                                                    : Icons.circle_outlined,
                                                color:
                                                    _sortOption == 'name_desc'
                                                        ? const Color(
                                                          0xFF2e67a3,
                                                        )
                                                        : Colors.grey,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Nombre Z-A',
                                                style: TextStyle(
                                                  color:
                                                      isDark
                                                          ? Colors.white
                                                          : Colors.black87,
                                                  fontWeight:
                                                      _sortOption == 'name_desc'
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'price_asc',
                                          child: Row(
                                            children: [
                                              Icon(
                                                _sortOption == 'price_asc'
                                                    ? Icons.check_circle
                                                    : Icons.circle_outlined,
                                                color:
                                                    _sortOption == 'price_asc'
                                                        ? const Color(
                                                          0xFF2e67a3,
                                                        )
                                                        : Colors.grey,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Precio: Menor a Mayor',
                                                style: TextStyle(
                                                  color:
                                                      isDark
                                                          ? Colors.white
                                                          : Colors.black87,
                                                  fontWeight:
                                                      _sortOption == 'price_asc'
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'price_desc',
                                          child: Row(
                                            children: [
                                              Icon(
                                                _sortOption == 'price_desc'
                                                    ? Icons.check_circle
                                                    : Icons.circle_outlined,
                                                color:
                                                    _sortOption == 'price_desc'
                                                        ? const Color(
                                                          0xFF2e67a3,
                                                        )
                                                        : Colors.grey,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Precio: Mayor a Menor',
                                                style: TextStyle(
                                                  color:
                                                      isDark
                                                          ? Colors.white
                                                          : Colors.black87,
                                                  fontWeight:
                                                      _sortOption ==
                                                              'price_desc'
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ProductsList(products: _sortProducts(state.productos)),
                      ],
                    ),
                  );
                } else if (state is ProductLoadFailure) {
                  return Center(child: Text(l10n.errorLoadingProducts));
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          },
        ),
      ),
    );
  }

  // Método para ordenar productos según el filtro seleccionado
  List<ProductModel> _sortProducts(List<ProductModel> products) {
    if (_sortOption == 'none') {
      return products;
    }

    final sorted = List<ProductModel>.from(products);

    switch (_sortOption) {
      case 'name_asc':
        sorted.sort((a, b) => (a.nombre ?? '').compareTo(b.nombre ?? ''));
        break;
      case 'name_desc':
        sorted.sort((a, b) => (b.nombre ?? '').compareTo(a.nombre ?? ''));
        break;
      case 'price_asc':
        sorted.sort((a, b) => (a.precio ?? 0).compareTo(b.precio ?? 0));
        break;
      case 'price_desc':
        sorted.sort((a, b) => (b.precio ?? 0).compareTo(a.precio ?? 0));
        break;
    }

    return sorted;
  }
}
