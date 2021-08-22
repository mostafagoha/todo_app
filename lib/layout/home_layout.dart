import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:to_do_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:to_do_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:to_do_app/shared/componants/componants.dart';
import 'package:to_do_app/shared/componants/constants.dart';
import 'package:to_do_app/shared/cubit/cubit.dart';
import 'package:to_do_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is InsertDataBase) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);

          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.currentIndex]),
            ),
            body: ConditionalBuilder(
              condition: state is! GetDataFromDateBaseLoading,
              builder: (context)=>cubit.screens[cubit.currentIndex],
              fallback: (context)=>Center(child: CircularProgressIndicator(),),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (_formKey.currentState.validate()) {
                    cubit.insertToDatabase(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text,
                    );
                  } else {
                    return null;
                  }
                } else {
                  scaffoldKey.currentState
                      .showBottomSheet((context) => Container(
                            padding: EdgeInsets.all(20.0),
                            color: Colors.grey[100],
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  defaultFormField(
                                    controller: titleController,
                                    type: TextInputType.text,
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return 'Title must not be empty';
                                      } else {
                                        return null;
                                      }
                                    },
                                    label: 'Title',
                                    prefix: Icons.title,
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  defaultFormField(
                                      controller: timeController,
                                      type: TextInputType.datetime,
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return 'Time must not be empty';
                                        } else {
                                          return null;
                                        }
                                      },
                                      label: 'Task Time',
                                      prefix: Icons.watch_later_outlined,
                                      onTap: () {
                                        showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        ).then((value) {
                                          timeController.text =
                                              value.format(context);
                                          print(value.format(context));
                                        });
                                      }),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  defaultFormField(
                                      controller: dateController,
                                      type: TextInputType.datetime,
                                      validator: (String value) {
                                        if (value.isEmpty) {
                                          return 'Date must not be empty';
                                        } else {
                                          return null;
                                        }
                                      },
                                      label: 'Task Date',
                                      prefix: Icons.calendar_today,
                                      onTap: () {
                                        showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate:
                                              DateTime.parse('2022-05-04'),
                                        ).then((value) {
                                          dateController.text =
                                              DateFormat.yMMMd().format(value);
                                        });
                                      }),
                                ],
                              ),
                            ),
                          ))
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(
                        isShow: false, icon: Icons.edit);
                  });
                  cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(cubit.fabIcon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline), label: 'Done'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined), label: 'Archived'),
              ],
            ),
          );
        },
      ),
    );
  }

  void deleteFromDatabase() {}
}

// tasks.length <= 0
// ? Center(
// child: CircularProgressIndicator(),
// )
// :
