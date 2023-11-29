class Disposable {
  bool _isDisposed = false;

  /// Throw's [StateError] if this object is disposed. For internal use only.
  void ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError("Object is disposed");
    }
  }

  /// Destroys any resources related to this. This must never be used after a call to [dispose]. You must ensure to call [dispose] after you're done using this to avoid memory leaks
  void dispose() {
    ensureNotDisposed();
    _isDisposed = true;
  }
}
