
abstract class IMap<K, V> implements Map<K, V> {

  V get(K key);

  void put(K key, V val);
}