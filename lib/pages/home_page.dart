import 'dart:convert';
import 'package:adamsy/models/radio.dart';
import 'package:adamsy/utils/ai_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
late List<MyRadio> radios = [];

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  fetchRadios() async {
    final radiojson = await rootBundle.loadString("pics/radio.json");
    radios = MyRadioList.fromJson(radiojson).radios;
    print(radios);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchRadios();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      body: (radios.length==0)?Container(height:1000  ,color: AIColors.primarycolor1):Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(LinearGradient(
                  colors: [AIColors.primarycolor1, AIColors.primarycolor2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight))
              .make(),
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: "Adamsy".text.bold.white.xl4.make().shimmer(
                primaryColor: Vx.purple300, secondaryColor: Colors.white),
          ).h(80).p(16),
          VxSwiper.builder(
              aspectRatio: 1.0,enlargeCenterPage: true,

              itemCount: radios.length,
              itemBuilder: (context, index) {
                final rad = radios[index];

                return VxBox(child: ZStack([])).bgImage(DecorationImage(image: NetworkImage(rad.image),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3),BlendMode.darken  )
                )).border(color: Colors.black,width: 5.0).withRounded(value: 60)
                    .make().p16().centered();

              })
        ],
      ),
    );
  }
}
