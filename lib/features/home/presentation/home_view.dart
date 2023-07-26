import 'dart:developer';
import 'dart:io';

import 'package:crud_app/data/db/dbservice.dart';
import 'package:crud_app/data/model/student_details_model.dart';
import 'package:crud_app/features/add_student/presentation/add_student_view.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final StudentDb hiveMethods = StudentDb();
  List<StudentDetailsModel> studentdetailsList = [];
  bool isLoading = true;
  final int itemsPerPage = 4;
  int currentPage = 1;
  int currentIndex = 0;

  Widget buildPagination() {
    final int totalPages = (studentdetailsList.length / itemsPerPage).ceil();

    return Padding(
      padding: const EdgeInsets.only(right: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Previous button
          if (totalPages > 2)
            GestureDetector(
              onTap: () {
                if (currentPage > 1) {
                  setState(() {
                    currentPage--;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),

          ...List.generate(
            totalPages > 2 ? 2 : totalPages,
            (index) {
              final pageNumber = index + 1;
              currentIndex = pageNumber + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    currentPage = pageNumber;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: pageNumber == currentPage || pageNumber > 3
                        ? Colors.amber
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '$pageNumber',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
          if (totalPages > 2)
            GestureDetector(
              onTap: () {
                setState(() {
                  currentPage = currentIndex;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: currentIndex == currentPage || currentPage > 2
                      ? currentPage < 2
                          ? Colors.grey
                          : Colors.amber
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "${currentPage < 3 ? 3 : currentPage}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          if (totalPages > 2)
            GestureDetector(
              onTap: () {
                if (currentPage < totalPages) {
                  setState(() {
                    currentPage++;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void showSnackBar({required String message, required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 2),
      backgroundColor: color,
      content: Text(message),
    ));
  }

  void searchStudent(String searchString) {
    setState(
      () {
        if (searchString.isNotEmpty) {
          studentdetailsList = studentdetailsList
              .where((item) =>
                  item.name
                      .toLowerCase()
                      .contains(searchString.toLowerCase()) ||
                  item.gender
                      .toLowerCase()
                      .contains(searchString.toLowerCase()) ||
                  item.country
                      .toLowerCase()
                      .contains(searchString.toLowerCase()) ||
                  item.date.toLowerCase().contains(searchString.toLowerCase()))
              .toList();
        } else {
          fetchStudentDetails();
        }
      },
    );
  }

  Future<void> fetchStudentDetails() async {
    final usersData = await hiveMethods.getAllStudentDetailsList();
    log(usersData.length.toString());
    studentdetailsList = usersData;
    setState(() {
      isLoading = false;
    });
  }

  void deleteStudentDetails({required int index}) async {
    await hiveMethods.deleteStudentDetails(index);
    await fetchStudentDetails();
    const snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text("Successfully Deleted"),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  List<StudentDetailsModel> studentListPagination() {
    final int startIndex = (currentPage - 1) * itemsPerPage;
    final int endIndex = startIndex + itemsPerPage;
    if (studentdetailsList.length < endIndex) {
      return studentdetailsList.sublist(startIndex, studentdetailsList.length);
    } else {
      return studentdetailsList.sublist(startIndex, endIndex);
    }
  }

  @override
  void initState() {
    fetchStudentDetails();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EasySearchBar(
          elevation: 0.5,
          title: const Text(
            "Students Details",
            style: TextStyle(color: Colors.white),
          ),
          onSearch: (value) {
            searchStudent(value);
          }),
      body: Center(
        child: SingleChildScrollView(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : studentdetailsList.isNotEmpty
                  ? RefreshIndicator(
                      onRefresh: () async {
                        Future.delayed(const Duration(seconds: 4));
                        return fetchStudentDetails();
                      },
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.79,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(15),
                              itemCount: studentListPagination().length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.58),
                              itemBuilder: (context, index) {
                                final studentdetails =
                                    studentListPagination()[index];

                                return SizedBox(
                                  height: 150,
                                  child: Card(
                                    elevation: 3,
                                    surfaceTintColor: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: SizedBox(
                                                    height: 150,
                                                    width: 180,
                                                    child: Image.file(
                                                      fit: BoxFit.cover,
                                                      File(studentdetails
                                                          .imagePath),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "Name : ${studentdetails.name}",
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                                Text(
                                                    "Age : ${studentdetails.age}",
                                                    style: const TextStyle(
                                                        fontSize: 13)),
                                                Text(
                                                    "gender : ${studentdetails.gender}",
                                                    style: const TextStyle(
                                                        fontSize: 13)),
                                                Text(
                                                    "Dob : ${studentdetails.date}",
                                                    style: const TextStyle(
                                                        fontSize: 13)),
                                                Text(
                                                    "Country : ${studentdetails.country}",
                                                    style: const TextStyle(
                                                        fontSize: 13))
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            child: IconButton(
                                              onPressed: () async {
                                                deleteStudentDetails(
                                                    index: index);
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: -8,
                                            right: -8,
                                            child: IconButton(
                                              onPressed: () async {
                                                var result =
                                                    await Navigator.push<bool>(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddStudentView(
                                                      countryCode:
                                                          studentdetails
                                                              .countryCode,
                                                      index: index,
                                                      isVisibleAddButton: false,
                                                      appBarTittleName:
                                                          "Update Student",
                                                      studentName:
                                                          studentdetails.name,
                                                      studentAge:
                                                          studentdetails.age,
                                                      studentDob:
                                                          studentdetails.date,
                                                      studentCountry:
                                                          studentdetails
                                                              .country,
                                                      studentGender:
                                                          studentdetails.gender,
                                                      studentImage:
                                                          studentdetails
                                                              .imagePath,
                                                    ),
                                                  ),
                                                );
                                                if (result != null &&
                                                    result == true) {
                                                  showSnackBar(
                                                      message:
                                                          "Successfully Updated",
                                                      color: Colors.blue);
                                                  await fetchStudentDetails();
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                                size: 17,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          buildPagination(),
                          const SizedBox(
                            height: 15,
                          )
                        ],
                      ),
                    )
                  : const Center(child: Text("No Student Data Found")),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddStudentView(
                index: 0,
                isVisibleAddButton: true,
                appBarTittleName: "Add student",
                studentName: "",
                studentAge: "",
                studentDob: "",
                studentCountry: "",
                studentImage: null,
                countryCode: "+91",
              ),
            ),
          );
          if (result != null && result == true) {
            showSnackBar(message: "Successfully Added", color: Colors.green);
            await fetchStudentDetails();
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
