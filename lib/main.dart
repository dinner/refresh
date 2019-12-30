import 'package:flutter/material.dart';
import 'Utils.dart';

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
enum GestureStatus{
  TouchNone,TouchDown,TouchMove,TouchUp
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  int _counter = 5;
  ScrollController _controller = new ScrollController();
  double _criticalPos = -80;
  double _hideOffset = 35;
  AnimationController _animateControl;
  Animation<double> _animat;
  RefreshStatus refStatus = RefreshStatus.DropBiggerThanCritical;

  DateTime promptTime=DateTime.now();//刷新提示展示的时间
  bool _isFirstRefresh = true;

  ScrollPhysics physics;
  double _headerMinHeight=50;
  double _headerHeight;
  GestureStatus _gesuture = GestureStatus.TouchNone;

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

  void onPointUp(PointerUpEvent event)async{
    print('onPointUp');
    _gesuture = GestureStatus.TouchUp;
    var offset = _controller.offset;
    if(offset < _criticalPos){//启动动画
      setState(() {
        refStatus = RefreshStatus.DropOffControll;
        physics = NeverScrollableScrollPhysics();
      });

      await Future.delayed(Duration(milliseconds: 2000),(){
        setState(() {
          refStatus = RefreshStatus.DropBiggerThanCritical;
          physics = AlwaysScrollableScrollPhysics();
        });
      });
    }
    else{
      _controller
          .animateTo(0,duration: Duration(milliseconds: 1000),curve: Curves.linear)
          .whenComplete((){
            setState(() {
              refStatus = RefreshStatus.DropBiggerThanCritical;
            });
          });
      // _animateControl = new AnimationController(
      //   duration: const Duration(milliseconds:3000),vsync: this);
      // _animat = Tween(begin: _controller.offset,end: 0)
      // .animate(_animateControl)
      // ..addListener((){
      //   setState(() {
      //     if (_animat.status != AnimationStatus.dismissed) {

      //     }
      //   });
      // });
      // _animateControl.forward();
    }
  }

  void onPointDown(PointerDownEvent event){
    _gesuture = GestureStatus.TouchDown;
    promptTime = DateTime.now();
  }

  void onPointMove(PointerMoveEvent event){
    _gesuture = GestureStatus.TouchMove;
    print('onPointMove');
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
          height: _headerMinHeight,
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('asserts/dropDown.png',width: 24,height: 24),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                Text('下拉刷新'),
                Text(
                  Utils.dateTimeToString(promptTime,'yyyy-MM-dd HH:mm')
                )
              ],)
            ],
          ),
        );
      }break;
      case RefreshStatus.DropOffControll:{
        wid = Container(
          height: _headerMinHeight,
          color: Colors.transparent,
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
                valueColor:new AlwaysStoppedAnimation<Color>(Colors.black),
                strokeWidth:3,
              ))),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                Text('正在刷新，请稍候'),
                Text(
                  Utils.dateTimeToString(promptTime,'yyyy-MM-dd HH:mm')
                )
              ],)
            ],
          ),
        );
      }break;
      case RefreshStatus.DropSmallerCritical:{
          wid = Container(
          height: _headerMinHeight,
            color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('asserts/dropUp.png',width: 24,height: 24),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                Text('松开刷新'),
                Text(
                  Utils.dateTimeToString(promptTime,'yyyy-MM-dd HH:mm')
                )
              ],)
            ],
          ),
        );
      }break;
    }
    return wid;
  }

  final GlobalKey _key = new GlobalKey();

  bool _isDrag(){
    if(_controller.offset < 0){
      return true;
    }
    else{
      return false;
    }
  }

  double getHeaderHeight(){
    bool isDrag = _isDrag();
    if(isDrag == false){
      return 0;
    }
    else{
      return -_controller.offset<_headerMinHeight?_headerMinHeight:-_controller.offset;
    }
  }

  double getHeaderOffset(){
    // bool isDrag = _isDrag();
    // if(isDrag == false){
    //   return -_headerMinHeight;
    // }
    // else{
    //   print('headerOffset:${-_headerMinHeight-_controller.offset}');
    //   return -_headerMinHeight-_controller.offset;
    // }
  }

  Widget header(){
    return Container(
      padding: EdgeInsets.only(top:0),
      height:getHeaderHeight(), 
      width: MediaQuery.of(context).size.width,
      child: widgetHeader(refStatus),
    );
  }

  Widget getWid(){
    return Listener(
      key:_key,
      onPointerDown: onPointDown,
      onPointerMove: onPointMove,
      onPointerUp: onPointUp,
      child:
      Container(
        padding: EdgeInsets.only(top:0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child:
    CustomScrollView(
      controller: _controller,
      physics: physics,
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (cont,index){
              return header();
            }
            ,childCount: 1
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (cont,index){
              return ListTile(
                title: Text('我是标题'),
                subtitle: Text('我是子标题'),
              );
            }
            ,childCount: 50
          ),
        )
      ],
    )));
  }

  @override
  Widget build(BuildContext context) {
    if(_isFirstRefresh){
      _isFirstRefresh = _isFirstRefresh;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('刷新'),
        elevation: 0.0,
      ),
    body: getWid(),
    );
  }
}
