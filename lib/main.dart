import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(ProviderScope(child:  MyApp()));
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


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

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var loading = false;
  List<Product> listModel = [];

  void delete(BuildContext context) {

  }


  Future<void> _dialogBuilder(BuildContext context, String name, String units, int id, int option) {

    final nameController = TextEditingController();
    final unitsController = TextEditingController();
    nameController.text = name;
    unitsController.text = units;
    Future<Null> addProducts(name, units) async {

      if(option == 1 ) {   //add
        await http.post(
          Uri.parse('https://jmp.iv.o-app.xyz/items'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'name': name,
            'units' : units
          }),
        );
      }
      else if (option == 2){ //edit
        await http.put(
          Uri.parse('https://jmp.iv.o-app.xyz/items/${id}'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'name': name,
            'units' : units
          }),
        );
      }
      else {
        await http.delete(
          Uri.parse('https://jmp.iv.o-app.xyz/items/${id}')
        );
      }


      Future.delayed(const Duration(milliseconds: 1000), () {
        fetchProducts();
      });

    }
    @override
    void dispose() {
      // Clean up the controller when the widget is disposed.
      nameController.dispose();
      unitsController.dispose();
    }
    if (option == 1 || option == 2) {
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
                            decoration: const InputDecoration(labelText: 'Name'),
                            controller: nameController,
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: const InputDecoration(labelText: 'Units'),
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
                  // ref.read(productProvider.notifier).add(new Product(id: 4, name: nameController.text, units: int.parse(unitsController.text)));
                  addProducts(nameController.text, int.parse(unitsController.text));
                  Navigator.of(context).pop();

                },
              ),
            ],

          );
        },
      );
    }
    else  { //Dialog for elimination
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Product'),
            content: Form(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Are you sure you want to delete this item?'
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
                child: const Text('Delete'),
                onPressed: () {
                  // ref.read(productProvider.notifier).add(new Product(id: 4, name: nameController.text, units: int.parse(unitsController.text)));
                  addProducts(nameController.text, int.parse(unitsController.text));
                  Navigator.of(context).pop();

                },
              ),
            ],

          );
        },
      );
    }

  } // DIALOG BUILDER




  Future<Null> fetchProducts() async {

    setState(() {
      loading = true;
    });




    final response = await http
        .get(Uri.parse('https://jmp.iv.o-app.xyz/items'));

    listModel.clear();

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      final data = jsonDecode(response.body);
      for (var prod in data) {
        listModel.add(new Product(id: prod['id'], name: prod['name'], units: prod['units']));
      }
      setState(() {
        loading = false;
      });


    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print('F');
      print(response.body);
    }
  }
  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('LIST OF PRODUCTS!'),
      ),
      body:

      Container(

        child: loading ? Center (child: CircularProgressIndicator()) : ListView.builder(
        itemCount: listModel.length,
        itemBuilder: (context, i){
        // final nDataList = listModel[i];
          return
            Slidable(
              // Specify a key if the Slidable is dismissible.
              key: const ValueKey(0),

          // The start action pane is the one at the left or the top side.
          startActionPane: ActionPane(
                // A motion is a widget used to control how the pane animates.
                motion: const ScrollMotion(),

                // A pane can dismiss the Slidable.
                dismissible: DismissiblePane(onDismissed: () {
                  _dialogBuilder(context, listModel[i].name, listModel[i].units.toString(), listModel[i].id, 3);
                }),

                // All actions are defined in the children parameter.
                children:  [
                // A SlidableAction can have an icon and/or a label.
                SlidableAction(
                onPressed: (_) => {_dialogBuilder(_, listModel[i].name, listModel[i].units.toString(), listModel[i].id, 3)},
                backgroundColor: Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
                ),

                ],
                ),
              endActionPane:  ActionPane(
                motion: ScrollMotion(),

                children: [
                  SlidableAction(
                    // An action can be bigger than the others.

                    onPressed: (_) => {_dialogBuilder(_, listModel[i].name, listModel[i].units.toString(), listModel[i].id, 2)},
                    backgroundColor: Color(0xFF7BC043),
                    foregroundColor: Colors.white,
                    icon: Icons.archive,
                    label: 'Edit',
                  ),

                ],
              ),

          child: InkWell(
            onTap: () => {
              _dialogBuilder(context, listModel[i].name, listModel[i].units.toString(), listModel[i].id, 2),  // :)
            },
            onDoubleTap: () => {    _dialogBuilder(context,  listModel[i].name, listModel[i].units.toString(), listModel[i].id, 3) },
            child:
            ProductItem(product: listModel[i])
            ,
          ),
            );

        }

    ),

    ),
        floatingActionButton: FloatingActionButton(
        onPressed: () {
          _dialogBuilder(context, '', '', 0, 1);
        },
    backgroundColor: Colors.red,
    child: const Icon(Icons.add),
    ),


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

    );

  }

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


