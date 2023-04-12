import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(ProviderScope(child:  MyApp()));
}

final tasksProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier( tasks: [
    Task(id: 1, label: "Load the rocket"),
    Task(id: 2, label: "Launch rocket"),
    Task(id: 3, label: "Circle the home planet") ,
    Task(id: 4, label: "Head out to the first moon"),
    Task(id: 5, label : "Launch moon lander #1")
  ]);
});

final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier( products : [
    Product(id: 1, name: "huevos Pequeños", units: 3),
    Product(id: 2, name: "huevos Grandes", units: 3),
    Product(id: 3, name: "huevos Medianos", units: 3),
    Product(id: 4, name: "huevos que me faltan para declararme a mi crush", units: 0)
  ] );
});




class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  List<Product> listModel = [];

  Future<Null> fetchProducts() async {
    final response = await http
        .get(Uri.parse('https://jmp.iv.o-app.xyz/items'));

    List<Product> listModel = [];

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      final data = jsonDecode(response.body);
      for (var prod in data) {
        listModel.add(new Product(id: prod['id'], name: prod['name'], units: prod['units']));
      }
      print(listModel);

    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print('Liadinha');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  @override


  Widget build(BuildContext context,  WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LIST OF PRODUCTS!'),
      ),
      body:
         ProductList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _dialogBuilder(context, ref),
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),


    ),
    );
  }
}
class ProductList extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    var products = ref.watch(productProvider);


    return Column(
      children: products.map((product) => ProductItem(product: product), ).toList(),
    );
  }
}

class ProductItem extends ConsumerWidget {

  final Product product;

  const ProductItem({Key? key,  required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(product.name),
      subtitle: Text(product.units.toString()),
      trailing: Icon(Icons.chevron_right),
      onTap: () => print('tapped'),
    );


  }

}
Future<void> _dialogBuilder(BuildContext context,  WidgetRef ref) {

  final nameController = TextEditingController();
  final unitsController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    unitsController.dispose();
  }

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add New Product'),
        content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
              Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: nameController,
              )
              ),
              Padding(
              padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: unitsController,
                  )
              ),
              ]
            )
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Submit'),
            onPressed: () {
              ref.read(productProvider.notifier).add(new Product(id: 4, name: nameController.text, units: int.parse(unitsController.text)));
              Navigator.of(context).pop();
            },
          ),
        ],

      );
    },
  );
}
@immutable
class Product {
  final int id;
  final String name;
  final int units;

  Product({required this.id, required this.name, required this.units});

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        units = json['units'];

  Map<String, dynamic> toJson() => {
    'id' : id,
    'name': name,
    'units' : units,
  };

  Product copyWith({int? id, String? name, int? units}) {
    return Product(
        id: id ?? this.id,
        name: name ?? this.name,
        units: units ?? this.units);
  }
}

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier({products}) : super(products);

  void add(Product product) {
    print('KLK');
    print(state);
    state = [...state, product];
    print(state);
  }


}

class Progress extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tasks = ref.watch(tasksProvider);

    var numCompletedTasks = tasks.where((task) {
      return task.completed == true;
    }).length;

    return Column(
      children: [
        Text("You are this far from descovering the whole universe"),
        LinearProgressIndicator(value: numCompletedTasks/tasks.length),

      ],
    );
  }
}

class TaskList extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    var tasks = ref.watch(tasksProvider);


    return Column(
      children: tasks.map((task) => TaskItem(task: task), ).toList(),
    );
  }
}

class TaskItem extends ConsumerWidget {
  final Task task;



  const TaskItem({Key? key,  required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Checkbox(
          onChanged: (newValue) =>
              ref.read(tasksProvider.notifier).toggle(task.id),
          value : task.completed,
        ),
        Text(task.label),
      ],
    );
  }
}

@immutable
class Task {
  final int id;
  final String label;
  final bool completed;

  Task({required this.id, required this.label, this.completed = false});

  Task copyWith({int? id, String? label, bool? completed}) {
    return Task(
        id: id ?? this.id,
        label: label ?? this.label,
        completed: completed ?? this.completed);
  }
}

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier({tasks}) : super(tasks);

  void add(Task task) {
    state = [...state, task];
  }

  void toggle(int taskId) {
    state = [
      for (final item in state)
        if (taskId == item.id)
          item.copyWith(completed: !item.completed)
        else
          item
    ];
  }
}


