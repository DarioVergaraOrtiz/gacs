import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthController with ChangeNotifier {
  List<User> _users = [];
  bool _isAuthenticated = false;

  List<User> get users => _users;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final userStrings = prefs.getStringList('users') ?? [];
    
    _users = userStrings.map((userString) {
      final userMap = json.decode(userString);
      return User.fromMap(Map<String, dynamic>.from(userMap));
    }).toList();
    
    notifyListeners();
  }

  Future<void> register(User user) async {
    _users.add(user);
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setStringList(
      'users',
      _users.map((user) => json.encode(user.toMap())).toList(),
    );
    
    notifyListeners();
  }

  Future<bool> login(String name, String lastName) async {
    await loadUsers();
    final userExists = _users.any((user) => 
      user.name == name && user.lastName == lastName);
    
    _isAuthenticated = userExists;
    notifyListeners();
    
    return userExists;
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}