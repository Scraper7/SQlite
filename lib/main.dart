import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workwithfiles_read_write/db/database.dart';
import 'package:workwithfiles_read_write/model/student.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite CRUD Demo',
      home: StudentPage(),
    );
  }
}

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();

  late Future<List<Student>> _studentsList;
  late String _studentName;
  bool isUpdate = false;
  int? studentIdForUpdate;

  @override
  void initState() {
    super.initState();
    updateStudentList();
  }

  updateStudentList() {
    setState(() {
      _studentsList = DBProvider.db.getStudent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SQLite CRUD Demo',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Form(
            key: _formStateKey,
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please Enter Student Name';
                  }
                  if (value.trim() == '') return 'Only Space is Not Valid!!!';
                  return null;
                },
                onSaved: (value) {
                  _studentName = value!;
                },
                controller: _studentNameController,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                        style: BorderStyle.solid),
                  ),
                  labelText: 'Student Name',
                  icon: Icon(
                    Icons.people,
                    color: Colors.black,
                  ),
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll<Color>(Colors.green)),
                onPressed: () {
                  if (_formStateKey.currentState!.validate()) {
                    _formStateKey.currentState!.save();
                    if (isUpdate) {
                      DBProvider.db
                          .updateStudent(
                              Student(studentIdForUpdate!, _studentName))
                          .then((data) {
                        setState(() {
                          isUpdate = false;
                          studentIdForUpdate = null;
                        });
                      });
                    } else {
                      DBProvider.db
                          .insertStudent(Student.withoutId(_studentName));
                    }
                    _studentNameController.text = '';
                    updateStudentList();
                  }
                },
                child: Text(
                  (isUpdate ? 'UPDATE' : 'ADD'),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll<Color>(Colors.red)),
                  child: Text(
                    (isUpdate ? 'CANCEL UPDATE' : 'CLEAR'),
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _studentNameController.text = '';
                    setState(() {
                      isUpdate = false;
                      studentIdForUpdate = null;
                    });
                  },
                ),
              ),
            ],
          ),
          Divider(
            height: 5.0,
          ),
          Expanded(
            child: FutureBuilder(
                future: _studentsList,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return generateList(snapshot.data as List<Student>);
                  }
                  if (snapshot.data == null ||
                      (snapshot.data as List<Student>).isEmpty) {
                    return Text('No data Found');
                  }
                  return CircularProgressIndicator();
                }),
          )
        ],
      ),
    );
  }

  SingleChildScrollView generateList(List<Student> students) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          columns: [
            DataColumn(
              label: Text('NAME'),
            ),
            DataColumn(
              label: Text('DELETE'),
            ),
          ],
          rows: students
              .map((student) => DataRow(cells: [
                    DataCell(Text(student.name), onTap: () {
                      setState(() {
                        isUpdate = true;
                        studentIdForUpdate = student.id;
                      });
                      _studentNameController.text = student.name;
                    }),
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          DBProvider.db.deleteStudent(student.id!);
                          updateStudentList();
                        },
                      ),
                    ),
                  ]))
              .toList(),
        ),
      ),
    );
  }
}
