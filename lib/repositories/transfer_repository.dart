import '../services/api_client.dart';

class TransferRepository {
  final ApiClient apiClient;

  TransferRepository(this.apiClient);

  Future<void> submitTransferReservation({
    required String name,
    required String email,
    required String phone,
    required int numberPerson,
    required String date,
    required String hour,
    required String adresseDepart,
    required String adresseArrive,
  }) async {
    await apiClient.post(
      '/utilisateur/transfers',
      body: {
        "name": name,
        "email": email,
        "phone": phone,
        "number_person": numberPerson,
        "date": date,
        "hour": hour,
        "adresse_depart": adresseDepart,
        "adresse_arrive": adresseArrive,
      },
    );
  }
}
