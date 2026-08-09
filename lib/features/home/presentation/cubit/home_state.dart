import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'home_cubit.dart';

abstract class HomeState extends Equatable {}

class HomeStateInitial extends HomeState {
  final int currentBottommNavIndex;

  HomeStateInitial({this.currentBottommNavIndex = 0});

  HomeStateInitial copyWith({int? currentBottommNavIndex}) => HomeStateInitial(
    currentBottommNavIndex:
        currentBottommNavIndex ?? this.currentBottommNavIndex,
  );

  @override
  List<Object?> get props => [currentBottommNavIndex];
}
