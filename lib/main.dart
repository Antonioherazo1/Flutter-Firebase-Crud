// import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_crud/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform
      // options: FirebaseOptions(
      //   apiKey: "AIzaSyBxiI7er3ZT1w65TWvaVu-9_e-VlxLVK8k", // Your apiKey
      //   appId: "1:750935514151:web:64aefa2a868dc2631f4202", // Your appId
      //   messagingSenderId: "750935514151", // Your messagingSenderId
      //   projectId: "crud-flutter-firebase-94cc5", // Your projectId
      // ),
      );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');

  // await _products.add({'name':name, 'price': price});
  // await _products.update({'name':name, 'price': price});
  // await _products.doc(productId).delete();

  final TextEditingController _nameContoller = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameContoller.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameContoller,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: const Text('Update'),
                onPressed: () async {
                  final String name = _nameContoller.text;
                  final double? price = double.tryParse(_priceController.text);
                  if (price != null) {
                    await _products
                        .doc(documentSnapshot!.id)
                        .update({'name': name, 'price': price});
                    _nameContoller.text = '';
                    _priceController.text = '';
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameContoller.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameContoller,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: const Text('Add'),
                onPressed: () async {
                  final String name = _nameContoller.text;
                  final double? price = double.tryParse(_priceController.text);
                  if (price != null) {
                    await _products.add({'name': name, 'price': price});
                    _nameContoller.text = '';
                    _priceController.text = '';
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _delete(String productId) async {
    await _products.doc(productId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You Have successfully deleted a product'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: StreamBuilder(
          stream: _products.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: ((context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(documentSnapshot['name']),
                      subtitle: Text(documentSnapshot['price'].toString()),
                      trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () => _update(documentSnapshot),
                                  icon: const Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () => _delete(documentSnapshot.id),
                                  icon: const Icon(Icons.delete))
                            ],
                          )),
                    ),
                  );
                }),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
