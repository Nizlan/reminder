import 'package:shared_preferences/shared_preferences.dart';

updateId(int newId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('id', newId);
}

Future<int> getId() async {
  final prefs = await SharedPreferences.getInstance();
  if (_isIdExist(prefs)) {
    print('exist');
    return prefs.getInt('id')!;
  } else {
    print('dont exist');
    await updateId(0);
    return prefs.getInt('id')!;
  }
}

_isIdExist<bool>(SharedPreferences prefs) {
  return prefs.containsKey('id');
}
