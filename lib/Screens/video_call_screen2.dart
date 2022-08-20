import 'package:flutter/material.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class video_call2 extends StatefulWidget {
  const video_call2({Key? key}) : super(key: key);

  @override
  State<video_call2> createState() => _video_call2State();
}

class _video_call2State extends State<video_call2> {
  static const appId = '24ee9678e6cb4a59b4602db627a6503c';
  static const token =
      '007eJxTYMj27nJiaxO4+9VmV1ao0VM5LfP6o20TOp9OXCh1pEz13H0FBiOT1FRLM3OLVLPkJJNEU8skEzMDo5QkMyPzRDNTA+NkBb3/SQvqGZIvpJ5jZWSAQBCfhaEsOdeIgQEAN7cgbQ==';
  dynamic _remoteUid;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initForAgora();
  }

  Future<void> initForAgora() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = await RtcEngine.createWithConfig(RtcEngineConfig(appId));
    await _engine.enableVideo();

    _engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
      print("local user ${uid} joined");
    }, userJoined: (int uid, int elapsed) {
      print('remote user $uid joined');
      setState(() {
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      print('remote user $uid left channel');
      setState(() {
        _remoteUid = null;
      });
    }));
    await _engine.joinChannel(token, "vcm2", null, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Agora video call'),
        ),
        body: Stack(
          children: [
            Center(
              child: _renderRemoteVideo(),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 100,
                height: 100,
                child: Center(
                  child: _renderLocalPreview(),
                ),
              ),
            )
          ],
        ));
  }

  Widget _renderLocalPreview() {
    return RtcLocalView.SurfaceView();
  }

  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(uid:_remoteUid,channelId: 'vcm2',);
    } else {
      return Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
