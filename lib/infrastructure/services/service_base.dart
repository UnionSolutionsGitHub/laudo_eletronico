import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:laudo_eletronico/infrastructure/resources/local_resources.dart';

class ServiceBase {
  String urlBase;

  ServiceBase({
    @required this.urlBase,
  });

  Future<dynamic> get<T extends DataTransferObject>({
    @required String serviceName,
    @required T object,
  }) async {
    final token = (await LocalResources().instance()).token;

    final response = await http.get(
      "$urlBase$serviceName",
      headers: {
        "Authorization": token,
      },
    );

    if (response.statusCode == 200) {
      return await object
          .fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception(response.statusCode);
    }
  }

  Future<dynamic> postAsJson<T extends DataTransferObject>({
    @required String serviceName,
    @required T object,
  }) async {
    try {
      final token = (await LocalResources().instance()).token;

      final request = http.Request("POST", Uri.parse("$urlBase$serviceName"));

      request.headers.addAll({
        "Authorization": token,
        "content-type": "application/json",
      });

      request.body = jsonEncode(object);
      final response = await http.Response.fromStream(
        await request.send().timeout(const Duration(seconds: 90)),
      );

      if (response.statusCode == 200) {
        if (response?.body?.isNotEmpty == true) {
          return await object
              .fromJson(json.decode(utf8.decode(response.bodyBytes)));
        }

        return true;
      } else {
        throw Exception(response.statusCode);
      }
    } catch (e) {
      throw Exception(e.message);
    }
  }

  Future<dynamic> postAsFormData({
    @required String serviceName,
    @required File file,
  }) async {
    try {
      final token = (await LocalResources().instance()).token;

      final request =
          http.MultipartRequest("POST", Uri.parse("$urlBase$serviceName"));

      request.headers.addAll({
        "Authorization": token,
      });

      request.files.add(http.MultipartFile(
        "foto",
        file.openRead(),
        await file.length(),
      ));

      final response = await http.Response.fromStream(
        await request.send().timeout(const Duration(minutes: 1)),
      );

      if (response.statusCode == 200) {
        if (response?.body?.isNotEmpty == true) {
          return json.decode(utf8.decode(response.bodyBytes));
        }

        return true;
      } else {
        throw Exception(response.statusCode);
      }
    } on TimeoutException catch (e) {
      throw e;
    } catch (e) {
      throw Exception(e.message);
    }
  }

  Future<String> post<T extends DataTransferObject>({
    @required String serviceName,
    @required T object,
  }) async {
    try {
      final response = await http.post(
        "$urlBase$serviceName",
        body: object.toJson(),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(response.statusCode);
      }
    } catch (e) {
      throw Exception(e.message);
    }
  }
}

abstract class DataTransferObject<T> {
  Future<T> fromJson(dynamic json);

  Map<String, dynamic> toJson();
}
