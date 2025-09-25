import 'package:another_telephony/telephony.dart';
import 'package:dhanra/core/services/sms_parser_service.dart';
import 'package:dhanra/firebase_options.dart';
import 'package:dhanra/injection.dart';
import 'package:dhanra/features/splash/dhanra_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'core/services/local_storage_service.dart';

@pragma('vm:entry-point')
void onBackgroundMessage(SmsMessage message) async {
  try {
    final storage = LocalStorageService();
    if (storage.isLoggedIn) {
      final smsMap = {
        'sender': message.address ?? '',
        'body': message.body ?? '',
        'date': message.date?.toString() ?? '',
      };

      final List<Map<String, String>> parsed = await SmsParserService.instance
          .parseTransactionMessagesFlexible([smsMap]);
      parsed.removeWhere((d) =>
          d['amount'] == 'Unknown' ||
          d['lastFourDigits'] == "Unkown" ||
          d['hasBalanceSms'] == "true");
      if (parsed.isNotEmpty) {
        storage.saveTransactionData([Map.from(parsed.first)]);
      }
    }
  } catch (e) {
    print('ERRROR $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );
  await SmsParserService.loadSenders();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalStorageService.init();
  await configureDependencies();

  runApp(
    const DhanraApp(),
  );
}
