import 'package:bloc/bloc.dart';

class GenericCubit<T> extends Cubit<T> {
  GenericCubit(super.initialValue);

  void updateValue(T newValue) => emit(newValue);
}
