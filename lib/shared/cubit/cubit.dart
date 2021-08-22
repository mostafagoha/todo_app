import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:to_do_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:to_do_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:to_do_app/shared/componants/constants.dart';
import 'package:to_do_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialStates());

  static AppCubit get(context) => BlocProvider.of(context);

  Database database;

  int currentIndex = 0;
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = [
    'New Task',
    'Done Task',
    'Archived Task',
  ];
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavState());
  }

  void createDatabase() {
    openDatabase(
      'todoapp.db',
      version: 1,
      onCreate: (database, version) async {
        print('database is created');
        await database.execute(
          'CREATE TABLE task (id INTEGER PRIMARY KEY,title TEXT,date TEXT,time TEXT,status TEXT)',
        );
        print('table is created');
      },
      onOpen: (database) {
        getDataFromDatabase(database);
        print('database is opened');
      },
    ).then((value) {
      database = value;
      emit(CreateDataBase());
    });
  }

  insertToDatabase({
    @required String title,
    @required String time,
    @required String date,
  }) async {
    await database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO task(title , date , time , status) VALUES("$title" , "$date" , "$time" , "new")')
          .then((value) {
        print('$value inserted successfully');
        emit(InsertDataBase());

        getDataFromDatabase(database);
      }).catchError((error) {
        print('this is an error${error.toString()}');
      });
      return null;
    });
  }

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(GetDataFromDateBaseLoading());
    database.rawQuery('SELECT * FROM task').then((value) {
      // newTasks = value;
      // print(newTasks);
      value.forEach((element) {
        if (element['status'] == 'new')
          newTasks.add(element);
        else if (element['status'] == 'done')
          doneTasks.add(element);
        else
          archivedTasks.add(element);
      });
      emit(GetDataFromDateBase());
    });
  }

  void updateData({
    @required String status,
    @required int id,
  }) {
    database.rawUpdate(
      'UPDATE task SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value) {
      getDataFromDatabase(database);
      emit(UpdateDataBase());
    });
  }

  void deleteData({
    @required int id,
  }) {
    database.rawDelete(
      'DELETE FROM task WHERE id = ?', [id],

    ).then((value) {
      getDataFromDatabase(database);
      emit(DeleteDataBase());
    });
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
    @required bool isShow,
    @required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    fabIcon = icon;

    emit(AppChangeBottomNavState());
  }
}
