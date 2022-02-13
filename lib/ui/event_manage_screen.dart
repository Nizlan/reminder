import 'package:flutter/material.dart';
import 'package:reminder/ui/events_screen.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:reminder/data/id_counter.dart';

import '../data/helpers/db_helper.dart';
import '../data/models/event_info.dart';
import '../domain/notification_api.dart';

class EventManageScreen extends StatefulWidget {
  final String timezone;
  final RegularEvent? event;
  const EventManageScreen({
    Key? key,
    required this.timezone,
    this.event,
  }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<EventManageScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  int? id;
  late DateTime _time;
  void listenNotifications() =>
      NotificationApi.onNotifications.listen(onClickedNotification);
  void onClickedNotification(String? payload) => {};

  void _selectTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _time.hour, minute: _time.minute),
    );
    if (newTime != null) {
      setState(() {
        _time = DateTime(
            _time.year, _time.month, _time.day, newTime.hour, newTime.minute);
      });
    }
  }

  @override
  void initState() {
    if (widget.event != null) {
      _title.text = widget.event!.name;
      _body.text = widget.event!.body;
      id = widget.event!.id;
    }
    tz.setLocalLocation(tz.getLocation(widget.timezone));
    _time = tz.TZDateTime.now(tz.local);
    NotificationApi().init();
    listenNotifications();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<int>(
          future: getId(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print('snapshot ${snapshot.data}');
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 100,
                      ),
                      // InkWell(
                      //   child: const Text('Добавить одинарное событие'),
                      //   onTap: () => DBHelper.insert('single_event', {
                      //     'id': 0,
                      //     'name': 'test1',
                      //     'time': '15:35:14',
                      //   }),
                      // ),
                      TextButton(
                        onPressed: _selectTime,
                        child: Text(
                          _time.hour.toString() +
                              ' : ' +
                              _time.minute.toString(),
                        ),
                      ),
                      TextField(
                        controller: _title,
                      ),
                      TextField(
                        controller: _body,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // TextButton(
                            //   onPressed: () => NotificationApi().showNotification(
                            //       title: 'Война', body: 'На украине', payload: 'ыыы'),
                            //   child: const Center(child: Text('Просто уведомление')),
                            // ),
                            if (id != null)
                              TextButton(
                                onPressed: () => {
                                  NotificationApi().deleteNotification(id!),
                                  DBHelper.delete(id!.toString()),
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: ((context) => EventsScreen(
                                              timezone: widget.timezone,
                                            )),
                                      ),
                                      (route) => false)
                                },
                                child: const Text('Удалить уведомление'),
                              ),
                            MaterialButton(
                              color: Colors.blue,
                              disabledColor: Colors.grey,
                              onPressed: () => (_title.text.isNotEmpty &&
                                      _body.text.isNotEmpty)
                                  ? {
                                      print('yes'),
                                      NotificationApi()
                                          .showScheduledNotification(
                                        id: id ?? snapshot.data!,
                                        title: _title.text,
                                        body: _body.text,
                                        scheduledDate: _time,
                                      ),
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: ((context) => EventsScreen(
                                                  timezone: widget.timezone,
                                                )),
                                          ),
                                          (route) => false)
                                    }
                                  : null,
                              child: const Center(
                                  child: Text('Уведомление по расписанию')),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return SizedBox();
            }
          }),
    );
  }
}
