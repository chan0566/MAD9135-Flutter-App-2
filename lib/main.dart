import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          textTheme: Theme.of(context).textTheme.copyWith(
              bodyLarge: TextStyle(fontSize: 24, color: Colors.white))),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> _screen = [HomePage(), DataPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screen[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.data_usage), label: 'Data'),
        ],
      ),
    );
  }
}

// HomePage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/yellow_cat.jpg'),
                      fit: BoxFit.cover)),
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.secondary,
              child: Center(
                child: Transform.rotate(
                  angle: 0.15,
                  child: Text(
                    "Hello World",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// DataPage

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  late Future<List<Product>> _data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _data = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Product>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error loading data');
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemBuilder: (context, index) {
                return Card(
                    child: ListTile(
                        leading: Image.network(snapshot.data![index].thumbnail),
                        title: Text(snapshot.data![index].title),
                        subtitle: Text(snapshot.data![index].description)));
              },
            );
          } else {
            return Text('No data');
          }
        },
      ),
    );
  }

  Future<List<Product>> fetchData() async {
    final response =
        await http.get(Uri.parse('https://dummyjson.com/products'));
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body)['products'];
      return jsonData
          .map((data) => Product(
              id: data['id'],
              title: data['title'],
              description: data['description'],
              thumbnail: data['thumbnail']))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class Product {
  final int id;
  final String title;
  final String description;
  final String thumbnail;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.thumbnail});
}
