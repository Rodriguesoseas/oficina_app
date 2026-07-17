import '../core/api/api_client.dart';
import '../models/dashboard_data.dart';

class DashboardService {
  DashboardService(this._client);

  final ApiClient _client;

  Future<DashboardData> carregar() {
    return _client.get<DashboardData>(
      '/dashboard',
      parser: (data) => DashboardData.fromJson(data as Map<String, dynamic>),
    );
  }
}
