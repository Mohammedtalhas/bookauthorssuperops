import 'package:bookauthors/controllers/message_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MessageListScreen(),
    );
  }
}

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  final MessageController controller = Get.put(MessageController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages"),
        actions: [
          IconButton(onPressed: (){
            showSearch(context: context, delegate: MessageSearchDelegate(controller));
          }
          , icon: Icon(Icons.search))
        ],
      ),
      body: Obx((){
        if(controller.isLoading.value && controller.messages.isEmpty){
          return const Center(child: CircularProgressIndicator(),);
        }
        return
        //  Column(
        //   children: [
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: TextFormField(
            //     onChanged: controller.setSearchQuery,
            //     decoration: const InputDecoration(
            //       hintText: "Search here...",
            //       border: OutlineInputBorder(),
            //     ),
            //   ),
            // ),
            // Container(
            //   height: MediaQuery.sizeOf(context).height*.7,
            //   child: 
              ListView.builder(
                shrinkWrap: true,
          itemCount: controller.filteredMessages.length+1,
          itemBuilder: (context, index){
            if(index<controller.filteredMessages.length){
              final message = controller.messages[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage("https://message-list.appspot.com/${message.author.photoUrl}"),
                ),
                title: Text(message.content),
                subtitle: Text(message.author.name),
                trailing: IconButton(onPressed: (){
                  controller.toggleFavourite(message.id);
                }, icon: Icon(message.isFavourite?Icons.favorite:Icons.favorite_border,color:message.isFavourite?Colors.red:null ,)),
                onLongPress:()=> controller.deleteMessage(message.id),
              );
            }else if(controller.nextPageToken.isNotEmpty){
              controller.fetchMessages(isNextPage: true);
              return const Center(child: CircularProgressIndicator(),);
            }
            return Container();
           }
          );
           // )
        //   ],
        // );
      }),
    );
  }
}

class MessageSearchDelegate extends SearchDelegate {
  final MessageController controller;
  MessageSearchDelegate(this.controller);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
          controller.clearSearch();
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _performSearch(context);
    return Obx(() {
      return ListView.builder(
        itemCount: controller.filteredMessages.length,
        itemBuilder: (context, index) {
          final message = controller.filteredMessages[index];
          return ListTile(
            title: Text(message.content),
            subtitle: Text(message.author.name),
          );
        },
      );
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _performSearch(context);
    return Obx(() {
      return ListView.builder(
        itemCount: controller.filteredMessages.length,
        itemBuilder: (context, index) {
          final message = controller.filteredMessages[index];
          return ListTile(
            title: Text(message.content),
            subtitle: Text(message.author.name),
          );
        },
      );
    });
  }

  void _performSearch(BuildContext context) {
    // Delaying the search operation to avoid calling setState during the build phase
    Future.delayed(Duration(milliseconds: 100), () {
      controller.performSearch(query);
    });
  }
}
