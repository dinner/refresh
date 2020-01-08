import 'package:flutter/material.dart';
import 'dart:math' as math;
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

/* 
********
下拉状态枚举
********
*/
enum RefreshStatus{
  /*
    未拖拽
  */
  none,
  /*
    下拉拖拽中
  */
  drag,
  /*
    刷新
  */
  refresh,
  /*
    刷新完毕
  */
  done,
  /*
    刷新后返回
  */
  back
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{
  int _counter                  = 20;
  int maxCount                  = 20;           //最大数
  ScrollController _controller  = new ScrollController();
  double _criticalPos           = -80;          //下拉最大下拉高度 超过-80则触发请求数据操作
  DateTime promptTime           = DateTime.now();//刷新提示展示的时间
  RefreshStatus _refresh        = RefreshStatus.none;
  bool _isRequestData           = false;        //是否在请求数据
  bool noMoreData               = false;        //是否还有更多数据

  AnimationController _animateControl;          //下拉返回的动画
  Animation<double> _animat;
  ScrollPhysics physics;
  double _refreshOffset;                        //偏移offset记录
  double rotate;

  @override
  void initState(){
    super.initState();
    _controller.addListener(() { 
      print(_controller.offset);
      if(_controller.position.pixels == 
        _controller.position.maxScrollExtent){//下滑到最底部
          loadData();
        }
    });

    _animateControl = AnimationController(duration: Duration(milliseconds:300 ),vsync: this);
    rotate = 0;
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }
  //加载数据
  Future<void> loadData()async{
    if(!_isRequestData){
      setState(() {
        _isRequestData = true;
      });
      await Future.delayed(Duration(seconds:2),(){
        setState(() {
          _isRequestData = false;
          if(_counter < maxCount){
            _counter += 5;
          }
          else{
            noMoreData = true;
          }
        });
      });
    }
  }

  Future<void>refreshData(VoidCallback call)async{
    if(!_isRequestData){
      setState(() {
        _isRequestData = true;
      });
      await Future.delayed(Duration(seconds:2),(){
        _counter = 20;
        _isRequestData = false;
        call();
      });
    }
  }

  //滑动手指抬起
  void onPointUp(PointerUpEvent event)async{
    print('onPointUp');
    var offset = _controller.offset;
    if(offset < 0){
      if(offset < _criticalPos){//启动动画
        _controller.jumpTo(_criticalPos);
        _refresh = RefreshStatus.refresh;
        setState(() {
          physics = NeverScrollableScrollPhysics();
        });
       await refreshData(()async{
          print('刷新完成');
          _refreshOffset = _criticalPos;
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
  }
  //手指按下
  void onPointDown(PointerDownEvent event){
    promptTime = DateTime.now();
  }
  //手指移动
  void onPointMove(PointerMoveEvent event){
    print('onPointMove');
    var offset = _controller.offset;
    if(offset < 0){
      if(offset <= _criticalPos && offset > -100){
        rotate = (_criticalPos - offset)/20* math.pi;
      }
      else if(offset > _criticalPos){
        rotate = 0;
      }
      else{
        rotate = math.pi;
      }
      _refresh = RefreshStatus.drag;
      setState(() {
        
      });
    }
  }

  Widget widgetHeader(RefreshStatus status){
    String img;
    String prompt;
    Widget widImg;

    switch(status){
      case RefreshStatus.refresh:{
        prompt = '正在刷新，请稍候';
        widImg = Padding(
                padding: EdgeInsets.only(right: 10),
                child:
                Container(
                  width: 24,
                  height: 24,
                  child:
              CircularProgressIndicator(
                valueColor:new AlwaysStoppedAnimation<Color>(Colors.black),
                strokeWidth:3,
              )));
      }break;
      case RefreshStatus.back:
      case RefreshStatus.none:{
        img = 'asserts/dropDown.png';
        prompt = '下拉刷新';

        widImg = Transform.rotate(
            angle: rotate,
            child:
          Image.asset(img,width: 24,height: 24));
      }break;
      case RefreshStatus.drag:{
        img = 'asserts/dropDown.png';
        prompt = _controller.offset>_criticalPos?'下拉刷新':'松开刷新';

        widImg = Transform.rotate(
            angle: rotate,
            child:
          Image.asset(img,width: 24,height: 24));
      }break;
      case RefreshStatus.done:{
        img = 'asserts/finish.png';
        prompt = '刷新完成';

        widImg = Image.asset(img,width: 24,height: 24);
      }break;
    }
    Widget wid = Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          widImg,
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

  double getHeaderHeight(){
    if(_refresh == RefreshStatus.drag||_refresh == RefreshStatus.refresh){
      if(_controller.offset < 0){
      return -_controller.offset;
      }
      else{
        return _controller.offset;
      }
    }
    else if(_refresh == RefreshStatus.done){
      if(_refreshOffset<0){
        return -_refreshOffset;
      }
      return _refreshOffset;
    }
    else if(_refresh == RefreshStatus.back){
      return -_animat.value;
    }
    else{
      return 0;
    }
  }

  Widget item(){
     return ListTile(
        title: Text('我是标题'),
        subtitle: Text('我是子标题'),
      );
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

  Widget footer(){
   return _isRequestData==true?
   noMoreData==false?
              Container(
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
        ):
        Container(
          color: Colors.transparent,
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                Text('没有更多数据了'),
                Text(
                  Utils.dateTimeToString(promptTime,'yyyy-MM-dd HH:mm')
                )
              ],)
            ],
          ),
        )
        :Container();
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
              return item();
            }
            ,childCount:_counter 
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (count,index){
              return footer();
            }
            ,childCount: 1
          ),
        )
      ],
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('刷新'),
        elevation: 0.0,
      ),
    body: getWid(),
    );
  }
}
