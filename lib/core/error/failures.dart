abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

//! 1.1.4 ISP
//? L'extension FailureIcon ajoute la propriété icon à toutes les Failure. 
extension FailureIcon on Failure {
  String get icon {
    if (this is ServerFailure) {
      return '🌐';
    }
    if (this is NetworkFailure) {
      return '📡';
    }
    return '❓';
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

void _retryRequest() {
  Future.delayed(const Duration(seconds: 1));
}
