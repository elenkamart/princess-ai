import 'package:flutter/material.dart';
import 'models.dart';
import 'princess_mode.dart';
class HomeScreen extends StatelessWidget { const HomeScreen({super.key,required this.body}); final BodyType body;
  @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Princess AI')),body:ListView(padding:const EdgeInsets.all(20),children:[
    Text('Добро пожаловать',style:Theme.of(c).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.bold)),
    const SizedBox(height:6),Text('Ваш тип фигуры: ${body.title}'),const SizedBox(height:24),
    Card(color:const Color(0xFF171717),child:Padding(padding:const EdgeInsets.all(22),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Icon(Icons.auto_awesome,color:Color(0xFFC8A96A)),const SizedBox(height:16),
      const Text('Сделай меня принцессой',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),const Text('Полный образ под фигуру, стиль и повод.',style:TextStyle(color:Colors.white70)),
      const SizedBox(height:18),FilledButton.tonal(onPressed:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>PrincessModeScreen(body:body))),child:const Text('Создать образ'))
    ])))
  ]));}
}
