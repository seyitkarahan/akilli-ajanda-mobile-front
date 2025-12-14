import 'package:akilli_ajanda_front/model/category_request.dart';
import 'package:flutter/material.dart';
import '../model/category_response.dart';
import '../service/api_service.dart';

class CategoryViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<CategoryResponse> _categories = [];

  List<CategoryResponse> get categories => _categories;

  Future<void> fetchCategories() async {
    _categories = await _apiService.getCategories();
    notifyListeners();
  }

  Future<void> addCategory(CategoryRequest request) async {
    try {
      var newCategory = await _apiService.createCategory(request);
      if (newCategory != null) {
        _categories.add(newCategory);
        notifyListeners();
      }
    } catch (e) {
      // Hata yönetimi
      print(e);
    }
  }

  Future<void> updateCategory(int id, CategoryRequest request) async {
    try {
      var updatedCategory = await _apiService.updateCategory(id, request);
      if (updatedCategory != null) {
        int index = _categories.indexWhere((cat) => cat.id == id);
        if (index != -1) {
          _categories[index] = updatedCategory;
          notifyListeners();
        }
      }
    } catch (e) {
      // Hata yönetimi
      print(e);
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      await _apiService.deleteCategory(categoryId);
      _categories.removeWhere((category) => category.id == categoryId);
      notifyListeners();
    } catch (e) {
      // Hata yönetimi burada yapılabilir
      print(e);
    }
  }
}
