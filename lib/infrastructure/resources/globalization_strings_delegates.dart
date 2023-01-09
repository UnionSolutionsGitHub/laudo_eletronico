import 'dart:async';

import 'package:flutter/material.dart';

import './globalization_strings.dart';

class LocalizationStringsDelegate extends LocalizationsDelegate<GlobalizationStrings> {
  const LocalizationStringsDelegate();

  @override
  bool isSupported(Locale locale) => ['pt', 'en'].contains(locale.languageCode);

  @override
  Future<GlobalizationStrings> load(Locale locale) async {
    GlobalizationStrings localizations = new GlobalizationStrings(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationStringsDelegate old) => false;
}
