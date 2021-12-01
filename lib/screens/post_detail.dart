import 'package:flutter/material.dart';
import 'package:flutter_blog/helpers/services.dart';
import 'package:flutter_blog/models/post_model.dart';
import 'package:flutter_blog/screens/edit_post.dart';
import 'package:flutter_blog/screens/home.dart';
import 'package:intl/intl.dart';

import 'package:flutter_blog/helpers/functions.dart';
import 'package:flutter_blog/models/post.dart';
import 'package:provider/provider.dart';

class PostDetails extends StatefulWidget {
  const PostDetails({
    Key? key,
    required this.post,
    required this.comments,
  }) : super(key: key);
  final Post post;
  final List<PostComment>? comments;
  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              "Flutter Blog",
              style: TextStyle(color: theme.primaryColor),
            ),
            expandedHeight: MediaQuery.of(context).size.height / 3,
            flexibleSpace: FlexibleSpaceBar(
              background: _header(theme),
            ),
            actions: [
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: theme.primaryColor),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                      child: Text(
                        "Edit Post",
                        style: theme.textTheme.bodyText2,
                      ),
                      value: "edit"),
                  PopupMenuItem(
                      child: Text(
                        "Delete Post",
                        style: theme.textTheme.bodyText2,
                      ),
                      value: "delete"),
                ],
                onSelected: (String value) {
                  if (value == "edit") {
                    showModalBottomSheet(  
                        isDismissible: false,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15))),
                        context: context,
                        builder: (context) => EditPost(
                              id: widget.post.id,
                              userId: widget.post.userId,
                              title: widget.post.title,
                              body: widget.post.body,
                            ));
                  } else if (value == "delete") {
                    showAlertDialog(context);
                  }
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(15.0),
            sliver: SliverList(
                delegate: SliverChildListDelegate([
              Container(
                child: Text(
                  "${widget.post.body!.sentenceCase.replaceAll("\n", "")}",
                  textAlign: TextAlign.justify,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("20 Likes"),
                        TextButton(
                          child: Text("${widget.comments!.length} Comments"),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.comments != null && widget.comments!.length > 0)
                for (var i = 0; i < widget.comments!.length; i++) commentBox(i)
            ])),
          ),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme) {
    DateTime? date = widget.post.date;
    if (date == null) {
      date = DateTime(2021);
    }
    var dateFormat = DateFormat("E d, MMM y");
    var timeFormat = DateFormat.jm();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 35, horizontal: 20),
      color: Colors.blueGrey.shade200,
      child: Stack(
        children: [
          Center(child: Text("Image")),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${dateFormat.format(date)}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 15),
                        Text(
                          "${timeFormat.format(date)}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text("${widget.post.title!.titleCase}",
                        style: theme.textTheme.headline6),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget commentBox(int i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 2,
        child: ListTile(
          title: Text(
              "${widget.comments![i].name!.titleCase} (${widget.comments![i].email})",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold)),
          subtitle: Text(
            "${widget.comments![i].body!.sentenceCase.replaceAll("\n", "")}",
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
        child: Text("Continue"),
        onPressed: () async {
          await deletePost(widget.post.id);
          Navigator.pop(context);
          Provider.of<PostModel>(context, listen: false).delete(widget.post);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Post successfully deleted")));
          Navigator.pop(context);
          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (context) => Home()));
        });
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Post"),
      content: Text(
        "Would you like to Delete this post?",
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
