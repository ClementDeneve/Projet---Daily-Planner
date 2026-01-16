import 'package:flutter/material.dart';

class TimelineEvent {
  final String time;
  final String title;
  final String? subtitle;
  const TimelineEvent({required this.time, required this.title, this.subtitle});
}

class DailyTimeline extends StatelessWidget {
  final List<TimelineEvent> events;
  const DailyTimeline({Key? key, this.events = const [
    TimelineEvent(time: '07:00', title: 'Réveil', subtitle: 'Petit-déjeuner'),
    TimelineEvent(time: '08:30', title: 'Trajet', subtitle: 'Aller au travail'),
    TimelineEvent(time: '09:00', title: 'Stand-up', subtitle: 'Réunion quotidienne'),
    TimelineEvent(time: '12:30', title: 'Déjeuner'),
    TimelineEvent(time: '15:00', title: 'Focus', subtitle: 'Travail sur projet'),
    TimelineEvent(time: '18:00', title: 'Sport', subtitle: 'Gym'),
    TimelineEvent(time: '20:00', title: 'Dîner', subtitle: 'Temps en famille'),
  ]}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final contentWidth = width > 600 ? 600.0 : width * 0.9;
    return Center(
      child: SizedBox(
        width: contentWidth,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final e = events[index];
            final isLast = index == events.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 72,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(e.time, style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title, style: Theme.of(context).textTheme.titleMedium),
                            if (e.subtitle != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(e.subtitle!, style: Theme.of(context).textTheme.bodySmall),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
