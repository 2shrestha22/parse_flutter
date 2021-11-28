import 'dart:convert';
import 'dart:math';

import 'package:example/models/pc.dart';
import 'package:flutter/material.dart';
import 'package:parse_sdk/parse_sdk.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final cpuTextEditingController = TextEditingController();
  final ramTextEditingController = TextEditingController();
  final diskTextEditingController = TextEditingController();

  Future<List<PC>> getPCs() async {
    final res = await ParseObject().query('PC').get();
    return (jsonDecode(res)['results'] as List)
        .map((e) => PC.fromMap(e))
        .toList();
  }

  Future<List<PC>> queryPCs() async {
    final res = await ParseObject()
        .query('PC')
        .where('createdAt', isLessThanOrEqualTo: DateTime(2021, 11, 28))
        .where('cpu', isLessThanOrEqualTo: '60', isNotEqualTo: '35')
        .orderByAscending('createdAt')
        .limit(50)
        .get();
    return (jsonDecode(res)['results'] as List)
        .map((e) => PC.fromMap(e))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parse SDK Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Form(
              child: Column(
                children: [
                  TextFormField(
                    controller: cpuTextEditingController
                      ..text = Random().nextInt(100).toString(),
                    decoration: const InputDecoration(
                      labelText: 'CPU Usage %',
                      isDense: true,
                    ),
                  ),
                  TextFormField(
                    controller: ramTextEditingController
                      ..text = Random().nextInt(100).toString(),
                    decoration: const InputDecoration(
                      labelText: 'RAM Usage %',
                      isDense: true,
                    ),
                  ),
                  TextFormField(
                    controller: diskTextEditingController
                      ..text = Random().nextInt(100).toString(),
                    decoration: const InputDecoration(
                      labelText: 'Disk Usage %',
                      isDense: true,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      debugPrint(
                          identical(ParseObject(), ParseObject()).toString());
                      ParseObject()
                          .create(
                        className: 'PC',
                        data: PC(
                          cpu: cpuTextEditingController.text,
                          ram: ramTextEditingController.text,
                          disk: diskTextEditingController.text,
                        ).toMap(),
                      )
                          .then((value) {
                        setState(() {});
                      });
                    },
                    child: const Text('Save Data'),
                  ),
                ],
              ),
            ),

            // where query
            const Text('Query PCs'),
            FutureBuilder<List<PC>>(
              future: queryPCs(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: snapshot.data!
                        .map((e) => Row(
                              children: [
                                Expanded(child: Text('CPU ${e.cpu} %')),
                                Expanded(child: Text('RAM ${e.ram} %')),
                                Expanded(child: Text('Disk ${e.disk} %')),
                                Expanded(
                                    child: Text(e.createdAt
                                        .toString()
                                        .substring(0, 10))),
                              ],
                            ))
                        .toList(),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            // List all objects from PC class
            const Text('All PCs'),
            FutureBuilder<List<PC>>(
              future: getPCs(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: snapshot.data!
                        .map((e) => Row(
                              children: [
                                Expanded(child: Text('CPU ${e.cpu} %')),
                                Expanded(child: Text('RAM ${e.ram} %')),
                                Expanded(child: Text('Disk ${e.disk} %')),
                              ],
                            ))
                        .toList(),
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
