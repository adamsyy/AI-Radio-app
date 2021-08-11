import 'dart:convert';
import 'package:adamsy/models/radio.dart';
import 'package:adamsy/utils/ai_util.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';

late List<MyRadio> radios = [];
late MyRadio _selectedradio;
late Color _selectedcolor = AIColors.primarycolor1;
bool _isplaying = false;

final AudioPlayer _audioPlayer = AudioPlayer();

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  fetchRadios() async {
    final radiojson = await rootBundle.loadString("pics/radio.json");
    radios = MyRadioList.fromJson(radiojson).radios;
    _selectedradio=radios[0];
    print(radios);
    setState(() {});
  }

  _playmusic(String url) {
    _audioPlayer.play(url);
    _selectedradio = radios.firstWhere((element) => element.url == url);
    print(_selectedradio.name);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setupAlan();
    fetchRadios();
    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.PLAYING) {
        _isplaying = true;
      } else {
        _isplaying = false;
      }
      setState(() {});
    });
  }

  setupAlan(){
    AlanVoice.addButton(
        "ee83f9bacfd6d7a4277c3f37f33068772e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
    AlanVoice.callbacks.add((command)=>_handlecommand(command.data));
  }

  _handlecommand(Map<String,dynamic> response){
switch(response["command"]){
  case "play":{_playmusic(_selectedradio.url);
    break;
  }
  default: {print('no//////////////////////////////'); break;}
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: (radios.length == 0)
          ? Container(
              height: context.screenHeight, color: AIColors.primarycolor1)
          : Stack(
              children: [
                VxAnimatedBox()
                    .size(context.screenWidth, context.screenHeight)
                    .withGradient(LinearGradient(colors: [
                      AIColors.primarycolor2,
                      (_selectedcolor!= null) ? _selectedcolor
                          : AIColors.primarycolor1
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight))
                    .make(),
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: "Adamsy".text.bold.white.xl4.make().shimmer(
                      primaryColor: Vx.purple300, secondaryColor: Colors.white),
                ).h(80).p(16),
                VxSwiper.builder(
                    aspectRatio: 1.0,
                    enlargeCenterPage: true,
                    itemCount: radios.length,
                    onPageChanged: (index) {

                      final colorhex = radios[index].color;

                      setState(() { _selectedcolor = Color(int.parse(colorhex));
                      print(_selectedcolor);});
                    },
                    itemBuilder: (context, index) {
                      final rad = radios[index];

                      return VxBox(
                              child: ZStack(
                        [
                          Positioned(
                            top: 0.0,
                            right: 0.0,
                            child: VxBox(
                                    child: rad.category.text.uppercase.white
                                        .make()
                                        .px16())
                                .height(40)
                                .black
                                .alignCenter
                                .withRounded(value: 10)
                                .make(),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: VStack(
                              [
                                rad.name.text.xl3.bold.white.make(),
                                5.heightBox,
                                rad.tagline.text.sm.white.semiBold.make()
                              ],
                              crossAlignment: CrossAxisAlignment.center,
                            ),
                          ),
                          Align(
                              alignment: Alignment.center,
                              child: [
                                Icon(
                                  CupertinoIcons.play_circle,
                                  color: Colors.white,
                                ),
                                10.heightBox,
                                "Double tap to play".text.gray300.make()
                              ].vStack())
                        ],
                      ))
                          .clip(Clip.antiAlias)
                          .bgImage(DecorationImage(
                              image: NetworkImage(rad.image),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.3),
                                  BlendMode.darken)))
                          .border(color: Colors.black, width: 5.0)
                          .withRounded(value: 60)
                          .make()
                          .onInkDoubleTap(() {
                        print('oi');
                        _playmusic(rad.url);
                      }).p16();
                    }).centered(),
                Align(
                        alignment: Alignment.bottomCenter,
                        child: [
                          if (_isplaying)
                            "Playing now - ${_selectedradio.name} FM"
                                .text
                                .white
                                .makeCentered(),
                          Icon(
                            _isplaying
                                ? CupertinoIcons.stop_circle
                                : CupertinoIcons.play_circle,
                            color: Colors.white,
                            size: 50,
                          ).onInkTap(() {
                            if (_isplaying) {
                              _audioPlayer.stop();
                            } else {
                              _playmusic(_selectedradio.url);
                            }
                          })
                        ].vStack())
                    .pOnly(bottom: context.percentHeight * 12),

              ],
              fit: StackFit.expand,
              clipBehavior: Clip.antiAlias,
            ),
    );
  }
}
