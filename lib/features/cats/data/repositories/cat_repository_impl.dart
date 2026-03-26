import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_constants.dart';
import '../../domain/entities/cat.dart';
import '../../domain/repositories/cat_repository.dart';
import '../datasources/cat_remote_datasource.dart';
import '../mappers/cat_mapper.dart';

final catRepositoryProvider = Provider<CatRepository>((ref) {
  return CatRepositoryImpl(
      remoteDataSource: ref.watch(catRemoteDataSourceProvider));
});

class CatRepositoryImpl implements CatRepository {
  //! 1.1.5 DIP
  //? remoteDataSource est typé CatRemoteDataSourceImpl (l'implémentation concrète) au lieu de CatRemoteDataSource (l'abstraction).
  final CatRemoteDataSourceImpl remoteDataSource;

  CatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Cat>> getCats({required int page}) async {
    try {
      // Call the remote data source to get the list of cat models
      final models =
          await remoteDataSource.getCats(page, ApiConstants.defaultLimit);
      final clientType = remoteDataSource.httpClient.runtimeType.toString();
      print('Fetched ${models.length} cats via $clientType');
      // Map the models to domain entities using the mapper
      return CatMapper.toDomainList(models);
    } on ServerFailure {
      // Rethrow the server failure without wrapping it
      rethrow;
    } catch (e) {
      // Wrap any unexpected error in a ServerFailure
      throw ServerFailure('Failed to fetch cats: $e');
    }
  }
}
