import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_company2/firebase_options.dart';
import 'package:my_company2/fluttertoast.dart';
import 'package:my_company2/models.dart';
import 'package:my_company2/comapnies/companyListPage.dart';
import 'package:my_company2/editGroupdailog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference groups =
      FirebaseFirestore.instance.collection('groups');

  int selectedTileIndex = -1; // Initially no tile selected

  Future<void> updateGroupLength(DocumentReference groupRef) async {
    try {
      int companyCount = await groupRef
          .collection('companies')
          .get()
          .then((value) => value.size);

      await groupRef.update({'groupLength': companyCount});

      showToast("Group updated successfully", Colors.green);
    } catch (error) {
      showToast("Error updating group", Colors.red);
    }
  }

  Future<void> addNewGroupCollection(String groupName) async {
    try {
      await groups.doc(groupName).set({
        'groupName': groupName,
        'groupLogo': 'default_logo_url',
      });

      showToast("Group collection added successfully", Colors.green);
    } catch (error) {
      showToast("Error adding group collection", Colors.red);
    }
  }

  Future<void> showAddGroupCollectionDialog() async {
    TextEditingController _groupNameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Group Collection'),
          content: TextField(
            controller: _groupNameController,
            decoration: InputDecoration(labelText: 'Group Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String groupName = _groupNameController.text;
                if (groupName.isNotEmpty) {
                  await addNewGroupCollection(groupName);
                  Navigator.of(context).pop();
                } else {
                  showToast("Group name cannot be empty", Colors.red);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showDeleteConfirmationDialog(
      String groupId, String groupName) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete the group "$groupName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('groups')
                      .doc(groupId)
                      .delete();
                  showToast("Group deleted successfully", Colors.green);
                  Navigator.of(context).pop();
                } catch (error) {
                  showToast("Error deleting group", Colors.red);
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: StreamBuilder(
        stream: groups.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<GroupOfCompany> groupOfCompanies = snapshot.data!.docs.map(
            (DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return GroupOfCompany(
                groupName: data['groupName'],
                groupLogo: data['groupLogo'],
                groupLength: data['groupLength'] ?? 0,
              );
            },
          ).toList();

          return ListView.builder(
            itemCount: groupOfCompanies.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    // Toggle selection
                    selectedTileIndex =
                        (selectedTileIndex == index) ? -1 : index;
                  });
                },
                onDoubleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompanyPage(
                        groupId: snapshot.data!.docs[index].id,
                        onGroupUpdated: () =>
                            updateGroupLength(groups.doc(snapshot.data!.docs[index].id)),
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Add logo here'),
                  ),
                  title: Text(groupOfCompanies[index].groupName),
                  subtitle: Text('Companies: ${groupOfCompanies[index].groupLength}'),
                  trailing: (selectedTileIndex == index)
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return EditGroupDialog(
                                      groupId: snapshot.data!.docs[index].id,
                                      groupName: groupOfCompanies[index].groupName,
                                      groupLogo: groupOfCompanies[index].groupLogo,
                                      onGroupUpdated: (groupRef) =>
                                          updateGroupLength(groupRef),
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                showDeleteConfirmationDialog(
                                    snapshot.data!.docs[index].id,
                                    groupOfCompanies[index].groupName);
                              },
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddGroupCollectionDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
