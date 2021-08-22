import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:to_do_app/shared/cubit/cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  @required Function function,
  @required String text,
}) =>
    Container(
      width: width,
      color: background,
      child: MaterialButton(
        onPressed: function,
        child: Text(
          text.toUpperCase(),
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );

Widget defaultFormField({
  @required TextEditingController controller,
  @required TextInputType type,
  Function onSubmit,
  Function onChanged,
  bool isPassword = false,
  Function showPassword,
  @required Function validator,
  @required String label,
  @required IconData prefix,
  IconData suffix,
  Function onTap,
  bool isClickable = true,
}) =>
    TextFormField(
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefix),
          suffixIcon: suffix != null
              ? IconButton(
                  icon: Icon(suffix),
                  onPressed: showPassword,
                )
              : null,
          border: OutlineInputBorder()),
      obscureText: isPassword,
      validator: validator,
      enabled: isClickable,
      controller: controller,
      keyboardType: type,
      onTap: onTap,
      onFieldSubmitted: onSubmit,
      onChanged: onSubmit,
    );

Widget buildTaskItem(Map model, context) => Dismissible(
      key: Key(model['id'].toString()),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          //crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            CircleAvatar(
              radius: 40.0,
              child: Text('${model['time']}'),
            ),
            SizedBox(
              width: 15.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['title']}',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${model['date']}',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 15.0,
            ),
            IconButton(
              icon: Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              onPressed: () {
                AppCubit.get(context)
                    .updateData(status: 'done', id: model['id']);
              },
            ),
            SizedBox(
              width: 15.0,
            ),
            IconButton(
              icon: Icon(
                Icons.archive,
                color: Colors.black45,
              ),
              onPressed: () {
                AppCubit.get(context)
                    .updateData(status: 'archived', id: model['id']);
              },
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        AppCubit.get(context).deleteData(id: model['id']);
      },
    );

Widget buildTasks({@required List<Map> tasks}) {
  return ConditionalBuilder(
    condition: tasks.length > 0,
    builder: (context) => ListView.separated(
      itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
      separatorBuilder: (context, index) => Container(
        width: double.infinity,
        height: 1.0,
        color: Colors.grey[300],
      ),
      itemCount: tasks.length,
    ),
    fallback: (context) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu,
            size: 100.0,
            color: Colors.grey,
          ),
          Text(
            'No Tasks Yet , Please Add Some Tasks',
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
