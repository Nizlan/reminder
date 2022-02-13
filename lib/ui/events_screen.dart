import 'package:flutter/material.dart';
import 'package:reminder/data/helpers/db_helper.dart';

import 'package:reminder/data/models/event_info.dart';
import 'package:reminder/ui/event_manage_screen.dart';

class EventsScreen extends StatefulWidget {
  final String timezone;
  const EventsScreen({
    Key? key,
    required this.timezone,
  }) : super(key: key);

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  // List<SingleEvent> singleEvents = [];
  // List<RegularEvent> regularEvents = [];

  Future<List<SingleEvent>> getSingleEvents() async {
    final datalist = await DBHelper.getData('single_event');
    List<SingleEvent> singleEvents = datalist
        .map(
          (e) => SingleEvent(
            id: int.parse(e['id']),
            name: e['name'],
            body: e['body'],
            datetime: DateTime.now(),
          ),
        )
        .toList();
    return singleEvents;
  }

  Future<List<RegularEvent>> getRegularEvents() async {
    final datalist = await DBHelper.getData('regular_event');
    final _dateTimeNow = DateTime.now();
    List<RegularEvent> regularEvent = datalist
        .map((e) => RegularEvent(
            id: int.parse(e['id']),
            name: e['name'],
            body: e['body'],
            time: TimeOfDay(
                hour: _dateTimeNow.hour, minute: _dateTimeNow.minute)))
        .toList();
    return regularEvent;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Ваши события'),
        ),
        body: FutureBuilder<List<RegularEvent>>(
            future: getRegularEvents(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print('snapshot ${snapshot.data!.length}');
                return GridView.builder(
                  itemCount: snapshot.data!.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(snapshot.data![index].name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(snapshot.data![index].body),
                            Text(snapshot.data![index].time.toString()),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: ((context) => EventManageScreen(
                                  timezone: widget.timezone,
                                  event: snapshot.data![index],
                                )),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const SizedBox();
              }
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) => EventManageScreen(
                    timezone: widget.timezone,
                  )),
            ),
          ),
          child: const Icon(Icons.add),
        ));
  }
}
