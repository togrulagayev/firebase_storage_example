// ignore_for_file: use_build_context_synchronously

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as cloud_storage;
import 'package:flutter/material.dart';
import 'package:flutter_cloud/services/cloud_storage_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CloudStorageService cloudStorage = CloudStorageService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Storage'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: OutlinedButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    type: FileType.image,
                  );

                  if (result == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No file selected'),
                      ),
                    );
                    return;
                  }
                  final filePath = result.files.single.path!;
                  final fileName = result.files.single.name;

                  cloudStorage
                      .uploadFile(filePath, fileName)
                      .then((value) => debugPrint('done'));

                  debugPrint('Path: $filePath');
                  debugPrint('File name: $fileName');
                },
                child: const Text('Upload')),
          ),
          FutureBuilder(
              future: cloudStorage.listOfFiles(),
              builder: (BuildContext context,
                  AsyncSnapshot<cloud_storage.ListResult> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return const CircularProgressIndicator();
                } else if (snapshot.connectionState == ConnectionState.none ||
                    snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemCount: snapshot.data!.items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return OutlinedButton(
                          onPressed: () {},
                          child: Text(snapshot.data!.items[index].name));
                    },
                  ),
                );
              }),
          FutureBuilder(
            future: cloudStorage.downloadURL('pexels-pixabay-60597.jpg'),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData) {
                return const CircularProgressIndicator();
              } else if (snapshot.connectionState == ConnectionState.none ||
                  snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return SizedBox(
                width: 300,
                height: 300,
                child: Image.network(snapshot.data!),
              );
            },
          ),
        ],
      ),
    );
  }
}
