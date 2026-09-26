import 'package:dartz/dartz.dart';
import 'package:flutter_base/core/error/exceptions.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/core/services/local_storage/app_secure_storage.dart';
import 'package:flutter_base/core/services/local_storage/app_shared_preferences.dart';
import 'package:flutter_base/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_base/features/auth/data/models/requests/login_request.dart';
import 'package:flutter_base/features/auth/data/models/requests/register_request.dart';
import 'package:flutter_base/features/auth/data/models/responses/auth_token_response.dart';
import 'package:flutter_base/features/auth/data/repos/auth_repository_impl.dart';
import 'package:flutter_base/features/auth/domain/entities/login_credentials.dart';
import 'package:flutter_base/features/auth/domain/entities/registration_details.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRemote implements AuthRemoteDataSource {
  Object? error;
  LoginRequest? lastLogin;
  RegisterRequest? lastRegister;

  Future<AuthTokenResponse> _respond() async {
    if (error != null) throw error!;
    return const AuthTokenResponse(token: 'token-123');
  }

  @override
  Future<AuthTokenResponse> login(LoginRequest request) {
    lastLogin = request;
    return _respond();
  }

  @override
  Future<AuthTokenResponse> register(RegisterRequest request) {
    lastRegister = request;
    return _respond();
  }
}

class _FakeSecureStorage extends AppSecureStorage {
  _FakeSecureStorage() : super(instance: const FlutterSecureStorage());

  String? token;
  bool failWrites = false;

  @override
  Future<String?> getAccessToken() async => token;

  @override
  Future<void> saveAccessToken(String? value) async {
    if (failWrites) throw Exception('keystore unavailable');
    token = value;
  }

  @override
  Future<void> removeAccessToken() async {
    if (failWrites) throw Exception('keystore unavailable');
    token = null;
  }

  @override
  Future<String?> getDeviceToken() async => null;

  @override
  Future<void> saveDeviceToken(String token) async {}

  @override
  Future<void> removeDeviceToken() async {}

  @override
  Future<void> clearAll() async => token = null;
}

const LoginCredentials _credentials = LoginCredentials(
  phone: '+966512345678',
  password: 'secret123',
);

const RegistrationDetails _details = RegistrationDetails(
  name: 'Sara Customer',
  phone: '+966512345678',
  email: 'sara@ssm.test',
  password: 'secret123',
);

void main() {
  late _FakeRemote remote;
  late _FakeSecureStorage storage;
  late AppSharedPreferences preferences;
  late AuthRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    remote = _FakeRemote();
    storage = _FakeSecureStorage();
    preferences = AppSharedPreferencesImpl(
      instance: await SharedPreferences.getInstance(),
    );
    repository = AuthRepositoryImpl(
      remote: remote,
      secureStorage: storage,
      sharedPreferences: preferences,
    );
  });

  group('logout', () {
    test('discards the stored token', () async {
      storage.token = 'token-123';

      final Either<Failure, Unit> result = await repository.logout();

      expect(result, const Right<Failure, Unit>(unit));
      expect(storage.token, isNull);
    });

    test('discards the cached profile', () async {
      await preferences.saveUser(<String, dynamic>{'id': 7, 'name': 'Sara'});
      await preferences.saveUserId(7);

      await repository.logout();

      expect(preferences.getUser(), isNull);
      expect(preferences.getUserId(), isNull);
    });

    test('reports CacheFailure when the token cannot be removed', () async {
      storage
        ..token = 'token-123'
        ..failWrites = true;

      final Either<Failure, Unit> result = await repository.logout();

      expect(result, const Left<Failure, Unit>(CacheFailure()));
    });
  });

  group('login', () {
    test('stores the returned token and succeeds', () async {
      final Either<Failure, Unit> result = await repository.login(_credentials);

      expect(result, const Right<Failure, Unit>(unit));
      expect(storage.token, 'token-123');
    });

    test('sends the credentials to the remote', () async {
      await repository.login(_credentials);

      expect(remote.lastLogin?.toJson()['email_or_phone'], '+966512345678');
      expect(remote.lastLogin?.toJson()['password'], 'secret123');
    });

    test('maps a 401 to UnauthorizedFailure and stores nothing', () async {
      remote.error = const UnauthorizedException(message: 'Unauthorized.');

      final Either<Failure, Unit> result = await repository.login(_credentials);

      expect(
        result,
        const Left<Failure, Unit>(
          UnauthorizedFailure(message: 'Unauthorized.'),
        ),
      );
      expect(storage.token, isNull);
    });

    test('maps a 429 to TooManyRequestsFailure', () async {
      remote.error = const TooManyRequestsException();

      final Either<Failure, Unit> result = await repository.login(_credentials);

      expect(result, const Left<Failure, Unit>(TooManyRequestsFailure()));
    });

    test('reports CacheFailure when the token cannot be stored', () async {
      storage.failWrites = true;

      final Either<Failure, Unit> result = await repository.login(_credentials);

      expect(result, const Left<Failure, Unit>(CacheFailure()));
    });

    test('maps an unexpected error to ServerFailure', () async {
      remote.error = StateError('boom');

      final Either<Failure, Unit> result = await repository.login(_credentials);

      expect(result, const Left<Failure, Unit>(ServerFailure()));
    });
  });

  group('register', () {
    test('stores the returned token and succeeds', () async {
      final Either<Failure, Unit> result = await repository.register(_details);

      expect(result, const Right<Failure, Unit>(unit));
      expect(storage.token, 'token-123');
    });

    test('sends the details to the remote', () async {
      await repository.register(_details);

      expect(remote.lastRegister?.toJson(), <String, dynamic>{
        'name': 'Sara Customer',
        'phone': '+966512345678',
        'email': 'sara@ssm.test',
        'password': 'secret123',
      });
    });

    test(
      'maps a duplicate-phone 403 to ForbiddenFailure with its code',
      () async {
        remote.error = const ForbiddenException(
          message: 'The phone has already been taken.',
          code: 'phone',
        );

        final Either<Failure, Unit> result = await repository.register(
          _details,
        );

        expect(
          result,
          const Left<Failure, Unit>(
            ForbiddenFailure(
              message: 'The phone has already been taken.',
              code: 'phone',
            ),
          ),
        );
        expect(storage.token, isNull);
      },
    );
  });
}
