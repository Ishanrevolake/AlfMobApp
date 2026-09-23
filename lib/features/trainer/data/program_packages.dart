class ManagedPackage {
  final Map<String, dynamic> record;
  final int clientCount;
  const ManagedPackage(this.record, {this.clientCount = 0});

  String get id => record['id'] as String;
  String get name => record['title'] as String? ?? '';
  String get duration => record['subtitle'] as String? ?? '';
  String get category => record['category'] as String? ?? 'Bundles';
  String get description => record['detail_subtitle'] as String? ?? '';
  int get price => (record['price_lkr'] as num?)?.toInt() ?? 0;
  bool get active => record['is_active'] != false;
}

class PackageOperationException implements Exception {
  final String message;
  const PackageOperationException(this.message);
  @override
  String toString() => message;
}

const assignedPackageMessage =
    'This package is assigned to clients and cannot be deleted. You can edit it instead.';
