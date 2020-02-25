import 'package:flutter/foundation.dart';
import 'package:simple_app/models/catalog.dart';

class CartModel extends ChangeNotifier {
  CatalogModel _catalog;

  final List<int> _itemIds = [];

  // current catalog
  CatalogModel get catalog => _catalog;

  set catalog(CatalogModel newCatalog) {
    assert(newCatalog != null);
    assert(_itemIds.every((id) => newCatalog.getById(id) != null),
    'The catalog $newCatalog does not have one of $_itemIds in it.');
    _catalog = newCatalog;
    notifyListeners();
  }

  // list of items in the cart

  List<Item> get items => _itemIds.map((id) => _catalog.getById(id)).toList();

  // get total price of all items
  int get totalPrice =>
      items.fold(0, (total, current) => total + current.price);

// add item to cart
  void add(Item item) {
    _itemIds.add(item.id);
    notifyListeners();
  }

}
