import 'package:flutter/material.dart';
import '../service/api_service.dart';
import '../model/category_request.dart';
import '../model/category_response.dart';

class CategoriesViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CategoryResponse> _categories = [];
  List<CategoryResponse> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CategoriesViewModel() {
    loadCategories();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _setLoading(true);
    _categories = await _apiService.getCategories();
    _setLoading(false);
  }

  Future<void> createCategory(String name) async {
    final request = CategoryRequest(name: name);
    final newCategory = await _apiService.createCategory(request);
    if (newCategory != null) {
      _categories.add(newCategory);
      notifyListeners();
    }
  }

  Future<void> updateCategory(int id, String newName) async {
    final request = CategoryRequest(name: newName);
    final updatedCategory = await _apiService.updateCategory(id, request);
    if (updatedCategory != null) {
      final index = _categories.indexWhere((cat) => cat.id == id);
      if (index != -1) {
        _categories[index] = updatedCategory;
        notifyListeners();
      }
    }
  }

  Future<void> deleteCategory(int id) async {
    await _apiService.deleteCategory(id);
    _categories.removeWhere((cat) => cat.id == id);
    notifyListeners();
  }
}
