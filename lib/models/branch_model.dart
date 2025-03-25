import 'package:kijani_pmc_app/models/parish_model.dart';

class BranchModel {
  final String id;
  final String name;
  final List<ParishModel> parishes;

  BranchModel({
    required this.id,
    required this.name,
    required this.parishes,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'],
      name: json['name'],
      parishes: List<ParishModel>.from(
        json['parishes'].map(
          (parish) => ParishModel.fromJson(parish),
        ),
      ),
    );
  }
}
