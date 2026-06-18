import 'package:image_picker/image_picker.dart';

import '../pedigree_document_model.dart';

abstract class PedigreesRemoteDataSource {
  Future<List<PedigreeDocumentModel>> listDocuments({int? birdId});
  Future<PedigreeDocumentModel> uploadDocument(XFile file, {int? birdId});
  Future<PedigreeDocumentModel> getDocument(int id);
  Future<PedigreeDocumentModel> reviewDocument(
    int id, {
    required String ringNumber,
    required String description,
  });
}
