import 'package:flutter_test/flutter_test.dart';
import 'package:princess_ai/src/app.dart';
void main(){testWidgets('shows onboarding',(t)async{await t.pumpWidget(const PrincessAiApp());expect(find.text('Princess AI'),findsOneWidget);});}
