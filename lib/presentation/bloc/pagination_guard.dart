
class PaginationGuard {
  bool _isFetching = false;

  bool get isFetching => _isFetching;

  bool start() {
    if (_isFetching) return false;
    _isFetching = true;
    return true;
  }

  void finish() => _isFetching = false;

  void reset() => _isFetching = false;
}
