import 'dart:io';

import 'package:user_app/features/profile/domain/models/profile_model.dart';
import 'package:user_app/interface/repo_interface.dart';

abstract class ProfileRepositoryInterface implements RepositoryInterface{

  Future<dynamic> getProfileInfo();
  Future<dynamic> updateProfile(ProfileModel userInfoModel, String pass, File? file, String token);
}