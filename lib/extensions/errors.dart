class KeyError implements Exception {
  String cause;
  KeyError(this.cause);
}

class ValueError implements Exception {
  String cause;
  ValueError(this.cause);
}

class TypeError implements Exception {
  String cause;
  TypeError(this.cause);
}
