import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_company2/fluttertoast.dart';

class EditCompanyDialog extends StatefulWidget {
  final String groupId;
  final String companyId;
  final String companyName;
  final String companyLogo;
  final Function() onCompanyUpdated;

  EditCompanyDialog({
    required this.groupId,
    required this.companyId,
    required this.companyName,
    required this.companyLogo,
    required this.onCompanyUpdated,
  });

  @override
  _EditCompanyDialogState createState() => _EditCompanyDialogState();
}

class _EditCompanyDialogState extends State<EditCompanyDialog> {
  late TextEditingController _nameController;
  late TextEditingController _logoController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.companyName);
    _logoController = TextEditingController(text: widget.companyLogo);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Company'),
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
                  .doc(widget.companyId)
                  .update({
                'companyName': _nameController.text,
                'companyLogo': _logoController.text,
              });

              widget.onCompanyUpdated();
              showToast("Company updated successfully", Colors.green);
            } catch (error) {
              showToast("Error updating company", Colors.red);
            }

            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}