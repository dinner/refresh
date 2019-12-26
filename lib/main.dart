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

  void _incrementCounter() {
    setState(() {
      _counter+=20;
    });
  }

  @override
  void initState(){
    super.initState();
    _controller.addListener(() => print(_controller.offset));
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body:ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (cot,index){
          return ListTile(
            title: Text('我是元素'),
            subtitle: Text('我是子元素'),
          );
        },
        itemCount: _counter,
        controller: _controller,
      ) 
    );
  }
}
