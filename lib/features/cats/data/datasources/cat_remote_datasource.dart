import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_constants.dart';
import '../models/cat_model.dart';

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final catRemoteDataSourceProvider = Provider<CatRemoteDataSourceImpl>((ref) {
  return CatRemoteDataSourceImpl(httpClient: ref.watch(httpClientProvider));
});

abstract class CatRemoteDataSource {
  Future<List<CatModel>> getCats(int page, int limit);
}

class CatRemoteDataSourceImpl implements CatRemoteDataSource {
  final http.Client httpClient;

  //! 1.1.2 OCP
  //? Cette suite de if/else if pour construire le path viole l'OCP : ajouter une version v3 oblige à modifier cette méthode.
  String apiVersion = 'v1';

  CatRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<List<CatModel>> getCats(int page, int limit) async {
    String path;
    if (apiVersion == 'v1') {
      path = '/v1/breeds';
    } else if (apiVersion == 'v2') {
      path = '/v2/breeds';
    } else {
      path = '/v1/breeds';
    }

    final queryParameters = {
      'limit': '$limit',
      'page': '$page',
    };
    final uri = Uri.https(
      ApiConstants.catApiBaseUrl,
      path,
      queryParameters,
    );

    final response = await httpClient.get(uri);

    if (response.statusCode != 200) {
      throw ServerFailure('Cat API returned status ${response.statusCode}');
    }

    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList
        .map((json) => CatModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
