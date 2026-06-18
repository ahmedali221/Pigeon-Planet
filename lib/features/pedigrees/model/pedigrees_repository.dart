import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/error/failures.dart';
import 'pedigree_document_model.dart';

abstract class PedigreesRepository {
  Future<Either<Failure, List<PedigreeDocumentModel>>> listDocuments({int? birdId});

  Future<Either<Failure, PedigreeDocumentModel>> uploadDocument(
    XFile file, {
    int? birdId,
  });

  Future<Either<Failure, PedigreeDocumentModel>> getDocument(int id);

  Future<Either<Failure, PedigreeDocumentModel>> reviewDocument(
    int id, {
    required String ringNumber,
    required String description,
  });
}
