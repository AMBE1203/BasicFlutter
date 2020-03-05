import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_components/custom/asymmetric_view.dart';
import 'package:material_components/model/product.dart';
import 'package:material_components/model/products_repository.dart';

class HomePage extends StatelessWidget {

  final Category category;
  const HomePage({this.category: Category.all});

  @override
  Widget build(BuildContext context) {
    return AsymmetricView(
        products: ProductsRepository.loadProducts(Category.all));
  }
}
