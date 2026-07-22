import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/storage/token_store.dart';
import '../demo/demo_data.dart';
import '../models/user_account.dart';

abstract interface class AuthRepository {
  Future<UserAccount> signIn({required String email, required String password});

  Future<UserAccount> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<UserAccount?> currentUser();

  Future<void> signOut();
}

class RemoteAuthRepository implements AuthRepository {
  const RemoteAuthRepository(this._client, this._tokenStore);

  final ApiClient _client;
  final TokenStore _tokenStore;

  @override
  Future<UserAccount> signIn({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> response = await _client
        .post<Map<String, dynamic>>(
          ApiEndpoints.login,
          body: <String, dynamic>{'email': email, 'password': password},
        );

    return _persist(response);
  }

  @override
  Future<UserAccount> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> response = await _client
        .post<Map<String, dynamic>>(
          ApiEndpoints.register,
          body: <String, dynamic>{
            'full_name': fullName,
            'email': email,
            'password': password,
          },
        );

    return _persist(response);
  }

  @override
  Future<UserAccount?> currentUser() async {
    final String? token = await _tokenStore.read();
    if (token == null || token.isEmpty) {
      return null;
    }

    final Map<String, dynamic> response = await _client
        .get<Map<String, dynamic>>(ApiEndpoints.me);
    return UserAccount.fromJson(response);
  }

  @override
  Future<void> signOut() async {
    await _tokenStore.clear();
  }

  Future<UserAccount> _persist(Map<String, dynamic> response) async {
    final String token = response['access_token'] as String;
    await _tokenStore.write(token);
    return UserAccount.fromJson(response['user'] as Map<String, dynamic>);
  }
}

class MockAuthRepository implements AuthRepository {
  MockAuthRepository();

  UserAccount? _session;

  static const Duration _latency = Duration(milliseconds: 700);

  @override
  Future<UserAccount> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    _session = DemoData.account;
    return _session!;
  }

  @override
  Future<UserAccount> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    _session = UserAccount(
      id: 'user_demo',
      fullName: fullName,
      email: email,
      twinId: null,
    );
    return _session!;
  }

  @override
  Future<UserAccount?> currentUser() async => _session;

  @override
  Future<void> signOut() async {
    _session = null;
  }
}
