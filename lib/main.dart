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
  final TextEditingController _controllerIP = TextEditingController();
  final String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiRENDWkZZUldQYTdRUXNkZTRLUE8ifQ.7eM9qtoZodf6gGn99TUIDxWmB_IIH8wPbKtybDYIxHg";
  final String url = "wss://gw-dev.poker-age.com/api/v1/pokerage-backend/ws";
  List<String> status = [];
  String userId = "DCCZFYRWPa7QQsde4KPO";
  String roomId = "DCG5eK3Ldp9FHDAcw8GA";
  String callToken = "";
  String connectingStatus = "";
  Room room = Room();
  late LocalAudioTrack localAudio;

  @override
  void initState() {
    setState(() {
      _controllerRoomID.text = roomId;
      _controllerIP.text = "ws://34.126.110.186:7880";
    });

    _channel =
        IOWebSocketChannel.connect(url, headers: {"access_token": token});
    _channel.stream.listen((event) async {
      Map eventMap = json.decode(event);
      if (eventMap['type'] == "rpc:get_join_call_token") {
        Map data = eventMap["data"];
        setState(() {
          callToken = data['access_token'];
          print(callToken);
        });
      }
    });
    super.initState();
  }

  void getUserInRoom() {
    // late final _listener = room.participants.
  }

  void mute() {
    print("mute");

    LocalTrackPublication localTrackPublication = LocalTrackPublication(
        participant: room.localParticipant!,
        info: room.engine
            .addTrack(cid: cid, name: name, kind: kind, source: source),
        track: track);
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
    room = await LiveKitClient.connect(_controllerIP.text, callToken);

    localAudio = await LocalAudioTrack.create();
    await room.localParticipant?.publishAudioTrack(localAudio);

    localAudio.mediaStream.getAudioTracks().first.enableSpeakerphone(false);

    EventsListener<RoomEvent> _listener = room.createListener();
    _listener.on<TrackPublishedEvent>((e) {
      e.publication.subscribe();
    });

    _listener.on<SpeakingChangedEvent>((e) {
      print("sdsd");
      print(e.participant.name);
      print(e.speaking);
    });
    _listener
      ..on<RoomDisconnectedEvent>((_) {
        setState(() {
          connectingStatus = "Disconnected";
        });
      })
      ..on<ParticipantConnectedEvent>((e) {
        setState(() {
          connectingStatus = "Connected";
        });
      });
  }

  String dropdownvalue =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiRENDWkZZUldQYTdRUXNkZTRLUE8ifQ.7eM9qtoZodf6gGn99TUIDxWmB_IIH8wPbKtybDYIxHg';

  // List of items in our dropdown menu
  var items = [
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiRENDWkZZUldQYTdRUXNkZTRLUE8ifQ.7eM9qtoZodf6gGn99TUIDxWmB_IIH8wPbKtybDYIxHg",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiRENBS1ZseTRQZnl2OExmV0xIUE8ifQ.fg3xSZGG0RutiRgvsCvUVqgyAXo0XamC6YQUBt8inBM",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiRENBS1ZjdDVaNVpNRGU0bGJiUE8ifQ.B2RlNiZm8uQABjklgsCF_NQRcBp4E4-V18wN0z2fCQE",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiRENGV2ZyQ1RNajA2NVMyY3lrUE8ifQ.dzLULAsrCtCK3J-cjfCD9qXX6DQ9wpaAu2GyR6_Yixs",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test LiveKit"),
      ),
      body: Center(
        child: Column(
          children: [
            DropdownButton(
              // Initial Value
              value: dropdownvalue,

              // Down Arrow Icon
              icon: const Icon(Icons.keyboard_arrow_down),

              // Array list of items
              items: items.map((String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text("Token" + items.indexOf(item).toString()),
                );
              }).toList(),
              // After selecting the desired option,it will
              // change button value to selected value
              onChanged: (String? newValue) {
                setState(() {
                  dropdownvalue = newValue!;
                });
              },
            ),
            ElevatedButton(
              onPressed: getToken,
              child: Text("Get call token"),
            ),
            Text("Curent token + " + callToken),
            Text("userid"),
            TextFormField(
              controller: _controllerUserID,
            ),
            Text("roomid"),
            TextFormField(
              controller: _controllerRoomID,
            ),
            Text("IP"),
            TextFormField(
              controller: _controllerIP,
            ),
            ElevatedButton(
              onPressed: connect,
              child: Text("call"),
            ),
            Text(connectingStatus),
            ElevatedButton(
              onPressed: getUserInRoom,
              child: Text("get room"),
            ),
            ElevatedButton(
              onPressed: mute,
              child: Text("mute"),
            ),
          ],
        ),
      ),
    );
  }
}
