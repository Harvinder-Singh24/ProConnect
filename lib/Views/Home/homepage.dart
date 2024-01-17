import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseReference _usersRef =
      FirebaseDatabase.instance.reference().child('users');
  IO.Socket? socket;
  bool isConnecting = false;
  bool isConnected = false;
  RTCVideoRenderer? _localRenderer;
  RTCVideoRenderer? _remoteRenderer;
  late RTCPeerConnection _peerConnection;
  late MediaStream _localStream;
  List<String> onlineUsers = [];

  @override
  void initState() {
    super.initState();
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    initRenderers();
    _createPeerConnection().then((pc) {
      _peerConnection = pc;
    });
    _getUserMedia();
    _listenToOnlineUsers();
  }

  @override
  void dispose() {
    _localRenderer?.dispose();
    _remoteRenderer?.dispose();
    _localStream.dispose();
    socket?.disconnect();
    super.dispose();
  }

  initRenderers() async {
    await _localRenderer!.initialize();
    await _remoteRenderer!.initialize();
  }

  _getUserMedia() async {
    final Map<String, dynamic> constraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    MediaStream stream = await navigator.mediaDevices.getUserMedia(constraints);

    _localRenderer!.srcObject = stream;
    _localStream = stream;
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    RTCPeerConnection pc =
        await createPeerConnection(configuration, offerSdpConstraints);

    pc.addStream(_localStream);

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        print({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMLineIndex,
        });
      }
    };

    pc.onIceConnectionState = (e) {
      print(e);
    };

    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      _remoteRenderer!.srcObject = stream;
    };

    return pc;
  }

  _listenToOnlineUsers() {
    _usersRef.onValue.listen((event) {
      final Map<String, dynamic>? usersData =
          event.snapshot.value as Map<String, dynamic>?;

      if (usersData != null) {
        onlineUsers = usersData.keys.toList();
        setState(() {
          onlineUsers.remove(_getUserId()); // Remove current user from the list
        });
      }
    });
  }

  _startConnection() {
    setState(() {
      isConnecting = true;
    });

    if (onlineUsers.isNotEmpty) {
      // Select a random user from the online list
      final randomUser = onlineUsers[_getRandomIndex()];
      print('Connecting to user: $randomUser');

      // Simulate a signaling server connection (replace with your own signaling logic)
      socket = IO.io('https://your-signaling-server-url.com', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      socket!.onConnect((_) {
        print('Connected to signaling server');
        socket!.emit('joinRoom', randomUser);
      });

      socket!.on('offer', (data) {
        // Handle offer from the signaling server
        // Implement your WebRTC offer handling logic here
      });

      socket!.on('answer', (data) {
        // Handle answer from the signaling server
        // Implement your WebRTC answer handling logic here
      });

      socket!.on('iceCandidate', (data) {
        // Handle ICE candidate from the signaling server
        // Implement your WebRTC ICE candidate handling logic here
      });

      socket!.connect();

      // Simulate a delay to simulate the connection process
      Future.delayed(Duration(seconds: 2), () {
        // After successful connection
        setState(() {
          isConnecting = false;
          isConnected = true;
        });
      });
    } else {
      print('No online users available');
      setState(() {
        isConnecting = false;
      });
    }
  }

  _skipConnection() {
    // Implement your skip logic here (disconnect from the current stranger)
    socket?.disconnect();

    // Simulate a delay to reset the state
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isConnected = false;
      });
    });

    // Start connecting with a new stranger
    _startConnection();
  }

  int _getRandomIndex() {
    return (DateTime.now().millisecondsSinceEpoch % onlineUsers.length).toInt();
  }

  String _getUserId() {
    // Replace with your logic to get the current user's ID
    return 'currentUserId';
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    if (_localRenderer != null)
                      Container(
                        width: constraints
                            .maxWidth, // Adjust this based on your layout needs
                        height: constraints
                            .maxHeight, // Adjust this based on your layout needs
                        child: RTCVideoView(_localRenderer!),
                      ),
                    if (isConnecting)
                      Center(child: CircularProgressIndicator())
                    else if (_remoteRenderer != null)
                      Container(
                        width: constraints
                            .maxWidth, // Adjust this based on your layout needs
                        height: constraints
                            .maxHeight, // Adjust this based on your layout needs
                        child: RTCVideoView(_remoteRenderer!),
                      ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: isConnected ? _skipConnection : _startConnection,
              style: ElevatedButton.styleFrom(
                primary: isConnected ? Colors.red : Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(isConnected ? 'Skip' : 'Start'),
            ),
          ),
          if (isConnected) Text('Connected with Stranger!'),
        ],
      ),
    );
  }
}
