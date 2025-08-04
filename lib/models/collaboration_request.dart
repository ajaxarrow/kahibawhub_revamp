class CollaborationRequest {
  final String collabRequestId;
  final String materialId;
  final String? materialTitle;
  final String requestedBy;
  final String requestedByName;
  final String userAction;

  CollaborationRequest({
    required this.collabRequestId,
    required this.materialId,
    this.materialTitle,
    required this.requestedBy,
    required this.requestedByName,
    required this.userAction,
  });

  factory CollaborationRequest.fromMap(Map<String, dynamic> map) {
    return CollaborationRequest(
      collabRequestId: map['collabRequestId'] ?? '',
      materialId: map['materialId'] ?? '',
      materialTitle: map['materialTitle'],
      requestedBy: map['requestedBy'] ?? '',
      requestedByName: map['requestedByName'] ?? '',
      userAction: map['userAction'] ?? '',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'collabRequestId': collabRequestId,
      'materialId': materialId,
      'materialTitle': materialTitle,
      'requestedBy': requestedBy,
      'requestedByName': requestedByName,
      'userAction': userAction,
    };
  }

  @override
  String toString() {
    return 'CollaborationRequest(collabRequestId: $collabRequestId, materialId: $materialId, materialTitle: $materialTitle, requestedBy: $requestedBy, requestedByName: $requestedByName, userAction: $userAction)';
  }
}