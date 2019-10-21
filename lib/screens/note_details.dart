import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
final String appBarTitle ;
final Note note;
NoteDetail (this.note, this.appBarTitle);

  _NoteDetailState createState() => _NoteDetailState(this.note, this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  String appBarTitle ;
  Note note;
  _NoteDetailState (this.note, this.appBarTitle);

  static var _priorities = ["High", "Low"];
	DatabaseHelper helper = DatabaseHelper();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {

    titleController.text = note.title;
    descriptionController.text = note.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Padding(padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
      child: ListView(
        children: <Widget>[
          // Drop
          ListTile(
            title: DropdownButton(
              items: _priorities.map((String dropDownStringItem){
              return DropdownMenuItem(
                value: dropDownStringItem,
                child: Text(dropDownStringItem),
              );
              }).toList(),
              value: getPriorityAsString(note.priority),
              onChanged: (valueSelectedByUser){
                setState(() {
                  debugPrint('User selected $valueSelectedByUser');
                  updatePriorityAsInt(valueSelectedByUser);
                });
              },
            ),
          ),
         
          // title
          Padding(padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: TextField(
            controller: titleController,
            onChanged: (value){
              updateTitle();
            },
            decoration: InputDecoration(
              labelText: "Title",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0)
              )
            ),
          ),
          ),
          
          // description
          Padding(padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: TextField(
            controller: descriptionController,
            onChanged: (value){
              updateDescription();
            },
            decoration: InputDecoration(
              labelText: "Desc",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0)
              )
            ),
          ),
          ),          
          Padding(
            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    child: Text("Save", textScaleFactor: 1.5,),
                    onPressed: (){
                      setState(() {
                      if(titleController.text.isNotEmpty){                    
                        _save();
                      }else{
           		      	_showAlertDialog('Status', 'You Should write title at least');             
                      }
                      }
                      );
                    },
                  ),
                ),
                SizedBox(width: 10.0,),
                  Expanded(
                  child: RaisedButton(
                    child: Text("Delete", textScaleFactor: 1.5,),
                    onPressed: (){
                      setState(() {
                        _delete();
                      });
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),  
      ),
    );
  }
  // Convert the String priority in the form of integer before saving it to Database
	void updatePriorityAsInt(String value) {
		switch (value) {
			case 'High':
				note.priority = 1;
				break;
			case 'Low':
				note.priority = 2;
				break;
		}
	}
	// Convert int priority to String priority and display it to user in DropDown
	String getPriorityAsString(int value) {
		String priority;
		switch (value) {
			case 1:
				priority = _priorities[0];  // 'High'
				break;
			case 2:
				priority = _priorities[1];  // 'Low'
				break;
		}
		return priority;
	}
  // Update the title of Note object
  void updateTitle(){
    note.title = titleController.text;
  }

	// Update the description of Note object
	void updateDescription() {
		note.description = descriptionController.text;
	}
// Save data to database
	void _save() async {

		moveToLastScreen();

		note.date = DateFormat.yMMMd().format(DateTime.now());
		int result;
		if (note.id != null) {  // Case 1: Update operation
			result = await helper.updateNote(note);
		} else { // Case 2: Insert Operation
			result = await helper.insertNote(note);
		}

		if (result != 0) {  // Success
			_showAlertDialog('Status', 'Note Saved Successfully');
		} else {  // Failure
			_showAlertDialog('Status', 'Problem Saving Note');
		}

	}

  	void _delete() async {

		moveToLastScreen();

		// Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
		// the detail page by pressing the FAB of NoteList page.
		if (note.id == null) {
			_showAlertDialog('Status', 'No Note was deleted');
			return;
		}

		// Case 2: User is trying to delete the old note that already has a valid ID.
		int result = await helper.deleteNote(note.id);
		if (result != 0) {
			_showAlertDialog('Status', 'Note Deleted Successfully');
		} else {
			_showAlertDialog('Status', 'Error Occured while Deleting Note');
		}
	}

	void _showAlertDialog(String title, String message) {

		AlertDialog alertDialog = AlertDialog(
			title: Text(title),
			content: Text(message),
		);
		showDialog(
				context: context,
				builder: (_) => alertDialog
		);
	}

void moveToLastScreen() {
		Navigator.pop(context, true);
  }

}