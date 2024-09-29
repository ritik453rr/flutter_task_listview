import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/model/data_model.dart';

class ListViewScreen extends StatefulWidget {
  const ListViewScreen({super.key});

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController updateNameController = TextEditingController();
  TextEditingController updateNumberController = TextEditingController();
  List<DataModel> userList = [];
  bool addFieldActive = false;
  bool isUpdating = false;
  bool deleteBottomSheetActive = false;
  GlobalKey<FormState> formkey = GlobalKey();
  GlobalKey<FormState> updatekey = GlobalKey();
  List<DataModel> selectedItems = [];
  bool isTileHovered = false;
  int? hoverIndex;

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
    userList = [];
    if (userStringList.isNotEmpty) {
      for (var element in userStringList) {
        userList.add(DataModel.fromJson(jsonDecode(element)));
      }
    }
    setState(() {});
  }

  //Delete Data
  Future<void> deleteData({required List<DataModel> itemList}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userStringList = prefs.getStringList('userList') ?? [];
    selectedItems = [];
    List<DataModel> tempUserList = [];
    if (userStringList.isNotEmpty) {
      for (String element in userStringList) {
        tempUserList.add(DataModel.fromJson(jsonDecode(element)));
      }
      for (DataModel item in itemList) {
        tempUserList.removeWhere((element) => element.name == item.name);
      }
      List<String> stringUserList = [];
      for (DataModel item in tempUserList) {
        stringUserList.add(
          jsonEncode(
            item.toJson(),
          ),
        );
      }
      prefs.setStringList('userList', stringUserList);
    }
  }

  //Update Data....
  Future<void> updateData({required DataModel data}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userStringList = prefs.getStringList('userList') ?? [];
    List<DataModel> tempUserList = [];
    if (userStringList.isNotEmpty) {
      for (String element in userStringList) {
        tempUserList.add(DataModel.fromJson(jsonDecode(element)));
      }

      int index = tempUserList.indexWhere((element) => element.id == data.id);
      tempUserList[index] = data;
      List<String> stringUserList = [];
      for (DataModel item in tempUserList) {
        stringUserList.add(
          jsonEncode(
            item.toJson(),
          ),
        );
      }
      prefs.setStringList('userList', stringUserList);
      selectedItems = [];
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
      backgroundColor: Colors.blueGrey[50],
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.orange[500],
          shape: const CircleBorder(),
          tooltip: "Add",
          onPressed: () {
            setState(() {
              addFieldActive = !addFieldActive;
            });
          },
          label: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      //Bottom Sheet...........
      bottomSheet: selectedItems.isNotEmpty
          ? Container(
              height: 70,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(top: 11, bottom: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    selectedItems.length == 1
                        //Edit Button......
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 9),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  isUpdating = true;
                                  updateNameController.text =
                                      selectedItems[0].name ?? "null";
                                  updateNumberController.text =
                                      selectedItems[0].number ?? "null";
                                });
                              },
                              child: const Column(
                                children: [Icon(Icons.edit), Text("Edit")],
                              ),
                            ),
                          )
                        : const Text(""),
                    //Delete Button.....
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: InkWell(
                        onTap: () async {
                          await deleteData(itemList: selectedItems);
                          getData();
                        },
                        child: const Column(
                          children: [Icon(Icons.delete), Text("Delete")],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Text(""),
      body: Stack(
        children: [
          userList.isNotEmpty
              ? Padding(
                  padding: addFieldActive
                      ? const EdgeInsets.only(top: 8, bottom: 185)
                      : const EdgeInsets.only(top: 8, bottom: 65),
                  child: ListView.builder(
                      itemCount: userList.length,
                      itemBuilder: (context, index) {
                        //User Lile....
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 1.5),
                          child: SizedBox(
                            height: 80,
                            child: MouseRegion(
                              onEnter: (event) {
                                setState(() {
                                  isTileHovered = true;
                                  hoverIndex = index;
                                });
                              },
                              onExit: (event) {
                                setState(() {
                                  isTileHovered = false;
                                });
                              },
                              child: Card(
                                elevation: 1.5,
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  tileColor: isTileHovered
                                      ? hoverIndex == index
                                          ? Colors.grey[300]
                                          : Colors.white
                                      : Colors.white,
                                  //Name....
                                  title: Text(
                                    '${userList[index].name}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    "${userList[index].number}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  trailing: Transform.scale(
                                    scale: 1,
                                    child: Checkbox(
                                        activeColor: Colors.orange,
                                        shape: const CircleBorder(),
                                        value: selectedItems
                                            .contains(userList[index]),
                                        onChanged: (value) {
                                          setState(() {
                                            if (selectedItems
                                                .contains(userList[index])) {
                                              selectedItems
                                                  .remove(userList[index]);
                                            } else {
                                              selectedItems
                                                  .add(userList[index]);
                                            }
                                          });
                                        }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                )
              : const Center(
                  child: Text("Empty List"),
                ),
          addFieldActive
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      height: 250,
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black87, width: 1.5),
                      ),
                      child: Form(
                        key: formkey,
                        child: Column(
                          children: [
                            //Space..
                            const SizedBox(
                              height: 20,
                            ),
                            //Name Field
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "enter name";
                                  } else {
                                    return null;
                                  }
                                },
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                                controller: nameController,
                                decoration: InputDecoration(
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 1.5),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          width: 1.5, color: Colors.black87),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          width: 1.5, color: Colors.black87),
                                    ),
                                    hintStyle: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                    hintText: "Enter Name"),
                              ),
                            ),
                            //Space...
                            const SizedBox(
                              height: 6,
                            ),
                            Flexible(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: TextFormField(
                                  validator: (value) {
                                    final regex = RegExp(r'^[6-9]\d{9}$');
                                    if (value == null || value.isEmpty) {
                                      return "enter number";
                                    } else if (!regex.hasMatch(value)) {
                                      return "enter valid number";
                                    }

                                    {
                                      return null;
                                    }
                                  },
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                  controller: numberController,
                                  decoration: InputDecoration(
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.red, width: 1.5),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.red, width: 1.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.black, width: 1.5),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.black87, width: 1.5),
                                      ),
                                      hintStyle: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                      hintText: "Enter Number"),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            //Add Button...
                            Container(
                              height: 40,
                              width: 90,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  if (formkey.currentState!.validate()) {
                                    setState(() async {
                                      await setData(
                                        data: DataModel(
                                            name: nameController.text,
                                            number: numberController.text,
                                            id: DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString()),
                                      );
                                      nameController.text = "";
                                      numberController.text = "";
                                      getData();
                                      addFieldActive = false;
                                    });
                                  }
                                },
                                child: const Text(
                                  "Add",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const Text(""),
          //Update Field Start......
          isUpdating
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      height: 250,
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black87, width: 1.5),
                      ),
                      child: Form(
                        key: updatekey,
                        child: Column(
                          children: [
                            //Space..
                            const SizedBox(
                              height: 15,
                            ),
                            //Name Field
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: TextFormField(
                                cursorColor: Colors.black,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "enter name";
                                  } else {
                                    return null;
                                  }
                                },
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                                controller: updateNameController,
                                decoration: InputDecoration(
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.black),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.red),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.black),
                                    ),
                                    hintStyle: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                    hintText: "Enter Name"),
                              ),
                            ),
                            //Space...
                            const SizedBox(
                              height: 15,
                            ),
                            //Number Field
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: TextFormField(
                                cursorColor: Colors.black,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "enter number";
                                  } else {
                                    return null;
                                  }
                                },
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                                controller: updateNumberController,
                                decoration: InputDecoration(
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.black),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.red),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                    hintStyle: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                    hintText: "Enter Number"),
                              ),
                            ),
                            //Row[Cancel,Update]....
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //Cancel Button
                                  Container(
                                    height: 35,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(9),
                                      color: Colors.black,
                                    ),
                                    child: TextButton(
                                      onPressed: () async {
                                        setState(() {
                                          isUpdating = false;
                                        });
                                      },
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  //Update Button...
                                  Container(
                                    height: 35,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(9),
                                      color: Colors.black,
                                    ),
                                    child: TextButton(
                                      onPressed: () async {
                                        if (updatekey.currentState!
                                            .validate()) {
                                          isUpdating = false;
                                          await updateData(
                                            data: DataModel(
                                                name: updateNameController.text,
                                                number:
                                                    updateNumberController.text,
                                                id: selectedItems[0].id),
                                          );
                                          getData();
                                        }
                                      },
                                      child: const Text(
                                        "Update",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Text(""),
        ],
      ),
    );
  }
}
