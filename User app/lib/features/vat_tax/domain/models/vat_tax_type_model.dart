import 'package:flutter_sixvalley_ecommerce/features/vat_tax/domain/models/tax_vat_model.dart';

class TaxVats {
  int? id;
  String? taxableType;
  int? taxableId;
  int? taxId;
  int? systemTaxSetupId;
  String? createdAt;
  String? updatedAt;
  VatTaxModel? tax;

  TaxVats(
      {this.id,
        this.taxableType,
        this.taxableId,
        this.taxId,
        this.systemTaxSetupId,
        this.createdAt,
        this.updatedAt,
        this.tax});

  TaxVats.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    taxableType = json['taxable_type'];
    taxableId = json['taxable_id'];
    taxId = json['tax_id'];
    systemTaxSetupId = json['system_tax_setup_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    tax = json['tax'] != null ? VatTaxModel.fromJson(json['tax']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['taxable_type'] = taxableType;
    data['taxable_id'] = taxableId;
    data['tax_id'] = taxId;
    data['system_tax_setup_id'] = systemTaxSetupId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (tax != null) {
      data['tax'] = tax!.toJson();
    }
    return data;
  }
}