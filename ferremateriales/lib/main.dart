
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'features/productos/bloc/product_bloc.dart';
  import 'features/productos/views/initial_view.dart';
  import 'features/productos/views/products_view.dart';
  import 'views/failure_view.dart';
  import 'views/loading_view.dart';


  void main() {
    runApp(Ferreteria());
  }

  class Ferreteria extends StatelessWidget {
    const Ferreteria({super.key});

    @override
    Widget build(BuildContext context) {
      return BlocProvider(
        create: (context) => ProductBloc(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoadInProgress) {
                return LoadingView();
              } else if (state is ProductLoadFailure) {
                return FailureView();
              } else if (state is ProductLoadSuccess) {
                return ProductsPageView();
              } else if (state is ProductInitial) {
                return InitialView();
              }
              return InitialView();
            },
          ),
        ),
      );
    }
  }

































