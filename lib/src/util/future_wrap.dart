import '../services/locator.dart';
import '../services/snackbar_service.dart';

// TODO: Not sure about this pattern. How can I make a beautiful and ergonomic snackbar wrapper for futures that might fail??
Future<T> withErrorMessage<T>(Future<T> future, String msg) async {
  try {
    final T result = await future;
    return result;
  } catch (e) {
    serviceLocator.get<SnackbarService>().simpleSnackbar(msg);
    rethrow;
  }
}
