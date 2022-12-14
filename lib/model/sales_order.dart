import 'package:telkom/model/product.dart';
import 'package:telkom/model/customer.dart';
import 'package:telkom/model/location.dart';
import 'package:telkom/model/sales_order_detail.dart';

class SalesOrder {
  late int id;
  late int? locationId, customerId, employeeId, primaryProductId,totalPrice;
  late String code, name, status;
  late String? remarks, evidence1, evidence2, timeZone;
  late Product? product;
  late Location? location;
  late Customer? customer;
  late List<SalesOrderDetail> salesOrderDetail;
  late DateTime? startedAt,endedAt,createdAt;
  // late String? followUpBy, followUpNotes, followUpPicture;

  SalesOrder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    locationId = json['location_id'];
    customerId = json['customer_id'];
    employeeId = json['employee_id'];
    primaryProductId = json['primary_product_id'];
    code = json['code'];
    name = json['name'] != null ? json['name'] : '' ;
    remarks = json['remarks'];
    evidence1 = json['evidence_1'];
    evidence2 = json['evidence_2'];
    status = json['status'];
    totalPrice = json['total_price'];
    createdAt = DateTime.parse(json['created_at']);
    startedAt = DateTime.parse(json['started_at']);
    endedAt = DateTime.parse(json['ended_at']);
    timeZone = json['timezone'];
    product = (json['primary_product'] != []
        ? Product.fromJson(json['primary_product'])
        : []) as Product?;
    customer = (json['customer'] != []
        ? Customer.fromJson(json['customer'])
        : []) as Customer?;
    location = (json['location'] != []
        ? Location.fromJson(json['location'])
        : []) as Location?;
    if (json['sales_order_details'] != null) {
      salesOrderDetail = List<SalesOrderDetail>.from(
          json["sales_order_details"]
              .map((detailData) => SalesOrderDetail.fromJson(detailData)));
      ;
    }
  }
}
