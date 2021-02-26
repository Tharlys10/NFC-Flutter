import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

class ReadExampleScreen extends StatefulWidget {
  @override
  _ReadExampleScreenState createState() => _ReadExampleScreenState();
}

class _ReadExampleScreenState extends State<ReadExampleScreen> {
  StreamSubscription<NDEFMessage> _stream;

  List<String> payload = [];

  void _startScanning() {
    setState(() {
      _stream = NFC
          .readNDEF(alertMessage: "Custom message with readNDEF#alertMessage")
          .listen((NDEFMessage message) {
        if (message.isEmpty) {
          print("Read empty NDEF message");
          return;
        }
        print("Read NDEF message with ${message.records.length} records");


        payload.clear();
        for (NDEFRecord record in message.records) {
          
          setState(() {
            payload.add('${record.payload}');
          });
          print(
              "Record '${record.id ?? "[NO ID]"}' with TNF '${record.tnf}', type '${record.type}', payload '${record.payload}' and data '${record.data}' and language code '${record.languageCode}'");
        }
      }, onError: (error) {
        setState(() {
          _stream = null;
        });
        if (error is NFCUserCanceledSessionException) {
          print("user canceled");
        } else if (error is NFCSessionTimeoutException) {
          print("session timed out");
        } else {
          print("error: $error");
        }
      }, onDone: () {
        setState(() {
          _stream = null;
        });
      });
    });
  }

  void _stopScanning() {
    _stream?.cancel();
    setState(() {
      _stream = null;
    });
  }

  void _toggleScan() {
    if (_stream == null) {
      _startScanning();
    } else {
      _stopScanning();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _stopScanning();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _toggleScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF000000),
        title: const Text("Leia o NFC"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Para leitura aproxima o NFC", style: TextStyle(fontWeight: FontWeight.bold),),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.81,
            child: ListView.builder(
              itemCount: payload.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${index + 1} - ${payload[index]}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
