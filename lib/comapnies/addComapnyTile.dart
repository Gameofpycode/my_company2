// ignore_for_file: file_names, prefer_const_constructors_in_immutables, library_private_types_in_public_api, use_build_context_synchronously, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_company2/fluttertoast.dart';



class AddCompanyDialog extends StatefulWidget {
  final String groupId;
  final Function() onGroupUpdated;

  AddCompanyDialog({required this.groupId,required this.onGroupUpdated});

  @override
  _AddCompanyDialogState createState() => _AddCompanyDialogState();
}

class _AddCompanyDialogState extends State<AddCompanyDialog>{
  late TextEditingController _nameController;
  late TextEditingController _logoController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _logoController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Company'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Company Name'),
          ),
          TextField(
            controller: _logoController,
            decoration: InputDecoration(labelText: 'Company Logo URL'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            try {
              await FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('companies')
                  .add({
                'companyName': _nameController.text,
                'companyLogo': _logoController.text,
              });

              widget.onGroupUpdated();
              showToast("Company added successfully", Colors.green);
            } catch (error) {
              showToast("Error adding company", Colors.red);
            }

            Navigator.of(context).pop();
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
