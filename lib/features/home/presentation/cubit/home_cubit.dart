part of 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeStateInitial());

  void changeBottomNavCurrent(int index) {
    if (state is HomeStateInitial) {
      emit((state as HomeStateInitial).copyWith(currentBottommNavIndex: index));
    }
  }
}
