import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/vat_tax/domain/models/tax_vat_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/vat_tax/domain/models/vat_tax_type_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/vat_tax/domain/service/vat_tax_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';


class VatTaxController extends ChangeNotifier {
  final VatTaxServiceInterface vatTaxServiceInterface;

  VatTaxController({required this.vatTaxServiceInterface});

  List<VatTaxModel>  _taxVatList = [];
  List<VatTaxModel> get taxVatList => _taxVatList;

  List<VatTaxModel>  _selectedTaxList = [];
  List<VatTaxModel> get selectedTaxList => _selectedTaxList;


  Future<void> getVatTaxList() async {
    _taxVatList = [];

    ApiResponseModel response = await vatTaxServiceInterface.getVatTaxList();
    if (response.response != null && response.response!.statusCode == 200) {
      response.response?.data.forEach((vatTax) {
        _taxVatList.add(VatTaxModel.fromJson(vatTax));
      });
      if (_taxVatList.isNotEmpty) {
        _taxVatList.insert(0, VatTaxModel(id: 0, name: "All"));
      }
    } else {
      ApiChecker.checkApi(response);
    }
    notifyListeners();
  }

  void clearSelectedTaxList() {
    _selectedTaxList = [];
    notifyListeners();
  }

  void addToSelectedTaxList(VatTaxModel taxVatModel){
    _selectedTaxList.add(taxVatModel);
    notifyListeners();
  }

  void removeToSelectedTaxList(VatTaxModel taxVatModel, int index){
    _selectedTaxList.removeAt(index);
    notifyListeners();
  }

  bool isSelected (VatTaxModel taxVatModel) {
    for(VatTaxModel tvModel in _selectedTaxList){
      if(taxVatModel.id == tvModel.id) {
        return true;
      }
    }
    return false;
  }


  void setProductVatTax(List<TaxVats>? taxVats) {
    if (taxVats != null && taxVats.isNotEmpty) {
      for (TaxVats taxVat in taxVats) {
        if (taxVat.tax != null && !checkContains(taxVat.tax)) {
          _selectedTaxList.add(taxVat.tax!);
        }
      }
    }
  }


  void setAIProductVatTax(List<VatTaxModel>? taxVats) {
    if(taxVats != null && taxVats.isNotEmpty) {
      for(VatTaxModel taxVat  in taxVats) {
        if(!checkContains(taxVat)) {
          _selectedTaxList.add(taxVat);
        }
      }
    }
    notifyListeners();
  }

  bool checkContains(VatTaxModel? vatTRax) {
    if(_selectedTaxList.isNotEmpty && vatTRax != null){
      for(VatTaxModel tax in _selectedTaxList) {
        if(tax.id == vatTRax.id) {
          return true;
        }
      }
    }
    return false;
  }
}