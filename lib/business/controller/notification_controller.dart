import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

class NotitificationController extends GetxController {
  final notifications = [].obs;
  final isLoading = false.obs;
  final user = FirebaseAuth.instance.currentUser;
  final temps = "".obs;

  @override
  void onInit() {
    super.onInit();
    getNotifications();
  }

  getNotifications() {
    isLoading(true);
    FirebaseFirestore.instance
        .collection("usersNotifications")
        .orderBy("createdAt", descending: true)
        .where("userId", isEqualTo: user!.uid)
        .snapshots()
        .listen((events) {
      notifications.value = [];
      for (var event in events.docs) {
        final data = event.data();
        notifications.add(data);
      }
    });
    isLoading(false);
  }

  getTimeAtDate(DateTime date) {
    var now = DateTime.now();
    var diff = now.difference(date);
    var minute = date.minute.toString();
    var minLe = minute.toString().length;
    minLe == 1 ? minute = "0$minute" : minute;
    var heure = date.hour.toString();
    var heureLength = heure.toString().length;
    heureLength == 1 ? heure = "0$heure" : heure;
    var jour = date.day.toString();
    var jourLength = jour.toString().length;
    jourLength == 1 ? jour = "0$jour" : jour;
    var mois = date.month.toString();
    var moisLength = mois.toString().length;
    moisLength == 1 ? mois = "0$mois" : mois;
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final aDate = DateTime(date.year, date.month, date.day);

    if (aDate.compareTo(today) == 0) {
      if (diff.inSeconds < 60) {
        temps.value = "A l'instant";
      } else if (diff.inMinutes < 60) {
        temps.value = "Il y a ${diff.inMinutes} mn";
      } else {
        temps.value = "Aujord'hui à $heure:$minute";
      }
    } else if (aDate.compareTo(yesterday) == 0) {
      if (diff.inHours < 24) {
        temps.value = "hier à $heure:$minute";
      } else {
        temps.value = "$jour.$mois.${date.year}";
      }
    } else {
      temps.value = "$jour.$mois.${date.year}";
    }
  }

  updateNotificationsStatus(String notificationId) {
    FirebaseFirestore.instance
        .collection("usersNotifications")
        .doc(notificationId)
        .update({"opened": true}).then(
      (value) => print("notification lue"),
    );
  }
}
