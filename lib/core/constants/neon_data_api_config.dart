import '../errors/api_configuration_exception.dart';

class NeonDataApiConfig {
  factory NeonDataApiConfig({required String baseUrl}) {
    final trimmedBaseUrl = baseUrl.trim();
    final Uri baseUri;
    try {
      baseUri = Uri.parse(trimmedBaseUrl);
    } on FormatException catch (error) {
      throw ApiConfigurationException('La URL de Neon no es válida: $error');
    }

    final isLocalhost =
        baseUri.host == 'localhost' ||
        baseUri.host == '127.0.0.1' ||
        baseUri.host == '::1';
    if (!baseUri.hasAuthority ||
        baseUri.host.isEmpty ||
        (baseUri.scheme != 'https' && !(isLocalhost && baseUri.scheme == 'http')) ||
        baseUri.userInfo.isNotEmpty ||
        baseUri.hasQuery ||
        baseUri.hasFragment) {
      throw const ApiConfigurationException(
        'Configura una URL HTTPS válida para Neon Data API (HTTP solo se permite '
        'en localhost). No incluyas credenciales, parámetros ni fragmentos.',
      );
    }

    final path = baseUri.path.replaceFirst(RegExp(r'/+$'), '');
    return NeonDataApiConfig._(baseUri.replace(path: path));
  }

  const NeonDataApiConfig._(this.baseUri);

  factory NeonDataApiConfig.fromEnvironment() {
    const baseUrl = String.fromEnvironment('NEON_DATA_API_URL');
    if (baseUrl.isEmpty) {
      throw const ApiConfigurationException(
        'Falta NEON_DATA_API_URL. Configúrala con --dart-define.',
      );
    }
    return NeonDataApiConfig(baseUrl: baseUrl);
  }

  final Uri baseUri;
}
