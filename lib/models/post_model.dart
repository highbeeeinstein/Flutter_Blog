import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_blog/models/post.dart';

class PostModel extends ChangeNotifier { 
  final List<Post> _posts = [];
  UnmodifiableListView<Post> get items => UnmodifiableListView(_posts);

  List<Post> _filteredPost = [];

  set setFilteredPost(List<Post> posts) => _filteredPost = posts;
  List<Post> get getFilteredPost => _filteredPost;

  void add(Post post) {
    _posts.insert(0, post);
    _filteredPost = _posts;
    notifyListeners();
  }

  void delete(Post post) {
    _posts.remove(post);
    _filteredPost = _posts;
    notifyListeners();
  }

  int get length => _filteredPost.length;
}
