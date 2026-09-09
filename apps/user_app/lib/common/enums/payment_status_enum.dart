enum PaymentStatus {
  paid('paid'),
  unpaid('unpaid'),
  pending('pending');

  final String label;

  const PaymentStatus(this.label);

  static PaymentStatus? fromString(String? value) {
    if (value == null || value.isEmpty) return null;

    return PaymentStatus.values.firstWhere((e) =>
      e.label.toLowerCase() == value.toLowerCase() ||
          e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => PaymentStatus.unpaid,
    );
  }

  String toJson() => label;

  bool get isPaid => this == PaymentStatus.paid;

  bool get isUnpaid => this == PaymentStatus.unpaid;

  bool get isPending => this == PaymentStatus.pending;
}
