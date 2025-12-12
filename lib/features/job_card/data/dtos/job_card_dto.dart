class JobCardDto {
  final String id;
  final String companyName;
  final String jobTitle;
  final String status;
  final String? notes;
  final String? appliedDate; // ISO String

  JobCardDto({required this.id, required this.companyName, required this.jobTitle, required this.status, this.notes, this.appliedDate});

  factory JobCardDto.fromJson(Map<String, dynamic> json) => JobCardDto(
        id: json['id']?.toString() ?? '',
        companyName: json['companyName']?.toString() ?? '',
        jobTitle: json['jobTitle']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        notes: json['notes'] as String?,
        appliedDate: json['appliedDate'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyName': companyName,
        'jobTitle': jobTitle,
        'status': status,
        'notes': notes,
        'appliedDate': appliedDate,
      };
}
