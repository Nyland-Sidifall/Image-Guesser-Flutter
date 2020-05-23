import 'dart:ui';
import 'package:flutter/material.dart';
import 'image_card.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Guess the car!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{

  String curVehName = "";
  double scrollPercent = 0.0;
  Offset startDrag;
  double startDragPercentScroll;
  double finishScrollStart;
  double finishScrollEnd;
  AnimationController finishScrollController;

  List<String> vehicleNames = [
    'bmw',
    'cybertruck',
    'ford',
    'hummer',
    'hundai',
    'lambo',
    'lexus',
    'nissan',
    'rover',
    'toyota',
  ];

  @override
  initState(){
    super.initState();
    finishScrollController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    )..addListener(() { 
      setState(() {
        scrollPercent = lerpDouble(finishScrollStart, finishScrollEnd,
            finishScrollController.value);
      });
    });

    @override
    dispose(){
      finishScrollController.dispose();
      super.dispose();
    }
  }

  List<Widget> buildCards(){
    List<Widget> cardList = [];
    for(int i = 0; i < vehicleNames.length;i++){
      cardList.add(buildCard(i,scrollPercent));
    }
    return cardList;
  }

  Widget buildCard(int cardIndex, double scrollPercent){

    final cardScrollPercent = scrollPercent / ( 1 / vehicleNames.length);
    
    return FractionalTranslation(
      translation: Offset(cardIndex-cardScrollPercent,0.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: ImageCard(imageName: vehicleNames[cardIndex],
        ),
      ),
    );
  }

  onHorizontalDragStart(DragStartDetails details){
    startDrag = details.globalPosition;
    startDragPercentScroll = scrollPercent;
  }

  onHorizontalDragUpdate(DragUpdateDetails details){
    final currentDrag = details.globalPosition;
    final dragDistance = currentDrag.dx - startDrag.dx;
    final singleCardDragPercent = dragDistance / context.size.width;

    setState(() {
      scrollPercent = ( startDragPercentScroll + ( - singleCardDragPercent
          / vehicleNames.length )).clamp(0.0, 1.0 - ( 1 / vehicleNames.length));
    });
  }

  onHorizontalDragEnd(DragEndDetails details){
    finishScrollStart = scrollPercent;
    finishScrollEnd = (scrollPercent * vehicleNames.length).round()
        /vehicleNames.length;

    finishScrollController.forward(from: 0.0);

    setState(() {
      startDrag = null;
      startDragPercentScroll = null;
      curVehName = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              onHorizontalDragStart: onHorizontalDragStart,
              onHorizontalDragUpdate: onHorizontalDragUpdate,
              onHorizontalDragEnd: onHorizontalDragEnd,
              behavior: HitTestBehavior.translucent ,
              child: Stack(
                children: buildCards(),
              ),
            ),
            OutlineButton(
              padding: EdgeInsets.all(10.0),
              onPressed: (){
                setState((){
                  this.curVehName = vehicleNames[(scrollPercent*10).round()];
                  print("${((scrollPercent*10).round())}");
                });
              },
              child: Text(
                  'Show Answer',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              borderSide: BorderSide(
                color: Colors.black,
                width: 4.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              highlightedBorderColor: Colors.black,
            ),
            Text(
              curVehName,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
