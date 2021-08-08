import "package:flutter/material.dart";

class LoadingContainer extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final bool cover;

  LoadingContainer(
      {@required this.child, @required this.isLoading, this.cover = false});

  Widget get _loadingView {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return !cover
        ? !isLoading
            ? child
            : _loadingView
        : new Stack(
            children: <Widget>[child,
              isLoading
                ? _loadingView
                : const SizedBox.shrink()],
          );
  }
}
