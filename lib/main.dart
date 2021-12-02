import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatBot',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'ChatBot Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final mensajeController = TextEditingController();
  List<Map> mensajes = List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ChatBot",
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                reverse: true,
                itemCount: mensajes.length,
                itemBuilder: (context, index) => chat(
                    mensajes[index]["mensaje"].toString(),
                    mensajes[index]["data"]),
              ),
            ),
            SizedBox(height: 20),
            Divider(
              height: 5.0,
              color: Colors.blue,
            ),
            Container(
              child: ListTile(
                title: Container(
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Color.fromRGBO(220, 220, 220, 1),
                  ),
                  padding: EdgeInsets.only(left: 15),
                  child: TextFormField(
                    controller: mensajeController,
                    decoration: InputDecoration(
                      hintText: "Escribre un mensaje aquí",
                      hintStyle: TextStyle(color: Colors.black26),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    //onChanged: (value) {},
                  ),
                ),
                trailing: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 30.0,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      if (mensajeController.text.isEmpty) {
                        print("Mensaje vacio");
                      } else {
                        setState(() {
                          mensajes.insert(0,
                              {"data": 1, "mensaje": mensajeController.text});
                        });
                        respuestaDialogFlow(mensajeController.text);
                        mensajeController.clear();
                      }
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    }),
              ),
            ),
            SizedBox(height: 15.0)
          ],
        ),
      ),
    );
  }

  void respuestaDialogFlow(consulta) async {
    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: "assets/service.json").build();
    Dialogflow dialogflow =
        Dialogflow(authGoogle: authGoogle, language: Language.spanish);
    AIResponse aiResponse = await dialogflow.detectIntent(consulta);
    setState(() {
      mensajes.insert(0, {
        "data": 0,
        "mensaje": aiResponse.getListMessage()[0]["text"]["text"][0].toString()
      });
    });
  }

  Widget chat(String mensaje, int data) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment:
            // data = 1 usuario       data = 0 Bot
            data == 1 ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          data == 0
              ? Container(
                  height: 60,
                  width: 60,
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/robot.png"),
                  ),
                )
              : Container(),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Bubble(
              radius: Radius.circular(15.0),
              color: data == 0
                  ? Color.fromRGBO(23, 157, 139, 1)
                  : Colors.orangeAccent,
              elevation: 0.0,
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(width: 10.0),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 200),
                        child: Text(
                          mensaje,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data == 1
              ? Container(
                  height: 60,
                  width: 60,
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/user.png"),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
