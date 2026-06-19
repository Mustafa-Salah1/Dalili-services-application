import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static final Box servicesBox = Hive.box('services_box');

  static final Box providersBox = Hive.box('providers_box');

}
