import 'package:flutter/material.dart';
import 'models.dart';
import 'home.dart';
class OnboardingScreen extends StatefulWidget { const OnboardingScreen({super.key}); @override State<OnboardingScreen> createState()=>_S(); }
class _S extends State<OnboardingScreen>{ BodyType? selected;
  @override Widget build(BuildContext c)=>Scaffold(body:SafeArea(child:Padding(padding:const EdgeInsets.all(20),child:Column(children:[
    const SizedBox(height:30), const Icon(Icons.auto_awesome,size:54), const SizedBox(height:16),
    Text('Princess AI',style:Theme.of(c).textTheme.headlineLarge?.copyWith(fontWeight:FontWeight.bold)),
    const SizedBox(height:8), const Text('Выберите тип фигуры — приложение соберёт лучшие образы именно для вас.'),
    const SizedBox(height:20), Expanded(child:ListView(children:BodyType.values.map((b)=>Card(child:RadioListTile(value:b,groupValue:selected,title:Text(b.title),onChanged:(v)=>setState(()=>selected=v)))).toList())),
    FilledButton(onPressed:selected==null?null:()=>Navigator.pushReplacement(c,MaterialPageRoute(builder:(_)=>HomeScreen(body:selected!))),child:const Text('Создать мой стиль'))
  ]))));}
}
