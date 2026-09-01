class WithdrawMethodModel {
  final int id;
  final String methodName;
  final List<MethodField> methodFields;
  final bool isDefault;
  final bool isActive;

  WithdrawMethodModel({
    required this.id,
    required this.methodName,
    required this.methodFields,
    required this.isDefault,
    required this.isActive,
  });

  factory WithdrawMethodModel.fromJson(Map<String, dynamic> json) {
    return WithdrawMethodModel(
      id: json['id'],
      methodName: json['method_name'] ?? '',
      methodFields: (json['method_fields'] as List<dynamic>?)
          ?.map((e) => MethodField.fromJson(e))
          .toList() ??
          [],
      isDefault: json['is_default'] ?? false,
      isActive: json['is_active'] ?? false,
    );
  }
}

class MethodField {
  final String inputType;
  final String inputName;
  final String placeholder;
  final bool isRequired;

  MethodField({
    required this.inputType,
    required this.inputName,
    required this.placeholder,
    required this.isRequired,
  });

  factory MethodField.fromJson(Map<String, dynamic> json) {
    return MethodField(
      inputType: json['input_type'] ?? '',
      inputName: json['input_name'] ?? '',
      placeholder: json['placeholder'] ?? '',
      isRequired: (json['is_required'] ?? 0) == 1,
    );
  }
}