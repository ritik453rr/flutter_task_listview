import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/model/data_model.dart';

class ListViewScrenn extends StatefulWidget {
  const ListViewScrenn({super.key});

  @override
  State<ListViewScrenn> createState() => _ListViewScrennState();
}

class _ListViewScrennState extends State<ListViewScrenn> {
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  List<DataModel> userList = [];
  bool bottomSheet = false;

  //Set Data...
  Future<void> setData({required DataModel data}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userStringList = prefs.getStringList('userList') ?? [];
    userStringList.add(jsonEncode(data.toJson()));
    prefs.setStringList('userList', userStringList);
  }

  //Get Data....
  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userStringList = prefs.getStringList('userList') ?? [];
    if (userStringList.isNotEmpty) {
      userList = [];
      for (var element in userStringList) {
        userList.add(DataModel.fromJson(jsonDecode(element)));
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: bottomSheet
          ? Container(
              color: Colors.black87,
              height: 200,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(hintText: "Enter Name"),
                    ),
                    TextField(
                      controller: numberController,
                      decoration: InputDecoration(hintText: "Enter Number"),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    //Add Button...
                    TextButton(
                        onPressed: () async {
                          await setData(
                              data: DataModel(
                                  name: nameController.text,
                                  number: numberController.text));
                          setState(() {
                            nameController.text = "";
                            numberController.text = "";
                          });
                          getData();
                        },
                        child: const Text("Add"))
                  ],
                ),
              ),
            )
          : const Text(""),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            bottomSheet = !bottomSheet;
          });
        },
        label: const Icon(Icons.add),
      ),
      body: userList.isNotEmpty
          ? Padding(
              padding: bottomSheet
                  ? const EdgeInsets.only(bottom: 200)
                  : const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 4),
                      child: SizedBox(
                        height: 75,
                        child: Card(
                          child: ListTile(
                            title: Text('${userList[index].name}'),
                            subtitle: Text("${userList[index].number}"),
                            trailing:
                                Checkbox(value: false, onChanged: (value) {}),
                          ),
                        ),
                      ),
                    );
                  }),
            )
          : const Center(
              child: Text("Empty List"),
            ),
    );
  }
}
