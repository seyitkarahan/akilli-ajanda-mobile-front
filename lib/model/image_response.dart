
class ImageResponse {
  final int id;
  final String fileName;
  final String fileType;
  final String filePath;

  ImageResponse({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.filePath,
  });

  factory ImageResponse.fromJson(Map<String, dynamic> json) {
    return ImageResponse(
      id: json['id'],
      fileName: json['fileName'],
      fileType: json['fileType'],
      filePath: json['filePath'],
    );
  }
}
