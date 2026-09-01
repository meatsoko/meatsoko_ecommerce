class AuctionSalesReportModel {
  final int totalAuctionsCreated;
  final int totalAuctionsSold;
  final double totalProductSalesValue;
  final double totalVatTax;
  final double totalShippingFee;
  final double grossSalesAmount;
  final SalesTrendModel salesTrend;

  AuctionSalesReportModel({
    required this.totalAuctionsCreated,
    required this.totalAuctionsSold,
    required this.totalProductSalesValue,
    required this.totalVatTax,
    required this.totalShippingFee,
    required this.grossSalesAmount,
    required this.salesTrend,
  });

  factory AuctionSalesReportModel.fromJson(Map<String, dynamic> json) {
    return AuctionSalesReportModel(
      totalAuctionsCreated: json['total_auctions_created'] ?? 0,
      totalAuctionsSold: json['total_auctions_sold'] ?? 0,
      totalProductSalesValue: json['total_product_sales_value'] != null ? double.parse(json['total_product_sales_value'].toString()) : 0,
      totalVatTax: json['total_vat_tax'] != null ? double.parse(json['total_vat_tax'].toString()) : 0,
      totalShippingFee: json['total_shipping_fee'] != null ? double.parse(json['total_shipping_fee'].toString()) : 0,
      grossSalesAmount: json['gross_sales_amount'] != null ? double.parse(json['gross_sales_amount'].toString()) : 0,
      salesTrend: SalesTrendModel.fromJson(json['sales_trend'] ?? {}),
    );
  }
}

class SalesTrendModel {
  final List<String> labels;
  final List<double> data;

  SalesTrendModel({required this.labels, required this.data});

  factory SalesTrendModel.fromJson(Map<String, dynamic> json) {
    return SalesTrendModel(
      labels: List<String>.from(json['labels'] ?? []),
      data: List<double>.from((json['data'] ?? []).map((e) => double.tryParse(e.toString()) ?? 0)),
    );
  }
}
