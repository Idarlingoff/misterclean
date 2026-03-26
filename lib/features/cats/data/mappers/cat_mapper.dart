import '../../domain/entities/cat.dart';
import '../models/cat_model.dart';

class CatMapper {
  static Cat toDomain(CatModel model) {
    //! 1.2.9 Robustness Principle
    //? Lancer une FormatException si le nom est trop court est trop strict.
    if (model.name.length < 2) {
      throw FormatException('Cat name too short: ${model.name}');
    }
    return Cat(
      id: model.id,
      name: model.name,
      origin: model.origin,
      nameUpperCase: model.name.toUpperCase(),
    );
  }

  static List<Cat> toDomainList(List<CatModel> models) {
    return models.map(toDomain).toList();
  }
}
