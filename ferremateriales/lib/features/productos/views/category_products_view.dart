import 'package:ferremateriales/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_list.dart';

class CategoryProductsView extends StatefulWidget {
  final String categoryName;

  const CategoryProductsView({super.key, required this.categoryName});

  @override
  State<CategoryProductsView> createState() => _CategoryProductsViewState();
}

class _CategoryProductsViewState extends State<CategoryProductsView> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductFilterByCategory(widget.categoryName));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.brown.shade700,
      ),
      backgroundColor: const Color(0xFFFDF7F4),
      body: SafeArea(
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductLoadSuccess) {
              if (state.productos.isEmpty) {
                return Center(
                  child: Text(l10n.donthaveproductcategory),
                );
              }

              return SingleChildScrollView( // 👈 Esto evita el overflow
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.productsin} ${widget.categoryName}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade700,
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
