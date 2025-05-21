part of 'product_bloc.dart';

sealed class ProductState extends Equatable{ 
  const ProductState();
  @override
  List<Object> get props => [];
}

final class ProductInitial extends ProductState{}

final class ProductLoadInProgress extends ProductState {}

final class ProductLoadFailure extends ProductState {}

final class ProductLoadSuccess extends ProductState {}
