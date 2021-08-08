


import "IList.dart";

class JArrayList<E> extends IList<E> {

  @override
  E get(int index) {
    return this[index];
  }

  void set(int index, E val) {
    this[index] = val;
  }

  void noSuchMethod(Invocation invocation)
  => super.noSuchMethod(invocation);
}