import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/height/domain/repositories/height_repository.dart';

abstract class DeleteHeightUseCase {
  Future<Result<void, String>> call(String id);
}

@Injectable(as: DeleteHeightUseCase)
class DeleteHeightUseCaseImpl implements DeleteHeightUseCase {
  const DeleteHeightUseCaseImpl({required this._repository});

  final HeightRepository _repository;

  @override
  Future<Result<void, String>> call(String id) => _repository.deleteHeight(id);
}
