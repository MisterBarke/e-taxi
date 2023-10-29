import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HistoriquesIncidentsController extends GetxController {
  final user = FirebaseAuth.instance.currentUser;
  final incidents = [].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getIncidents();
  }

  getIncidents() {
    isLoading(true);
    FirebaseFirestore.instance
        .collection("incidents")
        .orderBy("createdAt", descending: false)
        .where("userId", isEqualTo: user!.uid)
        .snapshots()
        .listen((querySnapshot) {
      incidents.value = [];
      for (var docSnapshot in querySnapshot.docs) {
        final data = docSnapshot.data();
        incidents.add(data);
      }
      isLoading(false);
    });
  }
}
