import 'package:exam/codeEditor.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
      title: 'Server',
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic data;

  @override
  void initState() {
    super.initState();
    getIp();
  }

  void getIp() async {
    await NetworkInterface.list(type: InternetAddressType.IPv4)
        .then((value) => data = value[0].addresses[0].address);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Server $data'),
        actions: [
          IconButton(
            onPressed: getIp,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: const ListScreen(),
    );
  }
}

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late ApiService apiService;
  late Future<List<dynamic>> itemsFuture;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    apiService =
        ApiService('http://127.0.0.1:8000'); // Replace with your API URL
    itemsFuture = apiService.getItems();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students Programs'), actions: [
        IconButton(
          onPressed: getData,
          icon: const Icon(Icons.refresh),
        )
      ]),
      body: FutureBuilder<List<dynamic>>(
        future: itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var item = snapshot.data![index];
                return ListTile(
                  title: Text(item['text']),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(width: 2, color: Colors.white),
                  ),
                  subtitle: Text('User: ${item['username']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CodeEditor(
                          code: item['text'],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text("No items found"));
          }
        },
      ),
    );
  }
}
