class TransactionsResponse {
  final List<Transaction> data;
  final Pagination pagination;

  TransactionsResponse({
    required this.data,
    required this.pagination,
  });

  factory TransactionsResponse.fromJson(Map<String, dynamic> json) {
    return TransactionsResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
  };
}

class Transaction {
  final String uuid;
  final String scheme;
  final String? customerReferenceNumber; // Nullable
  final String? pan; // Nullable
  final String amountAuthorized;
  final String transactionType;
  final Currency currency;
  final bool isApproved;
  final bool isReversed;
  final bool isReconciled;
  final String startDate;
  final String startTime;
  final List<Performance> performance;

  Transaction({
    required this.uuid,
    required this.scheme,
    this.customerReferenceNumber,
    this.pan,
    required this.amountAuthorized,
    required this.transactionType,
    required this.currency,
    required this.isApproved,
    required this.isReversed,
    required this.isReconciled,
    required this.startDate,
    required this.startTime,
    required this.performance,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    print('json');
    print(json);
    return Transaction(
      uuid: json['uuid'] as String? ?? 'N/A',
      scheme: json['scheme'] as String? ?? 'Unknown',
      customerReferenceNumber: json['customer_reference_number'] as String?,
      pan: json['pan'] as String?,
      amountAuthorized: json['amountAuthorized']?.toString() ?? '0.00',
      transactionType: json['transactionType'] as String? ?? 'Unknown',
      currency: Currency.fromJson(json['currency'] as Map<String, dynamic>? ?? {}),
      isApproved: json['isApproved'] as bool? ?? false,
      isReversed: json['isReversed'] as bool? ?? false,
      isReconciled: json['isReconciled'] as bool? ?? false,
      startDate: json['startDate'] as String? ?? 'N/A',
      startTime: json['startTime'] as String? ?? 'N/A',
      performance: (json['performance'] as List<dynamic>?)
          ?.map((e) => Performance.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'scheme': scheme,
    'customer_reference_number': customerReferenceNumber,
    'pan': pan,
    'amountAuthorized': amountAuthorized,
    'transactionType': transactionType,
    'currency': currency.toJson(),
    'isApproved': isApproved,
    'isReversed': isReversed,
    'isReconciled': isReconciled,
    'startDate': startDate,
    'startTime': startTime,
    'performance': performance.map((e) => e.toJson()).toList(),
  };
}

class Currency {
  final String arabic;
  final String english;

  Currency({
    required this.arabic,
    required this.english,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      arabic: json['arabic'] as String? ?? '',
      english: json['english'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'arabic': arabic,
    'english': english,
  };
}

class Performance {
  final String type;
  final num timeStamp;  // Ensure it's int

  Performance({
    required this.type,
    required this.timeStamp,
  });

  factory Performance.fromJson(Map<String, dynamic> json) {
    return Performance(
      type: json['type'] as String? ?? '',
      timeStamp: (json['timeStamp'] as num?)?.toInt() ?? 0
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'timeStamp': timeStamp,
  };

}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalData;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalData,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
      totalData: (json['total_data'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'total_pages': totalPages,
    'total_data': totalData,
  };
}
