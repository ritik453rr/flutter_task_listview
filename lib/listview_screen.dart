import 'dart:convert';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/model/data_model.dart';
import 'package:task/utils/app_color.dart';

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
  GlobalKey<FormState> formkey = GlobalKey();
  GlobalKey<FormState> updatekey = GlobalKey();
  List<DataModel> userList = [];
  List<DataModel> selectedItems = [];
  bool addFieldActive = false;
  bool isUpdating = false;
  // bool bottomSheetActive = false;
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
      for (String element in userStringList) {
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
    final height = MediaQuery.of(context).size.height;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (selectedItems.isNotEmpty) {
          setState(() {
            selectedItems.clear();
          });
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.backgroundColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: selectedItems.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(bottom: 35, right: 8),
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.orange[500],
                  tooltip: "Add",
                  onPressed: () {
                    setState(
                      () {
                        addFieldActive = !addFieldActive;
                      },
                    );
                  },
                  label: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              )
            : const Text(""),
        //Bottom Sheet...........
        bottomSheet: selectedItems.isNotEmpty
            ? Container(
                height: 70,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      selectedItems.length == 1
                          //Edit Button......
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: InkWell(
                          onTap: () {
                            if (!isUpdating) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: const Text(
                                      "Delete this data?",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "No",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await deleteData(
                                              itemList: selectedItems);
                                          getData();
                                        },
                                        child: const Text(
                                          "Yes",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
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
                    padding: EdgeInsets.only(
                        bottom: selectedItems.isNotEmpty ? 68 : 5),
                    child: ListView.builder(
                        itemCount: userList.length,
                        itemBuilder: (context, index) {
                          DateTime date = DateTime.now();
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 1.5),
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
                              //User Lile....
                              child: Card(
                                elevation: 1,
                                child: SizedBox(
                                  height: height * 0.116,
                                  child: ListTile(
                                    onTap: () {
                                      if (addFieldActive) {
                                      } else {
                                        if (selectedItems.isNotEmpty) {
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
                                        }
                                      }
                                    },
                                    onLongPress: () {
                                      if (addFieldActive) {
                                      } else {
                                        setState(() {
                                          if (selectedItems
                                              .contains(userList[index])) {
                                            selectedItems
                                                .remove(userList[index]);
                                          } else {
                                            selectedItems.add(userList[index]);
                                          }
                                        });
                                      }
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    tileColor: isTileHovered
                                        ? hoverIndex == index
                                            ? AppColor.hoverColor
                                            : AppColor.tileColor
                                        : AppColor.tileColor,
                                    //Name....
                                    title: Text(
                                      '${userList[index].name}',
                                      style: TextStyle(
                                          fontSize: height * 0.022,
                                          fontWeight: FontWeight.w800),
                                    ),
                                    //Number....
                                    subtitle: Text(
                                      "${userList[index].number}\n${date.day}-0${date.month}-${date.year}",
                                      style: TextStyle(
                                          fontSize: height * 0.0175,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w400),
                                    ),
                                    trailing: Transform.scale(
                                      scale: 1,
                                      child: selectedItems.isNotEmpty
                                          ? Checkbox(
                                              activeColor: Colors.orange,
                                              shape: const CircleBorder(),
                                              value: selectedItems
                                                  .contains(userList[index]),
                                              onChanged: (value) {
                                                setState(() {
                                                  if (selectedItems.contains(
                                                      userList[index])) {
                                                    selectedItems.remove(
                                                        userList[index]);
                                                  } else {
                                                    selectedItems
                                                        .add(userList[index]);
                                                  }
                                                });
                                              },
                                            )
                                          : const Text(""),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  )
                : Center(
                    child: Text(
                      "Empty List",
                      style: TextStyle(
                          fontSize: 28.5,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400),
                    ),
                  ),
            //Add Field Start...
            addFieldActive
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        height: 260,
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
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
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
                              const Flexible(
                                child: SizedBox(height: 18),
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
                                  onPressed: () async {
                                    if (formkey.currentState!.validate()) {
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
                                      addFieldActive = false;
                                      getData();
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
                        height: 270,
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
                                        borderSide: const BorderSide(
                                            color: Colors.black),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            const BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.black),
                                      ),
                                      hintStyle: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                      hintText: "Enter Name"),
                                ),
                              ),
                              //Space...
                              const SizedBox(
                                height: 8,
                              ),
                              //Number Field
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
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
                                        borderSide: const BorderSide(
                                            color: Colors.black),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            const BorderSide(color: Colors.red),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.black),
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
                                padding: const EdgeInsets.only(top: 10),
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
                                                  name:
                                                      updateNameController.text,
                                                  number: updateNumberController
                                                      .text,
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
                : const Text(""),
          ],
        ),
      ),
    );
  }
}
