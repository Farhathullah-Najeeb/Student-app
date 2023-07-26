import 'dart:developer';

import 'package:crud_app/data/model/student_details_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StudentDb {
  String hiveBox = 'student';

  //Adding user model to hive db
  Future<void> addStudentDetails(StudentDetailsModel userModel) async {
    var box = await Hive.openBox(hiveBox); //open the hive box before writing
    var mapUserData = userModel.toMap();
    await box.add(mapUserData);
    Hive.close(); //closing the hive box
  }

  //Reading all the users data
  Future<List<StudentDetailsModel>> getAllStudentDetailsList() async {
    var box = await Hive.openBox(hiveBox);
    List<StudentDetailsModel> studentDetailsList = [];

    for (int i = 0; i < box.length; i++) {
      var userMap = box.getAt(i);
      studentDetailsList.add(StudentDetailsModel.fromMap(userMap));
    }
    log(studentDetailsList.toString());
    return studentDetailsList;
  }

  Future<void> updateStudentDetails(
      {required int index,
      required StudentDetailsModel studentDetailsModel}) async {
    var studentBox = await Hive.openBox(hiveBox);
    var studentDetails = studentDetailsModel.toMap();
    await studentBox.putAt(index, studentDetails);
    getAllStudentDetailsList();
  }

  //Deleting one data from hive DB
  Future<void> deleteStudentDetails(int id) async {
    var box = await Hive.openBox(hiveBox);
    await box.deleteAt(id);
    getAllStudentDetailsList();
  }

  //Deleting whole data from Hive
  Future<void> deleteAllUsers() async {
    var box = await Hive.openBox(hiveBox);
    await box.clear();
  }
}
