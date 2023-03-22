import 'package:flutter/material.dart';
import 'package:labhouse_combinable_reorderable_scroll/reorderable_grid.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// create a new list of data
  final items = List<int>.generate(40, (index) => index);

  /// when the reorder completes remove the list entry from its old position
  /// and insert it at its new index
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CombinableReorderableGrid(
          onCombine: (draggedIndex, targetIndex) => items[targetIndex] += items[draggedIndex],
          canCombine: (draggingIndex, targetIndex) => draggingIndex.isEven == targetIndex.isEven,
          itemBuilder: (context, index) {
            final item = items[index];

            final list = SliverCombinableReorderableGrid.of(context);
            var color = item.isEven ? Colors.blue.shade200 : Colors.greenAccent.shade200;
            if (list.indexCombine == index) {
              color = Colors.pink;
            }
            return CombinableReorderableGridDelayedDragStartListener(
              // affinity: Axis.horizontal,
              delay: Duration(milliseconds: 200),
              index: item,
              key: ValueKey(item),
              child: Card(
                color: color,
                child: Center(
                  child: Text(item.toString()),
                ),
              ),
            );
          },
          itemCount: items.length,
          onReorder: _onReorder,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
        ),

        // CombinableReorderableGridView.extent(
        //   maxCrossAxisExtent: 150,
        //   onReorder: _onReorder,
        //   childAspectRatio: 1,
        //   children: items.map((item) {
        //     /// map every list entry to a widget and assure every child has a
        //     /// unique key
        //     return CombinableReorderableGridDragStartListener(
        //       affinity: Axis.horizontal,
        //       index: item,
        //       key: ValueKey(item),
        //       child: Card(
        //         color: item.isEven ? Colors.blue.shade200 : Colors.greenAccent.shade200,
        //         child: Center(
        //           child: Text(item.toString()),
        //         ),
        //       ),
        //     );
        //   }).toList(),
        // ),
      ),
    );
  }
}
