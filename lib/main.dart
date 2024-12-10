import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return AnimatedContainer(
                duration: const Duration(seconds: 1),
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  /// [ValueNotifier] for managing the state of the items.
  late final ValueNotifier<List<T>> _itemsNotifier;

  @override
  void initState() {
    super.initState();
    _itemsNotifier = ValueNotifier<List<T>>(widget.items.toList());
  }

  @override
  void dispose() {
    _itemsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: ValueListenableBuilder<List<T>>(
        valueListenable: _itemsNotifier,
        builder: (context, items, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: items.asMap().entries.map((entry) {
              int index = entry.key;
              T item = entry.value;
              return DragTarget<T>(
                onAccept: (receivedItem) {
                  final fromIndex = items.indexOf(receivedItem);
                  if (fromIndex != -1) {
                    // Update the items in the notifier
                    items.removeAt(fromIndex);
                    items.insert(index, receivedItem);
                    _itemsNotifier.value = List.from(items);
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  return Draggable<T>(
                    data: item,
                    feedback: widget.builder(item),
                    childWhenDragging: Container(),
                    //select comment if calling class DockItem
                    child: /*widget.builder(
                        item),*/
                        DockItem<T>(item: item, builder: widget.builder),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

//this works better for pc
class DockItem<T> extends StatefulWidget {
  final T item;
  final Widget Function(T) builder;

  const DockItem({Key? key, required this.item, required this.builder})
      : super(key: key);

  @override
  _DockItemState<T> createState() => _DockItemState<T>();
}

class _DockItemState<T> extends State<DockItem<T>> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => scale = 1.1),
      onExit: (_) => setState(() => scale = 1.0),
      child: Transform.scale(
        scale: scale,
        child: widget.builder(widget.item),
      ),
    );
  }
}
