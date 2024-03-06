import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_company2/fluttertoast.dart';



class EditGroupDialog extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupLogo;
  final Function(DocumentReference) onGroupUpdated;

  EditGroupDialog({
    required this.groupId,
    required this.groupName,
    required this.groupLogo,
    required this.onGroupUpdated,
  });

  @override
  _EditGroupDialogState createState() => _EditGroupDialogState();
}

class _EditGroupDialogState extends State<EditGroupDialog> {
  late TextEditingController _nameController;
  late TextEditingController _logoController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.groupName);
    _logoController = TextEditingController(text: widget.groupLogo);
  }

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Group'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Group Name'),
          ),
          TextField(
            controller: _logoController,
            decoration: InputDecoration(labelText: 'Group Logo URL'),
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
                  .update({
                'groupName': _nameController.text,
                'groupLogo': _logoController.text,
              });

              widget.onGroupUpdated(
                  FirebaseFirestore.instance.collection('groups').doc(widget.groupId));

              showToast("Group updated successfully", Colors.green);
            } catch (error) {
              showToast("Error updating group", Colors.red);
            }

            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
