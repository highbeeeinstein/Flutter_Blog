import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog/helpers/functions.dart';
import 'package:flutter_blog/helpers/services.dart';
import 'package:flutter_blog/models/post.dart';
import 'package:flutter_blog/models/post_model.dart';
import 'package:flutter_blog/screens/new_post.dart';
import 'package:flutter_blog/screens/post_detail.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget _appBarTitle =
      Text("Flutter Blog", style: TextStyle(color: Color(0xFF8A0202)));
  IconData _searchIcon = Icons.search;
  String _searchText = "";
  TextEditingController _searchController = new TextEditingController();

  bool _isBuilding = false;

  ///Waiting while Fetching api online
  void _getPosts() async {
    setState(() {
      _isBuilding = true;
    });

    final response = await postList();
    if (response != null) {
      for (Post item in response) {
        Provider.of<PostModel>(context, listen: false)
            .add(item); // adding fetched api to post list
      }
    }

    setState(() {
      _isBuilding = false;
    });
  }

  /// adding listener to search bar
  _HomeState() {
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        setState(() {
          _searchText = "";
        });

        Provider.of<PostModel>(context, listen: false).setFilteredPost =
            Provider.of<PostModel>(context, listen: false)
                .items; // set filter post to all post if search bar is empty
      } else {
        setState(() {
          _searchText = _searchController.text;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getPosts(); //get post list on initialized
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _appBarTitle,
        actions: [
          IconButton(
              icon: Icon(_searchIcon),
              onPressed: () {
                setState(() {
                  if (_searchIcon == Icons.search) {
                    _searchIcon = Icons.close;
                    _appBarTitle = TextField(
                      autofocus: true,
                      controller: _searchController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(hintText: "Search..."),
                    );
                  } else {
                    _searchIcon = Icons.search;
                    _appBarTitle = Text("Flutter Blog",
                        style: TextStyle(color: theme.primaryColor));
                    _searchController.clear();
                  }
                });
              }),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Top Headlines",
              style: theme.textTheme.headline6,
            ),
            SizedBox(height: 10),
            Container(
              height: MediaQuery.of(context).size.height - 150,
              child: _buildList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => showModalBottomSheet( 
            isDismissible: false,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15))),
            context: context,
            builder: (context) => NewPost()),
      ),
    );
  }

  /// building list to display
  Widget _buildList() {
    List<Post> posts = Provider.of<PostModel>(context, listen: false).items;

    // checking if search text is not empty then filter all post and rebuild the list
    if (_searchText.isNotEmpty) {
      List<Post> tempList = [];
      for (Post post in posts) {
        if (post.title!.toLowerCase().contains(_searchText.toLowerCase()) ||
            post.body!.toLowerCase().contains(_searchText.toLowerCase())) {
          tempList.add(post);
        }
      }

      Provider.of<PostModel>(context, listen: false).setFilteredPost =
          tempList; //adding filtered post
    }

    //check if api is not reading then display dummy list
    if (_isBuilding) {
      return ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) => Shimmer.fromColors(
                baseColor: Colors.grey.shade400,
                highlightColor: Colors.white,
                child: dummyList(),
              ));
    }

    //building list
    return Consumer<PostModel>(builder: (context, value, child) {
      //check if list is empty
      if (value.length < 1 && !_isBuilding) {
        return Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("No post found",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold))
            ],
          ),
        );
      }

      return ListView.builder(
          itemCount: value.length,
          itemBuilder: (context, index) {
            Post post = value.getFilteredPost[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: GestureDetector(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  )),
                  elevation: 3,
                  child: postContent(post),
                ),
                onTap: () async {
                  showCupertinoDialog(
                      context: context, builder: (context) => InfoDialog());
                  final response = await postComment(post.id); 
                  print(response.toString()); 
                  Navigator.pop(context); 
                  print(post.toJson());
                  if (response != null) {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                          builder: (context) => PostDetails( 
                                post: post,
                                comments: response,
                              )),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Connection Error")));
                  }
                },
              ),
            );
          });
    });
  }

  /// dummy list
  Widget dummyList() {
    return ListTile(
      isThreeLine: true,
      title: Container(height: 8.0, color: Colors.white),
      subtitle: Container(height: 8.0, color: Colors.white),
      trailing: Container(
        width: 40,
        height: 8.0,
        color: Colors.white,
      ),
    );
  }

  /// content of a post
  Widget postContent(Post post) {
    DateTime? date = post.date;
    if (date == null) {
      date = DateTime(2021);
    }
    var dateFormat = DateFormat("E d, MMM y");
    var timeFormat = DateFormat.jm();

    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              height: 160,
              child: Center(child: Text("Image")),
              color: Colors.blueGrey.shade200,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                child: Text("${dateFormat.format(date)}"),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15)),
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${post.title!.titleCase}",
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 10),
              Text(
                "${post.body!.sentenceCase.replaceAll("\n", "")}",
                textAlign: TextAlign.justify,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Author ${post.userId}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${timeFormat.format(date)}",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    ));
  }
}

class InfoDialog extends StatefulWidget {
  const InfoDialog({
    Key? key,
  }) : super(key: key);
  @override
  _InfoDialogState createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(30.0),
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Center(
          child: Column(
            children: [CircularProgressIndicator(), Text("Please wait...")],
          ),
        ));
  }
}
