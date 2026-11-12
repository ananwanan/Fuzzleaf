import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzleaf/app/fuzzleaf_app.dart';

void main() {
  testWidgets('displays the Fuzzleaf offline TTS prototype', (tester) async {
    await tester.pumpWidget(const FuzzleafApp());

    expect(find.text('绒页 · Fuzzleaf'), findsOneWidget);
    expect(find.text('把故事，轻轻讲给你听。'), findsOneWidget);
  });
}
