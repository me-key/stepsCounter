// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'dart:async';
import 'dart:io';
import 'package:stepscounter/app_strings.dart';
import 'package:stepscounter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    
    // Mock Permission Handler to deny permissions (avoids Pedometer logic)
    const MethodChannel('flutter.baseflow.com/permissions/methods')
        .setMockMethodCallHandler((MethodCall methodCall) async {
          if (methodCall.method == 'requestPermissions') {
            return {19: 0}; // 0 = denied? We just need it to not be granted (1)
          }
          return null;
        });

    // Handle Network Image
    await HttpOverrides.runZoned(
      () async {
        // Build our app and trigger a frame.
        await tester.pumpWidget(const StepGoalApp());
        
        // Wait for async operations
        await tester.pumpAndSettle();

        // Verify that our step tracker shows steps.
        expect(find.text('0'), findsOneWidget);
        // Since default is Hebrew
        expect(find.text('יעד יומי: 10000'), findsOneWidget);
      },
      createHttpClient: (SecurityContext? context) {
         return MockHttpClient();
      },
    );
  });
}

class MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;
  
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => MockHttpClientRequest();
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => MockHttpClientResponse();
}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 404; 
  
  @override
  int get contentLength => 0;
  
  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;
  
  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return const Stream<List<int>>.empty().listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
