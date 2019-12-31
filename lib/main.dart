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

enum DragStatus{
  DropSmallerCritical,DropOffControll,DropBiggerThanCritical,DropDone
}
enum GestureStatus{
  TouchNone,TouchDown,TouchMove,TouchUp
}
enum RefreshStatus{
  none,drag,refresh,done,back
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  int _counter = 5;
  ScrollController _controller = new ScrollController();
  double _criticalPos = -80;
  double _hideOffset = 35;
  AnimationController _animateControl;
  Animation<double> _animat;
  DragStatus _dragStatus = DragStatus.DropBiggerThanCritical;

  DateTime promptTime=DateTime.now();//刷新提示展示的时间
  bool _isFirstRefresh = true;

  ScrollPhysics physics;
  double _headerMinHeight=50;
  double _headerHeight;
  GestureStatus _gesuture = GestureStatus.TouchNone;
  RefreshStatus _refresh = RefreshStatus.none;

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

    _animateControl = AnimationController(duration: Duration(seconds: 2),vsync: this);
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  void onPointUp(PointerUpEvent event)async{
    print('onPointUp');
    _gesuture = GestureStatus.TouchUp;
    _refresh = RefreshStatus.drag;
    var offset = _controller.offset;
    if(offset < _criticalPos){//启动动画
      setState(() {
        _dragStatus = DragStatus.DropOffControll;
        physics = NeverScrollableScrollPhysics();
      });
      await Future.delayed(Duration(milliseconds: 2000),()async{
        print('刷新完成');
        _refresh = RefreshStatus.done;
        _dragStatus = DragStatus.DropDone;
        setState(() {
          
        });

        // await Future.delayed(Duration(seconds:2),(){
        //   _refresh = RefreshStatus.back;
        // //   _animat = Tween<double>(begin: offset,end:0).animate(_animateControl)
        // // ..addListener((){
        // //   setState(() {
            
        // //   });
        // // })
        // // ..addStatusListener((status){
        // //   if(status == AnimationStatus.completed){
        // //     setState(() {
        // //       _refresh = RefreshStatus.none;
        // //      _dragStatus = DragStatus.DropBiggerThanCritical;
        // //      physics = AlwaysScrollableScrollPhysics();
        // //     });
        // //   }
        // // });
        // // _animateControl.forward();
        // });

        // _animat = Tween<double>(begin: offset,end:0).animate(_animateControl)
        // ..addListener((){
        //   setState(() {
            
        //   });
        // })
        // ..addStatusListener((status){
        //   if(status == AnimationStatus.completed){
        //     setState(() {
        //       _refresh = RefreshStatus.none;
        //      _dragStatus = DragStatus.DropBiggerThanCritical;
        //      physics = AlwaysScrollableScrollPhysics();
        //     });
        //   }
        // });
        // _animateControl.forward();
      });
    }
    else{
      _controller
          .animateTo(0,duration: Duration(milliseconds: 1000),curve: Curves.linear)
          .whenComplete((){
            setState(() {
              _dragStatus = DragStatus.DropBiggerThanCritical;
            });
          });
    }
  }

  void onPointDown(PointerDownEvent event){
    _gesuture = GestureStatus.TouchDown;
    promptTime = DateTime.now();
  }

  void onPointMove(PointerMoveEvent event){
    _gesuture = GestureStatus.TouchMove;
    _refresh = RefreshStatus.drag;
    print('onPointMove');
    var offset = _controller.offset;
    if(offset < _criticalPos){
      _dragStatus = DragStatus.DropSmallerCritical;
    }
    else{
      _dragStatus = DragStatus.DropBiggerThanCritical;
    }
    setState(() {
      
    });
  }

  Widget widgetHeader(DragStatus status){
    Widget wid;
    switch(status){
      case DragStatus.DropBiggerThanCritical:{
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
      case DragStatus.DropOffControll:{
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
      case DragStatus.DropSmallerCritical:{
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
      case DragStatus.DropDone:{
        wid = Container(
          height: _headerMinHeight,
            color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('asserts/finish.png',width: 24,height: 24),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                Text('刷新完成'),
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
    // bool isDrag = _isDrag();
    // if(isDrag == false){
    //   return 0;
    // }
    // else{
    //   return -_controller.offset<_headerMinHeight?_headerMinHeight:-_controller.offset;
    // }
    if(_refresh == RefreshStatus.drag){
      return -_controller.offset;
    }
    else if(_refresh == RefreshStatus.done){
      return -_controller.offset;
    }
    else if(_refresh == RefreshStatus.back){
      return -_animat.value;
    }
    else{
      return 0;
    }
  }

  Widget header(){
    return Container(
      padding: EdgeInsets.only(top:0),
      height:getHeaderHeight(), 
      width: MediaQuery.of(context).size.width,
      child: widgetHeader(_dragStatus),
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
