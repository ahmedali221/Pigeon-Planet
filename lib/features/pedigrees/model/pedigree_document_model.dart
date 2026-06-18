class PedigreeDocumentModel {
  final int id;
  final String? fileUrl;
  final String status;
  final String? extractedBirdRingNumber;
  final String? extractedDescription;
  final String? reviewedBirdRingNumber;
  final String? reviewedDescription;
  final String? processingError;
  final String? rawOcrText;
  final int? birdId;
  final DateTime? reviewedAt;
  final DateTime? created;

  const PedigreeDocumentModel({
    required this.id,
    this.fileUrl,
    required this.status,
    this.extractedBirdRingNumber,
    this.extractedDescription,
    this.reviewedBirdRingNumber,
    this.reviewedDescription,
    this.processingError,
    this.rawOcrText,
    this.birdId,
    this.reviewedAt,
    this.created,
  });

  factory PedigreeDocumentModel.fromJson(Map<String, dynamic> json) {
    return PedigreeDocumentModel(
      id: json['id'] as int,
      fileUrl: json['file_url'] as String?,
      status: json['status'] as String? ?? 'uploaded',
      extractedBirdRingNumber: json['extracted_bird_ring_number'] as String?,
      extractedDescription: json['extracted_description'] as String?,
      reviewedBirdRingNumber: json['reviewed_bird_ring_number'] as String?,
      reviewedDescription: json['reviewed_description'] as String?,
      processingError: json['processing_error'] as String?,
      rawOcrText: json['raw_ocr_text'] as String?,
      birdId: json['bird_id'] as int?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'] as String)
          : null,
      created: json['created'] != null
          ? DateTime.tryParse(json['created'] as String)
          : null,
    );
  }

  bool get isFailed => status == 'failed';
  bool get isReviewed => status == 'reviewed';
  bool get canReview => status == 'failed' || status == 'processed';

  PedigreeDocumentModel copyWith({
    String? status,
    String? reviewedBirdRingNumber,
    String? reviewedDescription,
  }) {
    return PedigreeDocumentModel(
      id: id,
      fileUrl: fileUrl,
      status: status ?? this.status,
      extractedBirdRingNumber: extractedBirdRingNumber,
      extractedDescription: extractedDescription,
      reviewedBirdRingNumber: reviewedBirdRingNumber ?? this.reviewedBirdRingNumber,
      reviewedDescription: reviewedDescription ?? this.reviewedDescription,
      processingError: processingError,
      rawOcrText: rawOcrText,
      birdId: birdId,
      reviewedAt: reviewedAt,
      created: created,
    );
  }
}
