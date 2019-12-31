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
  none,drag,refresh,done,back
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  int _counter = 5;
  ScrollController _controller = new ScrollController();
  double _criticalPos = -80;
  AnimationController _animateControl;
  Animation<double> _animat;

  DateTime promptTime=DateTime.now();//刷新提示展示的时间
  bool _isFirstRefresh = true;

  ScrollPhysics physics;
  RefreshStatus _refresh = RefreshStatus.none;
  double _refreshOffset;

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

    _animateControl = AnimationController(duration: Duration(milliseconds:300 ),vsync: this);
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  void onPointUp(PointerUpEvent event)async{
    print('onPointUp');
    var offset = _controller.offset;
    if(offset < _criticalPos){//启动动画
      _refresh = RefreshStatus.refresh;
      setState(() {
        physics = NeverScrollableScrollPhysics();
      });
      await Future.delayed(Duration(milliseconds: 2000),()async{
        print('刷新完成');
        _refreshOffset = -offset;
        _refresh = RefreshStatus.done;
        setState(() {
          
        });

        await Future.delayed(Duration(seconds:1),(){
          _refresh = RefreshStatus.back;
          _animat = Tween<double>(begin: _refreshOffset,end:0).animate(_animateControl)
        ..addListener((){
          setState(() {
            
          });
        })
        ..addStatusListener((status){
          if(status == AnimationStatus.completed){
            setState(() {
              _refresh = RefreshStatus.none;
             physics = AlwaysScrollableScrollPhysics();
             _animateControl.reset();
            });
          }
        });
        _animateControl.forward();
        });
      });
    }
    else{
      _refreshOffset = -offset;
          _refresh = RefreshStatus.back;
          _animat = Tween<double>(begin: _refreshOffset,end:0).animate(_animateControl)
        ..addListener((){
          setState(() {
            
          });
        })
        ..addStatusListener((status){
          if(status == AnimationStatus.completed){
            setState(() {
              _refresh = RefreshStatus.none;
             physics = AlwaysScrollableScrollPhysics();
             _animateControl.reset();
            });
          }
        });
        _animateControl.forward();
    }
  }

  void onPointDown(PointerDownEvent event){
    promptTime = DateTime.now();
  }

  void onPointMove(PointerMoveEvent event){
    _refresh = RefreshStatus.drag;
    print('onPointMove');
    setState(() {
      
    });
  }

  Widget widgetHeader(RefreshStatus status){
    String img;
    String prompt;

    switch(status){
      case RefreshStatus.refresh:{
        return Container(
          // height: getHeaderHeight(),
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
      case RefreshStatus.back:
      case RefreshStatus.none:{
        img = 'asserts/dropDown.png';
        prompt = '下拉刷新';
      }break;
      case RefreshStatus.drag:{
        img = _controller.offset>_criticalPos?'asserts/dropDown.png':'asserts/dropUp.png';
        prompt = _controller.offset>_criticalPos?'下拉刷新':'松开刷新';
      }break;
      case RefreshStatus.done:{
        img = 'asserts/finish.png';
        prompt = '刷新完成';
      }break;
    }
    Widget wid = Container(
      // height: getHeaderHeight(),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(img,width: 24,height: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            Text(prompt),
            Text(
              Utils.dateTimeToString(promptTime,'yyyy-MM-dd HH:mm')
            )
          ],)
        ],
      ),
    );
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
    if(_refresh == RefreshStatus.drag||_refresh == RefreshStatus.refresh){
      return -_controller.offset;
    }
    else if(_refresh == RefreshStatus.done){
      return _refreshOffset;
    }
    else if(_refresh == RefreshStatus.back){
      return _animat.value;
    }
    else{
      return 0;
    }
  }

  Widget header(){
    return Container(
      height:getHeaderHeight(), 
      width: MediaQuery.of(context).size.width,
      child:FittedBox(
        fit:BoxFit.none,
        alignment: Alignment.bottomCenter,
        child:
       widgetHeader(_refresh),
    )
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
