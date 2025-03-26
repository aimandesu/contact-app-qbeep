import 'package:contact_app_qbeep/data/model/user_contact.dart';
import 'package:dio/dio.dart';

abstract class ContactRepository {
  Future<List<UserContact>> getUserContact({int perPage});
}

class ContactRepositoryImpl extends ContactRepository {
  @override
  Future<List<UserContact>> getUserContact({
    perPage = 12,
  }) async {
    Dio dio = Dio();
    Response response =
        await dio.get('https://reqres.in/api/users?per_page=$perPage');

    return List<UserContact>.from(
        response.data['data'].map((e) => UserContact.fromJson(e)));
  }
}
