import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 5;
  ScrollController _controller = new ScrollController();
  double _criticalPos = -60;
  String _prompt = '下拉刷新';

  void _incrementCounter() {
    setState(() {
      _counter+=20;
    });
  }

  @override
  void initState(){
    super.initState();
    _controller.addListener(() { 
      print(_controller.offset);
      var offset = _controller.offset;
      if(offset < _criticalPos){
        _prompt = '松开刷新';
      }
      else{
        _prompt = '下拉刷新';
      }
      setState(() {
        
      });
    });
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  void onPointUp(PointerUpEvent event){
    var offset = _controller.offset;
    if(offset < _criticalPos){//启动动画
      _controller
      .animateTo(0,duration: Duration(milliseconds: 2000),curve: Curves.linear)
      .whenComplete((){
         _controller.animateTo(
          -10,
          duration: Duration(milliseconds: 100),
          curve: Curves.linear);
      });
    }
  }

  void onPointMove(PointerMoveEvent event){
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body:Stack(
        alignment: AlignmentDirectional.center,
        children:<Widget>[
          Positioned(top:-_controller.offset/2,
          child:
          Text(_prompt,style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),),
      Listener(
        onPointerUp: onPointUp,
        onPointerMove: onPointMove,
        child:
      ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (cot,index){
          return ListTile(
            title: Text('我是元素'),
            subtitle: Text('我是子元素'),
          );
        },
        itemCount: _counter,
        controller: _controller,
      )) ])
    );
  }
}
