extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) predicate) => 
    map((items) => items.where(predicate).toList());
}