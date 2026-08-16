import 'package:googleapis/tasks/v1.dart' as tasks_api;
import 'package:http/http.dart' as http;

import '../auth/auth_service.dart';

class _AuthenticatedClient extends http.BaseClient {
  _AuthenticatedClient(this._headers, this._inner);

  final Map<String, String> _headers;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

class TasksService {
  TasksService._();
  static final TasksService instance = TasksService._();

  /// Adds a task with the given [title] to the user's default task list.
  Future<void> addTask(String title) async {
    final headers = await AuthService.instance.getAuthHeaders();
    if (headers == null) {
      throw StateError('Not signed in');
    }

    final client = _AuthenticatedClient(headers, http.Client());
    try {
      final api = tasks_api.TasksApi(client);
      await api.tasks.insert(tasks_api.Task(title: title), '@default');
    } finally {
      client.close();
    }
  }
}
