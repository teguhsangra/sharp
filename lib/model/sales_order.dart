import 'package:telkom/model/primary_product.dart';
import 'package:telkom/model/product.dart';
import 'package:telkom/model/customer.dart';
import 'package:telkom/model/location.dart';
import 'package:telkom/model/sales_order_detail.dart';
import 'package:telkom/model/tenant.dart';

class SalesOrder {
  late int id;
  late int? locationId, customerId, employeeId, primaryProductId,totalPrice,totalDiscount,totalTax,totalServiceCharge;
  late String code, name, status;
  late String? remarks, evidence1, evidence2, timeZone;
  late PrimaryProduct? product;
  late Location? location;
  late Customer? customer;
  // late Tenant? tenant;
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
    totalDiscount = json['total_discount'];
    totalServiceCharge = json['total_service_charge'];
    totalTax = json['total_tax'];
    createdAt = DateTime.parse(json['created_at']);
    startedAt = DateTime.parse(json['started_at']);
    endedAt = DateTime.parse(json['ended_at']);
    timeZone = json['timezone'];
    product = (json['primary_product'] != []
        ? PrimaryProduct.fromJson(json['primary_product'])
        : []) as PrimaryProduct?;
    customer = (json['customer'] != []
        ? Customer.fromJson(json['customer'])
        : []) as Customer?;
    // tenant =  (
    //     json['tenant'] != null
    //     ? Tenant.fromJson(json['tenant'])
    //     : []
    // ) as Tenant?;
    location = (json['location'] != []
        ? Location.fromJson(json['location'])
        : []) as Location?;
    if (json['sales_order_details'] != []) {
      salesOrderDetail = List<SalesOrderDetail>.from(
          json["sales_order_details"]
              .map((detailData) => SalesOrderDetail.fromJson(detailData)));
      ;
    }
  }
}
