import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_blog/helpers/services.dart';
import 'package:flutter_blog/models/post.dart';
import 'package:flutter_blog/models/post_model.dart';
import 'package:flutter_blog/screens/home.dart';

class EditPost extends StatefulWidget {
  const EditPost({
    Key? key,
    this.title,
    this.body,
    this.userId,
    this.id,
  }) : super(key: key);
  final String? title;
  final String? body;
  final int? userId;
  final int? id;

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextEditingController _titleController =
        TextEditingController(text: widget.title);
    TextEditingController _descriptionController =
        TextEditingController(text: widget.body);
    int? id = widget.id;
    int? userId = widget.userId;

    return Container(
      height: MediaQuery.of(context).size.height / 1.5,
      padding: EdgeInsets.all(20),
      child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Container(
                  width: 70,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(25)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Post",
                    style: TextStyle(
                        fontSize: 18,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: theme.primaryColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              formField(
                controller: _titleController,
                label: "Title",
                hint: "Post Title",
                validator: (value) {
                  if (value!.isEmpty) return "This field required";
                  return null;
                },
              ),
              formField(
                controller: _descriptionController,
                label: "Description",
                hint: "Write Something here...",
                minLines: 6,
                validator: (value) {
                  if (value!.isEmpty) return "This field required";
                  return null;
                },
              ),
              SizedBox(height: 20),
              CupertinoButton.filled(
                borderRadius: BorderRadius.circular(5),
                child: Text('Update Post'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    showCupertinoDialog(
                        context: context, builder: (context) => InfoDialog());
                    var response = await updatePost(
                        AddPost(
                          userId: userId.toString(),
                          id: id,
                          title: _titleController.text,
                          body: _descriptionController.text,
                        ),
                        id);
                    Navigator.pop(context);
                    print(response!.toJson());
                    if (response.title!.isNotEmpty) {
                      _titleController.clear();
                      _descriptionController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Post successfully updated")));
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Connection Error")));
                    }
                  }
                },
              ),
            ],
          )),
    );
  }

  Widget formField({
    TextEditingController? controller,
    String? label,
    String? hint,
    int? minLines,
    String? Function(String?)? validator,
  }) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text("$label", style: TextStyle(fontSize: 16)),
          TextFormField(
            controller: controller,
            style: TextStyle(color: Colors.black),
            minLines: minLines,
            maxLines: null,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
