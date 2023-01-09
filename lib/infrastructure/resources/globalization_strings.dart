import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlobalizationStrings {  
  GlobalizationStrings(this.locale);  
  
  final Locale locale;  
  
  static GlobalizationStrings of(BuildContext context) {  
    return Localizations.of<GlobalizationStrings>(context, GlobalizationStrings);
  }  
  
  Map<String, String> _sentences;  
  
  Future<bool> load() async {
    String data = await rootBundle.loadString('assets/strings/${this.locale.languageCode}_${this.locale.countryCode}.json');
    Map<String, dynamic> _result = json.decode(data);

    this._sentences = new Map();
    _result.forEach((String key, dynamic value) {
      this._sentences[key] = value.toString();
    });

    return true;
  }
  
  String value(String key) {
    if (this._sentences == null){
      return key;
    }

    if (!this._sentences.containsKey(key)) {
      return key;
    }

    return this._sentences[key];
  }
}