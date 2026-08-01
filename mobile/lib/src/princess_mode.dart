import 'package:flutter/material.dart';
import 'api.dart';
import 'models.dart';
class PrincessModeScreen extends StatefulWidget { const PrincessModeScreen({super.key,required this.body}); final BodyType body; @override State<PrincessModeScreen> createState()=>_S(); }
class _S extends State<PrincessModeScreen>{ final api=ApiClient(); String occasion='Свидание'; String style='Romantic'; final budget=TextEditingController(text:'200'); bool loading=false; String? error; PrincessOutfit? outfit;
  Future<void> run() async { setState((){loading=true;error=null;}); try{final o=await api.generate(widget.body,occasion,style,double.tryParse(budget.text));setState(()=>outfit=o);}catch(e){setState(()=>error='$e');}finally{setState(()=>loading=false);} }
  @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Princess Mode')),body:ListView(padding:const EdgeInsets.all(20),children:[
    DropdownButtonFormField(value:occasion,decoration:const InputDecoration(labelText:'Повод'),items:['Свидание','Работа','Театр','Прогулка'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>occasion=v!)),const SizedBox(height:12),
    DropdownButtonFormField(value:style,decoration:const InputDecoration(labelText:'Стиль'),items:['Romantic','Quiet Luxury','Old Money','Minimalism'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(v)=>setState(()=>style=v!)),const SizedBox(height:12),
    TextField(controller:budget,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Бюджет',suffixText:'EUR')),const SizedBox(height:16),
    FilledButton.icon(onPressed:loading?null:run,icon:const Icon(Icons.auto_awesome),label:Text(loading?'Создаём...':'Сделай меня принцессой')),
    if(error!=null) Padding(padding:const EdgeInsets.only(top:16),child:Text('Запустите backend на порту 8000. $error',style:const TextStyle(color:Colors.red))),
    if(outfit!=null) ...[const SizedBox(height:24),Text('${outfit!.title} — ${outfit!.score}/100',style:Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),const SizedBox(height:12),...outfit!.items.map((i)=>Card(child:ListTile(title:Text(i.name),subtitle:Text(i.reason)))),const SizedBox(height:12),...outfit!.explanation.map((e)=>ListTile(leading:const Icon(Icons.check_circle),title:Text(e)))]
  ]));}
}
