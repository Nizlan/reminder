import 'package:flutter/material.dart';

abstract class EventInfo {
  final int id;
  final String name;
  final String body;
  EventInfo({
    required this.id,
    required this.name,
    required this.body,
  });
}

class SingleEvent extends EventInfo {
  final DateTime datetime;

  SingleEvent(
      {required int id,
      required String name,
      required String body,
      required this.datetime})
      : super(id: id, name: name, body: body);
}

class RegularEvent extends EventInfo {
  final TimeOfDay time;

  RegularEvent(
      {required int id,
      required String name,
      required String body,
      required this.time})
      : super(id: id, name: name, body: body);
}
