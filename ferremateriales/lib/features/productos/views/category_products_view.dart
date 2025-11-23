import 'package:ferremateriales/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
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

class _CategoryProductsViewState extends State<CategoryProductsView> {
  @override
  void initState() {
    super.initState();
    // El ProductBloc ahora filtra desde caché si está disponible
    context
        .read<ProductBloc>()
        .add(ProductFilterByCategory(widget.categoryId));
  }

  @override
  Widget build(BuildContext context) {
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
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoadInProgress) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: LoadingShimmer(isGrid: true), // 👈 Use the new shimmer
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
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.donthaveproductcategory,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${l10n.productsin} ${widget.displayName}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF222222),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ProductsList(products: state.productos),
                  ],
                ),
              );
            } else if (state is ProductLoadFailure) {
              return Center(
                child: Text(l10n.errorLoadingProducts),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
