import 'dart:io';

import 'package:flutter_blog/models/post.dart';
import 'package:http/http.dart' as http;

Uri url(String url) {
  return Uri.parse("https://jsonplaceholder.typicode.com/$url");
}

Future<http.Response> postRequest(String uri, Object? body) async {
  final response = await http.post(url(uri),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body);
  return response;
}

Future<http.Response> getRequest(String uri) async {
  final response = await http.get(url(uri), headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  });
  return response;
}

Future<http.Response> updateRequest(String uri, Object? body) async {
  final response = await http.put(url(uri),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body);
  return response;
}

Future<http.Response> deleteRequest(String uri) async {
  final response = await http.delete(url(uri), headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  });
  return response;
}

Future<List<Post>?>? postList() async {
  try {
    final response = await getRequest('posts');
    return postFromJson(response.body);
  } catch (e) {
    print(e.toString());
    return null;
  }
}

Future<List<PostComment>?>? postComment(int? id) async {
  try {
    final response = await getRequest('posts/$id/comments');
    return postCommentFromJson(response.body);
  } catch (e) {
    print(e.toString());
    return null;
  }
}

Future<AddPost?> addPost(AddPost post) async {
  try {
    final response = await postRequest("posts", addPostToJson(post));
    return addPostFromJson(response.body);
  } catch (e) {
    print(e.toString());
    return null;
  }
}

Future<AddPost?> updatePost(AddPost post, int? id) async {
  try {
    final response = await updateRequest("posts/$id", addPostToJson(post));
    return addPostFromJson(response.body);
  } catch (e) {
    print(e.toString());
    return null;
  }
}

Future<AddPost?> deletePost(int? id) async {
  try {
    final response = await deleteRequest("posts/$id");
    return addPostFromJson(response.body);
  } catch (e) {
    print(e.toString());
    return null;
  }
}
