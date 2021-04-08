


import 'IList.dart';

class NormalList<E> extends IList<E> {

  @override
  E get(int index) {
    return this[index];
  }

  void set(int index, E val) {
    this[index] = val;
  }

  noSuchMethod(Invocation invocation)
  => super.noSuchMethod(invocation);
}