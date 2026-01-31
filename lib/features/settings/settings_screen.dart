import 'package:flutter/material.dart';
import '../../core/services/currency_service.dart';
import '../../core/animations/micro_interactions.dart';
import '../../core/constants/spacing.dart';

class SettingsScreen extends StatelessWidget {
  static const route = '/settings';
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = CurrencyService.instance;
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Currency', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: Spacing.sm),
            ValueListenableBuilder<String>(
              valueListenable: service.code,
              builder: (ctx, code, _) => Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: code,
                      items: service.supported
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                '$c (${CurrencyService.symbolMap[c]})',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) service.set(v);
                      },
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  SizedBox(width: Spacing.md),
                  ScaleOnTap(
                    onTap: () => service.set('INR'),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).cardColor,
                      ),
                      child: Text('Default (INR)'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
