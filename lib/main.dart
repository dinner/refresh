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

enum RefreshStatus{
  DropSmallerCritical,DropOffControll,DropBiggerThanCritical
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  int _counter = 5;
  ScrollController _controller = new ScrollController();
  double _criticalPos = -80;
  AnimationController ac;
  RefreshStatus refStatus = RefreshStatus.DropBiggerThanCritical;

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
      setState(() {
        refStatus = RefreshStatus.DropOffControll;
      });

      _controller
      .animateTo(offset+1,duration: Duration(milliseconds: 2000),curve: Curves.linear)
      .whenComplete((){
        _controller
          .animateTo(0,duration: Duration(milliseconds: 100),curve: Curves.linear)
          .whenComplete((){
            setState(() {
              refStatus = RefreshStatus.DropBiggerThanCritical;
            });
          });
      });
    }
    else{
      _controller
          .animateTo(0,duration: Duration(milliseconds: 100),curve: Curves.linear)
          .whenComplete((){
            setState(() {
              refStatus = RefreshStatus.DropBiggerThanCritical;
            });
          });
    }
  }

  void onPointMove(PointerMoveEvent event){
    var offset = _controller.offset;
    if(offset < _criticalPos){
      refStatus = RefreshStatus.DropSmallerCritical;
    }
    else{
      refStatus = RefreshStatus.DropBiggerThanCritical;
    }
    setState(() {
      
    });
  }

  Widget widgetHeader(RefreshStatus status){
    Widget wid;
    switch(status){
      case RefreshStatus.DropBiggerThanCritical:{
        wid = Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('asserts/dropDown.png',width: 24,height: 24),
              Text('下拉刷新')
            ],
          ),
        );
      }break;
      case RefreshStatus.DropOffControll:{
        wid = Container(
          color: Colors.white,
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 10),
                child:
                Container(
                  width: 24,
                  height: 24,
                  child:
              CircularProgressIndicator(
                valueColor:new AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth:3,
              ))),
              Text('正在刷新，请稍候')
            ],
          ),
        );
      }break;
      case RefreshStatus.DropSmallerCritical:{
          wid = Container(
            color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('asserts/dropUp.png',width: 24,height: 24),
              Text('松开刷新')
            ],
          ),
        );
      }break;
    }
    return wid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('刷新'),
        elevation: 0.0,
      ),
      body:Stack(
        alignment: AlignmentDirectional.center,
        children:<Widget>[
          Positioned(top:-_controller.offset/2-25,
          child:
          widgetHeader(refStatus)),
          // Text(_prompt,style: TextStyle(color: Colors.black),textAlign: TextAlign.center,),),
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
      ))])
    );
  }
}
