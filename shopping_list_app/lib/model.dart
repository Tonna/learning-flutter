

class Product {
  final int _id;
  final String _name;
  final List<ProductStateChange> _stateLog;

  Product(this._id, this._name, this._stateLog);

  int get id => _id;

  String get name => _name;

  List<ProductStateChange> get stateLog => _stateLog;

  Map<String, dynamic> toMap() {
    return {'id': _id, 'name': _name};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Product &&
              _id == other._id &&
              _name == other._name &&
              _stateLog == other._stateLog;

  @override
  int get hashCode => _id.hashCode ^ _name.hashCode ^ _stateLog.hashCode;

  @override
  String toString() {
    return 'Product{_id: $_id, _name: $_name, _stateLog: $_stateLog}';
  }
}

enum ProductState {
  //using enum value position for sorting
  //TODO come up with better, less implicit solution
  active,
  notActive
}

class ProductStateChange {
  final int _id;
  final ProductState _state;
  final DateTime _at;

  int get id => _id;

  ProductState get state => _state;

  DateTime get at => _at;

  ProductStateChange(this._id, this._state, this._at);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ProductStateChange &&
              _id == other._id &&
              _state == other._state &&
              _at == other._at;

  @override
  int get hashCode => _id.hashCode ^ _state.hashCode ^ _at.hashCode;

  String toString() {
    return '{$_id, $_state, at $_at}';
  }
}

ProductState getStateObject(String state) {
  switch (state) {
    case "active":
      return ProductState.active;
      break;
    case "notActive":
      return ProductState.notActive;
      break;
    default:
      throw new Exception("not expected StateChange value $state");
  }
}

String getStateString(ProductState state) {
  switch (state) {
    case ProductState.active:
      return "active";
      break;
    case ProductState.notActive:
      return "notActive";
      break;
    default:
      throw new Exception("not expected StateChange value $state");
  }
}