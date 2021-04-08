
import 'IMap.dart';

class NormalMap<K, V> implements IMap<K, V> {

  @override
  V get(K key) {
    return this[key];
  }

  @override
  void put(K key, V val) {
    this[key] = val;
  }

  noSuchMethod(Invocation invocation)
  => super.noSuchMethod(invocation);
}