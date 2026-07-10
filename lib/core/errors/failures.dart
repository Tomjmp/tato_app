abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Ocurrió un error en el servidor.']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Error de almacenamiento local.']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Sin conexión a internet.']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
