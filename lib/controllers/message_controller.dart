import 'dart:convert';

import 'package:bookauthors/constants/url.dart';
import 'package:bookauthors/models/messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
class MessageController extends GetxController{
  var messages = <Messages>[].obs;
  var filteredMessages =  <Messages>[].obs;
  var searchQuery =''.obs;
  var isLoading = false.obs;
  var nextPageToken = ''.obs;
  final int pageSize = 10;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchMessages();
   // debounce(searchQuery, (_) => filterMessages(), time: Duration(milliseconds: 500));
  }

  Future<void> fetchMessages({bool isNextPage = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try{
        final response = await http.get(Uri.parse("${API_URL}?count=$pageSize&pageToken=${isNextPage?nextPageToken.value:''}"));
        if (response.statusCode ==200){
          final data =  json.decode(response.body);
          nextPageToken.value = data['pageToken'];
          var fetchedMessages = (data['messages'] as List)
          .map((message) => Messages.fromJson(message))
          .toList();
          if(isNextPage){
            messages.addAll(fetchedMessages);
          }else{
            messages.value = fetchedMessages;

          }
        }
    }catch(e){
      print(e);
    }
    filteredMessages.assignAll(messages);
    isLoading.value = false;
  }

  void toggleFavourite(int id){
    var index  = filteredMessages.indexWhere((message)=>message.id==id);
    if(index!=-1){
      filteredMessages[index].isFavourite = !filteredMessages[index].isFavourite;
      filteredMessages.refresh();
    }
  }
  // void setSearchQuery(String query) {
  //   searchQuery.value = query;
  // }
  void deleteMessage(int id){
    filteredMessages.removeWhere((message)=>message.id==id);
  }
void performSearch(String query) {
    if (query.isEmpty) {
      filteredMessages.assignAll(messages);
    } else {
      filteredMessages.assignAll(
        messages.where((msg) =>
            msg.content.toLowerCase().contains(query.toLowerCase()) ||
            msg.author.name.toLowerCase().contains(query.toLowerCase())),
      );
    }
  }

  void clearSearch() {
    filteredMessages.assignAll(messages);
  }
  //  void filterMessages() {
  //   final query = searchQuery.value.toLowerCase();
  //   if (query.isEmpty) {
  //     filteredMessages.assignAll(messages);
  //   } else {
  //     filteredMessages.assignAll(
  //       messages.where((msg) => msg.author.name.toLowerCase().contains(query)).toList(),
  //     );
  //   }
  // }

}