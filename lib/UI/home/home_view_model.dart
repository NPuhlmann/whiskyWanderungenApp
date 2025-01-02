import 'package:flutter/cupertino.dart';
import 'package:whisky_hikes/data/repositories/user_repository.dart';

class HomePageViewModel extends ChangeNotifier{

  HomePageViewModel({
    required UserRepository userRepository,
}): _userRepository = userRepository;

  final UserRepository _userRepository;

  void signOut(){
    _userRepository.signUserOut();
    notifyListeners();
  }

}