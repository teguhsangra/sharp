// To parse this JSON data, do
//
//     final tenant = tenantFromJson(jsonString);

import 'dart:convert';

Tenant tenantFromJson(String str) => Tenant.fromJson(json.decode(str));

String tenantToJson(Tenant data) => json.encode(data.toJson());

class Tenant {
  Tenant({
    this.data,
  });

  Data? data;

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
        data: Data.fromJson(json["data"]),
      );

  factory Tenant.fromJsonTenant(Map<String, dynamic> json) => Tenant(
        data: Data.fromJson(json),
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
      };
}

class Data {
  Data({
    this.id,
    this.code,
    this.name,
    this.phone,
    this.email,
    this.headOfficeAddress,
    this.defaultCurrency,
    this.signatoryName,
    this.signatoryTitle,
    this.halfDayLength,
    this.hasServiceCharge,
    this.taxPercentage,
    this.serviceChargePercentage,
    this.depreciationPercentage,
    this.otpExpiredInMinutes,
    this.latlongToleranceDistanceInMeter,
    this.usingTelkomTeritorry,
    this.loginPage,
    this.appsName,
    this.logoPath,
    this.fileNameOfSalesOrderPrint,
    this.fileNameOfDomicilePrint,
    this.fileNameOfTermAndConditionPrint,
    this.fileNameOfProfitAndLossPrint,
    this.fileNameOfInvoicePrint,
    this.fileNameOfPaymentPrint,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  int? id;
  String? code;
  String? name;
  String? phone;
  String? email;
  String? headOfficeAddress;
  String? defaultCurrency;
  dynamic signatoryName;
  dynamic signatoryTitle;
  int? halfDayLength;
  int? hasServiceCharge;
  int? taxPercentage;
  int? serviceChargePercentage;
  int? depreciationPercentage;
  int? otpExpiredInMinutes;
  int? latlongToleranceDistanceInMeter;
  int? usingTelkomTeritorry;
  String? loginPage;
  String? appsName;
  String? logoPath;
  dynamic fileNameOfSalesOrderPrint;
  dynamic fileNameOfDomicilePrint;
  dynamic fileNameOfTermAndConditionPrint;
  dynamic fileNameOfProfitAndLossPrint;
  dynamic fileNameOfInvoicePrint;
  dynamic fileNameOfPaymentPrint;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic deletedAt;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        code: json["code"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        headOfficeAddress: json["head_office_address"],
        defaultCurrency: json["default_currency"],
        signatoryName: json["signatory_name"],
        signatoryTitle: json["signatory_title"],
        halfDayLength: json["half_day_length"],
        hasServiceCharge: json["has_service_charge"],
        taxPercentage: json["tax_percentage"],
        serviceChargePercentage: json["service_charge_percentage"],
        depreciationPercentage: json["depreciation_percentage"],
        otpExpiredInMinutes: json["otp_expired_in_minutes"],
        latlongToleranceDistanceInMeter:
            json["latlong_tolerance_distance_in_meter"],
        usingTelkomTeritorry: json["using_telkom_teritorry"],
        loginPage: json["login_page"],
        appsName: json["apps_name"],
        logoPath: json["logo_path"],
        fileNameOfSalesOrderPrint: json["file_name_of_sales_order_print"],
        fileNameOfDomicilePrint: json["file_name_of_domicile_print"],
        fileNameOfTermAndConditionPrint:
            json["file_name_of_term_and_condition_print"],
        fileNameOfProfitAndLossPrint:
            json["file_name_of_profit_and_loss_print"],
        fileNameOfInvoicePrint: json["file_name_of_invoice_print"],
        fileNameOfPaymentPrint: json["file_name_of_payment_print"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "name": name,
        "phone": phone,
        "email": email,
        "head_office_address": headOfficeAddress,
        "default_currency": defaultCurrency,
        "signatory_name": signatoryName,
        "signatory_title": signatoryTitle,
        "half_day_length": halfDayLength,
        "has_service_charge": hasServiceCharge,
        "tax_percentage": taxPercentage,
        "service_charge_percentage": serviceChargePercentage,
        "depreciation_percentage": depreciationPercentage,
        "otp_expired_in_minutes": otpExpiredInMinutes,
        "latlong_tolerance_distance_in_meter": latlongToleranceDistanceInMeter,
        "using_telkom_teritorry": usingTelkomTeritorry,
        "login_page": loginPage,
        "apps_name": appsName,
        "logo_path": logoPath,
        "file_name_of_sales_order_print": fileNameOfSalesOrderPrint,
        "file_name_of_domicile_print": fileNameOfDomicilePrint,
        "file_name_of_term_and_condition_print":
            fileNameOfTermAndConditionPrint,
        "file_name_of_profit_and_loss_print": fileNameOfProfitAndLossPrint,
        "file_name_of_invoice_print": fileNameOfInvoicePrint,
        "file_name_of_payment_print": fileNameOfPaymentPrint,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
      };
}
