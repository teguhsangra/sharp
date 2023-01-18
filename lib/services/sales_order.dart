import 'dart:convert';

import 'package:telkom/repositories/repository.dart';

class SalesOrderService{
  late Repository _repository;

  SalesOrderService(){
    _repository = Repository();
  }

  saveSalesorder(data) async {

    var value = {

      "tenant_id": data['tenant_id'],
      "location_id": data['location_id'],
      "customer_id": data['customer_id'],
      "contact_id": null,
      "emergency_contact_id": null,
      "primary_product_id": data['primary_product_id'],
      "code" : data['code'],
      "name":data['name'],
      "is_inquiry" : false, // Harus diisi dengan nilai false
      "has_contract" : false, // Harus diisi dengan nilai true
      "is_renewal" : false, // Harus diisi dengan nilai false
      "status" : "draft",
      "renewal_status" : "on renewal", // Harus diisi dengan nilai on renewal
      "started_at" : data['started_at'], // Isian dari user dan harus diisi
      "ended_at" : data['ended_at'], // Isian dari user dan harus diisi
      "signed_at" : data['signed_at'], // Isian dari user dan harus diisi
      "term" : data['term'], // Harus diisi dan diambil dari konfigurasi product
      "term_of_payment" : data['term_of_payment'], // Harus diisi dengan nilai anually
      "term_notice_period" : 1, // Harus diisi dengan nilai 3
      "tax_percentage" : data['tax_percentage'], // Diambil dari postman login di bagian tenant
      "length_of_term" : data['length_of_term'], // Isian dari user dan harus diisi
      "total_cost" : 0, // Harus diisi dengan nilai 0
      "total_price" : data['total_price'], // Harus diisi dengan nilai sesuai pilihan produk yang di kali dengan length of term dan di kali dengan quantity
      "total_discount" : data['total_discount'], // Harus diisi dengan nilai 0
      "total_tax" : data['total_tax'],
      'drafted_by': data['drafted_by']
    };


   var res =  await _repository.inserData('sales_orders', value);

    for (var content in jsonDecode(data['sales_order_details'])) {


      var details = await _repository.inserData('sales_order_details', {
        'sales_order_id': res,
        'product_id':content['product_id'],
        'customer_complimentary_id': null,
        'complimentary_id': null,
        'asset_type_id': null,
        'asset_id': content['asset_id'],
        'room_id': null,
        'name': content['name'],
        'type': 'charged',
        'has_complimentary':0,
        'has_term': 0,
        'is_repeated_in_term': 0,
        'has_quantity' : 1,
        'term': 'no term',
        'repeated_term': 'no term',
        'started_at': content['started_at'],
        'ended_at': content['ended_at'],
        'length_of_term': 1,
        'quantity': content['quantity'],
        'total_use_of_complimentary':0,
        'cost': 0,
        'price':content['price'],
        'discount': content['discount'],
        'service_charge': content['service_charge'],
        'tax': content['tax'],
      });


    }


    return true;

  }


  countSalesOrder() async{
    return await _repository.countData('sales_orders');
  }

  getDataSalesOrder() async{
    return await _repository.getAllData('sales_orders');
  }

  getSalesOrder() async{
    return await _repository.getDataPending('sales_orders');
  }

  getSalesOrderDetail(Id) async{
    return await _repository.getSalesOrderDetail(Id,'sales_order_details');
  }

  updateSalesOrder(Id,status) async{
    return await _repository.updateData(Id,status,'sales_orders');
  }

}