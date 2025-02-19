class MediaResponse {
  final String url;
  final String publicId;
  final String format;
  final int width;
  final int height;
  final String resourceType;
  final int bytes;

  MediaResponse({
    required this.url,
    required this.publicId,
    required this.format,
    required this.width,
    required this.height,
    required this.resourceType,
    required this.bytes,
  });

  factory MediaResponse.fromCloudinary(Map<String, dynamic> map) {
    return MediaResponse(
      url: map['secure_url'] ?? '',
      publicId: map['public_id'] ?? '',
      format: map['format'] ?? '',
      width: map['width'] ?? 0,
      height: map['height'] ?? 0,
      resourceType: map['resource_type'] ?? '',
      bytes: map['bytes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'publicId': publicId,
      'format': format,
      'width': width,
      'height': height,
      'resourceType': resourceType,
      'bytes': bytes,
    };
  }
}
