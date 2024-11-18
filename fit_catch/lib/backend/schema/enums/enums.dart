import 'package:collection/collection.dart';

enum StyleValues {
  Simple,
  Comfortable,
  Trendy,
  Classic,
  Colorful,
  Sophisticated,
}

enum CategoryValues {
  Top,
  Bottom,
  Outer,
  Accessory,
}

extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case (StyleValues):
      return StyleValues.values.deserialize(value) as T?;
    case (CategoryValues):
      return CategoryValues.values.deserialize(value) as T?;
    default:
      return null;
  }
}
