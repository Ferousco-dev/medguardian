import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/models/user_account.dart';

class AuthController extends AsyncNotifier<UserAccount?> {
  @override
  Future<UserAccount?> build() {
    return ref.watch(authRepositoryProvider).currentUser();
  }

  Future<bool> signIn({required String email, required String password}) async {
    return _run(
      () => ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password),
    );
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return _run(
      () => ref
          .read(authRepositoryProvider)
          .signUp(fullName: fullName, email: email, password: password),
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncValue<UserAccount?>.data(null);
  }

  Future<bool> _run(Future<UserAccount> Function() action) async {
    state = const AsyncValue<UserAccount?>.loading();
    final AsyncValue<UserAccount?> result =
        await AsyncValue.guard<UserAccount?>(action);
    state = result;
    return !result.hasError;
  }
}

final AsyncNotifierProvider<AuthController, UserAccount?>
authControllerProvider = AsyncNotifierProvider<AuthController, UserAccount?>(
  AuthController.new,
);

final Provider<bool> isSignedInProvider = Provider<bool>((Ref ref) {
  return ref.watch(authControllerProvider).valueOrNull != null;
});
