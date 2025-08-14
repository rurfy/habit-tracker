import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup_habits/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
  });

  test('save and load habits', () async {
    await storage.save('{"test":"value"}');
    final result = await storage.load();
    expect(result, '{"test":"value"}');
  });

  test('delete habits', () async {
    await storage.save('{"test":"value"}');
    await storage.delete();
    final result = await storage.load();
    expect(result, isNull);
  });
}
