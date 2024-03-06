// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_company2/fluttertoast.dart';
import 'package:my_company2/models.dart';
import 'package:my_company2/comapnies/editComapnyTile.dart';
import 'package:my_company2/comapnies/addComapnyTile.dart';


class CompanyPage extends StatefulWidget {
  final String groupId;
  final Function() onGroupUpdated;

  CompanyPage({required this.groupId, required this.onGroupUpdated});

  @override
  _CompanyPageState createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {

  
 Future<void> confirmDeleteCompany(String companyId, String companyName) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete $companyName?'),
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
                      .doc(widget.groupId)
                      .collection('companies')
                      .doc(companyId)
                      .delete();

                  widget.onGroupUpdated();
                  showToast("Company deleted successfully", Colors.green);
                } catch (error) {
                  showToast("Error deleting company", Colors.red);
                }

                Navigator.of(context).pop(); // Close the confirmation dialog
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
        title: Text('Company Page'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('companies')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<CompanyList> companyList = snapshot.data!.docs.map(
            (DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return CompanyList(
                companyName: data['companyName'],
                companyLogo: data['companyLogo'],
              );
            },
          ).toList();

          return ListView.builder(
            itemCount: companyList.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.network(companyList[index].companyLogo),
                title: Text(companyList[index].companyName),
                subtitle: Text('Additional company details'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return EditCompanyDialog(
                              groupId: widget.groupId,
                              companyId: snapshot.data!.docs[index].id,
                              companyName: companyList[index].companyName,
                              companyLogo: companyList[index].companyLogo,
                              onCompanyUpdated: () =>
                              widget.onGroupUpdated(),
                            );
                          },
                        );
                      },
                    ),
                     IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  confirmDeleteCompany(
                      snapshot.data!.docs[index].id,
                      companyList[index].companyName,
                  );
                },
              ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddCompanyDialog(
                  groupId: widget.groupId, onGroupUpdated: () => widget.onGroupUpdated());
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
