/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

enum Category implements _is.SerializableModel {
  food,
  clothes,
  books,
  furniture,
  toys,
  tech,
  tools,
  home,
  supplies;

  static Category fromJson(String name) {
    switch (name) {
      case 'food':
        return Category.food;
      case 'clothes':
        return Category.clothes;
      case 'books':
        return Category.books;
      case 'furniture':
        return Category.furniture;
      case 'toys':
        return Category.toys;
      case 'tech':
        return Category.tech;
      case 'tools':
        return Category.tools;
      case 'home':
        return Category.home;
      case 'supplies':
        return Category.supplies;
      default:
        throw ArgumentError('Value "$name" cannot be converted to "Category"');
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
