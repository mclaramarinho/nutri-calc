import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'injectable',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt();
