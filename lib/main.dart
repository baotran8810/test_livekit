import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late IOWebSocketChannel _channel;
  final TextEditingController _controllerUserID = TextEditingController();
  final TextEditingController _controllerRoomID = TextEditingController();
  final String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiRENDWkZZUldQYTdRUXNkZTRLUE8ifQ.7eM9qtoZodf6gGn99TUIDxWmB_IIH8wPbKtybDYIxHg";
  final String url = "wss://gw-dev.poker-age.com/api/v1/pokerage-backend/ws";
  List<String> status = [];
  String userId = "DCCZFYRWPa7QQsde4KPO";
  String roomId = "DCG5eK3Ldp9FHDAcw8GA";
  String callToken = "";

  @override
  void initState() {
    setState(() {
      _controllerRoomID.text = roomId;
    });

    _channel =
        IOWebSocketChannel.connect(url, headers: {"access_token": token});
    _channel.stream.listen((event) async {
      Map eventMap = json.decode(event);
      if (eventMap['type'] == "rpc:get_join_call_token") {
        Map data = eventMap["data"];
        setState(() {
          callToken = data['access_token'];
        });
        // print(data);
        // setState(() {
        //   callToken = data["access_token"];
        // });
      }
    });
    getToken();
    super.initState();
  }

  Future<void> getToken() async {
    final body = {
      "type": "rpc:get_join_call_token",
      "arguments": {
        "room_id": _controllerRoomID.text,
        "user_id": _controllerUserID.text,
      },
      "request_id": Uuid().v4()
    };
    print(body);
    _channel.sink.add(json.encode(body));
  }

  connect() async {
    var room =
        await LiveKitClient.connect("ws://34.124.221.247:7880", callToken);

    var localAudio = await LocalAudioTrack.create();
    await room.localParticipant?.publishAudioTrack(localAudio);

    EventsListener<RoomEvent> _listener = room.createListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Test LiveKit"),
        ),
        body: Center(
          child: Column(
            children: [
              Text("Curent token + " + callToken),
              Text("userid"),
              TextFormField(
                controller: _controllerUserID,
              ),
              Text("roomid"),
              TextFormField(
                controller: _controllerRoomID,
              ),
              ElevatedButton(
                onPressed: connect,
                child: Text("call"),
              )
            ],
          ),
        ));
  }
}
