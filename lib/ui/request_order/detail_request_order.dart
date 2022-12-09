import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telkom/components/helper.dart';
import 'package:telkom/model/request_order.dart';
import 'package:telkom/network/api.dart';
import 'package:telkom/ui/auth/notification/NotificationScreen.dart';

class RequestOrderDetailScreen extends StatefulWidget {
  final int requestOrderId;

  const RequestOrderDetailScreen({Key? key, required this.requestOrderId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => RequestOrderDetailState();
}

class RequestOrderDetailState extends State<RequestOrderDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  var user = {};
  bool isLoading = true;
  bool isFollowUp = false;
  late RequestOrder requestOrder;

  String? follow_up_by;
  String? follow_up_notes;
  var follow_up_picture;
  var picture;

  @override
  void initState() {
    super.initState();
    loadUserData();
    getDetail(widget.requestOrderId);
  }

  loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    var userSession = jsonDecode(localStorage.getString('user').toString());

    setState(() {
      user = userSession;
    });
  }

  void getDetail(int requestOrderId) async {
    try {
      isLoading = true;
      var res = await Network().getData('request_orders/$requestOrderId');
      if (res.statusCode == 200) {
        var resultData = jsonDecode(res.body);

        setState(() {
          requestOrder = RequestOrder.fromJson(resultData['data']);
        });
      }
    } finally {
      isLoading = false;
    }
  }

  final _controller = TextEditingController();
  String? get _errorText {
    // at any time, we can get the text from _controller.value.text
    final text = _controller.value.text;
    // Note: you can do your own custom validation here
    // Move this logic this outside the widget for more testable code
    if (text.isEmpty) {
      return 'Catatan tidak boleh kosong';
    }

    // return null if the text is valid
    return null;
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void bottomSheet() async{
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, StateSetter setState) {
                return Container(
                  width: size.width,
                  height: size.height * 0.3,
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 50.0,
                            height: 5.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0)),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Text('Gambar',
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        const SizedBox(height: 20.0),
                        GestureDetector(
                          onTap: () async {
                            getFromCamera();
                            Navigator.pop(
                                context);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.photo_camera,
                                color: Color(0XFFFA4A0C),
                                size: 28,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                'Ambil dari kamera',
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 15,),
                        GestureDetector(
                          onTap: () async {
                            getFromGallery();
                            Navigator.pop(
                                context);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.image,
                                color: Color(0XFFFA4A0C),
                                size: 28,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                'Ambil dari galeri',
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
  }

  void getFromCamera() async{
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      var file_image = File(pickedFile.path);
      // Get mime type
      final _image = await file_image.readAsBytes();
      final mime = lookupMimeType('', headerBytes: _image);
      // convert to base64
      Uint8List? imagebytes = await file_image.readAsBytes();
      String base64string = base64.encode(imagebytes!);

      setState(() {
        picture = file_image;
        follow_up_picture = "data:" + mime.toString() + ";base64," + base64string;
      });
    }
  }

  void getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      var file_image = File(pickedFile.path);
      // Get mime type
      final _image = await file_image.readAsBytes();
      final mime = lookupMimeType('', headerBytes: _image);
      // convert to base64
      Uint8List? imagebytes = await file_image.readAsBytes();
      String base64string = base64.encode(imagebytes!);

      setState(() {
        picture = file_image;
        follow_up_picture = "data:" + mime.toString() + ";base64," + base64string;
      });
    }
  }

  void _submit() async{
    var requestOrderDetail = [];
    for(var item  in requestOrder.requestOrderDetails)
      {
        requestOrderDetail.add(
          {
            'product_id': item.productId,
            'name': item.name,
            'quantity': item.quantity,
            'price': item.price
          }
        );
      }


    var data = {
      "tenant_id": user['tenant_id'],
      "status": requestOrder.status,
      "code": requestOrder.code,
      "name": requestOrder.name,
      "employee_id": requestOrder.employeeId,
      "customer_id": requestOrder.customerId,
      "room_id": requestOrder.roomId,
      "total_price": requestOrder.totalPrice,
      "remarks": requestOrder.remarks,
      "evidence_1": requestOrder.evidence1,
      "evidence_2": requestOrder.evidence2,
      "timezone": requestOrder.timeZone,
      "request_order_detail": jsonEncode(requestOrderDetail),
      "follow_up_at" : formatDate("yyyy-MM-dd HH:mm:ss", DateTime.now()),
      "follow_up_by" : user['name'],
      "follow_up_notes":_controller.value.text,
      "follow_up_picture":follow_up_picture
    };



    var res = await Network().putRequestOrder('request_orders/${requestOrder.id}', data);
    var body = json.decode(res.body);
    if(res.statusCode == 201 || res.statusCode == 200)
    {
      getDetail(requestOrder.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: const Text('Sukses tambahkan pesanan Permintaan'),
          action: SnackBarAction(
            textColor: Colors.white,
            label: 'x',
            onPressed: () {
              // Code to execute.
            },
          ),
          duration: Duration(seconds: 3),
          shape: StadiumBorder(),
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          behavior: SnackBarBehavior.floating,
          elevation: 0,
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFA4A0C),
        title: const Text("Request Order Detail"),
        actions: [
          Container(
            margin: const EdgeInsets.all(10),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationScreen()),
                );
              },
              icon: const Icon(Icons.notifications, color: Colors.white),
            ),
          ),
          CircleAvatar(
            radius: 15,
            backgroundColor: const Color(0xffD9D9D9),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: ClipOval(
                child: Image.asset(
                  "assets/images/hero_profile.png",
                  height: 40.0,
                  width: 40.0,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 2,
                            // Shadow position
                            spreadRadius: 3,
                            offset: const Offset(0, 2)),
                      ]),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          requestOrder.customer!.name,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 30,),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          requestOrder.room!.name,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 15,),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Nama Order : '+  requestOrder.name,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      SizedBox(height: 5,),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Tanggal order: '+formatDate('yyyy-MM-dd HH:mm', requestOrder.createdAt),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        width: 350,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                    8),
                              ),
                              elevation: 0,
                              color:
                              requestOrder.status == 'reject'?
                              Color(0xFFFFEBEB)
                                  : requestOrder.status == 'approve' ? Color(0xFF50C594)
                                  : Color(0XFFFFF5E8)
                              ,
                              child: SizedBox(
                                  width: size.width / 5,
                                  height: 35,
                                  child: Center(child: Text(requestOrder.status,
                                    style: TextStyle(
                                        color: requestOrder.status == 'reject'?
                                        Color(0xFFCB4C4D)
                                            : requestOrder.status == 'approve' ? Colors.white
                                            : Color(0XFFEA9B3F),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14
                                    ),
                                  ))
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5,),
                      Divider(color: Color(0XFFECECEC),height: 2,)

                    ],
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 2,
                            // Shadow position
                            spreadRadius: 3,
                            offset: const Offset(0, 2)),
                      ]),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Order Details',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 15,),
                      Divider(color: Colors.black,),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: requestOrder.requestOrderDetails.length,
                        itemBuilder: (context, index) {
                          var item = requestOrder.requestOrderDetails[index];
                          return Column(
                            children: [
                                Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                          item.name,
                                        style: TextStyle(
                                              fontWeight: FontWeight.normal
                                        ),
                                      ),
                                      SizedBox(height: 5,),
                                      Text(item.quantity.toString()+'x'),
                                    ],
                                  ),
                                  Text(
                                    '${currencyFormat(int.parse(item.price.toString()))}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                                SizedBox(height: 5,),
                                Divider(color: Colors.black,)
                            ],
                          );
                        }
                      ),
                      SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Total price',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black)),
                          ),
                          Text('${currencyFormat(int.parse(requestOrder.totalPrice.toString()))}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black))
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                if(requestOrder.evidence1 != null || requestOrder.evidence2 != null)
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 2,
                            // Shadow position
                            spreadRadius: 3,
                            offset: const Offset(0, 2)),
                      ]),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text('Gambar',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          (requestOrder.evidence1 != null ?
                          FullScreenWidget(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                baseUrl + requestOrder.evidence1.toString(),
                                width: 80,
                                height: 80,
                              ),
                            ),
                          )
                              :
                          new Container()

                          ),

                          (requestOrder.evidence2 != null ?
                          FullScreenWidget(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                baseUrl + requestOrder.evidence2.toString(),
                                width: 80,
                                height: 80,
                              ),
                            ),
                          )
                              : new Container()
                          )
                          ,
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                if(requestOrder.status == 'approve')
                  (requestOrder.followUpAt == '' ?
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 2,
                                  // Shadow position
                                  spreadRadius: 3,
                                  offset: const Offset(0, 2)),
                            ]),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text('Follow up',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            SizedBox(height: 20,),
                            Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('Catatan',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black)),
                                    ),
                                    SizedBox(height: 15,),
                                    TextField(
                                      controller: _controller,
                                      decoration: InputDecoration(
                                        // use the getter variable defined above
                                        errorText: _errorText,
                                      ),
                                      onChanged: (value) {
                                        // print(value);
                                        setState(() {
                                          follow_up_notes = value;
                                        });
                                      },

                                    ),
                                    SizedBox(height: 20,),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('Gambar',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black)),
                                    ),
                                    SizedBox(height: 15,),
                                    (picture != null ?

                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        FullScreenWidget(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: Image.file(
                                              picture,
                                              width: 100,
                                              height: 100,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {

                                              },
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(12.0),
                                                ),
                                                elevation: 0,
                                                color: Color(0xFFFA4A0C),
                                                child: const SizedBox(
                                                  width: 100,
                                                  height: 40,
                                                  child: Center(
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: <InlineSpan>[
                                                          WidgetSpan(
                                                            alignment:
                                                            PlaceholderAlignment
                                                                .middle,
                                                            child: Icon(
                                                              Icons.camera,
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                              text: ' foto ulang',
                                                              style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 12)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 20,),
                                            GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  picture = null;
                                                });
                                              },
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(12.0),
                                                ),
                                                elevation: 0,
                                                color: Color(0xFFFA4A0C),
                                                child: const SizedBox(
                                                  width: 100,
                                                  height: 40,
                                                  child: Center(
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: <InlineSpan>[
                                                          WidgetSpan(
                                                            alignment:
                                                            PlaceholderAlignment
                                                                .middle,
                                                            child: Icon(
                                                              Icons.delete,
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                              text: ' Hapus foto ',
                                                              style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 12)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )

                                      ],
                                    )
                                        :
                                    GestureDetector(
                                      onTap: () {
                                        bottomSheet();
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                            height: 50,
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE6ECF6),
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: Icon(
                                              Icons.photo_camera,
                                              color: Color(0XFFFA4A0C),
                                              size: 28,
                                            ),
                                          ),
                                          Text('Take a picture',
                                              style: TextStyle(
                                                fontSize: 14,
                                              ))
                                        ],
                                      ),
                                    )
                                    ),

                                  ],
                                )
                            ),
                            SizedBox(height: 20,),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              height: 50,
                              width: size.width * 0.9,
                              decoration: BoxDecoration(
                                  color: Color(0xFFFA4A0C),
                                  borderRadius: BorderRadius.circular(20)),
                              child: TextButton(
                                onPressed: _controller.value.text.isNotEmpty
                                    ? _submit
                                    : null,
                                child: const Text(
                                  'Kirim',
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                      :
                      new Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 2,
                                  // Shadow position
                                  spreadRadius: 3,
                                  offset: const Offset(0, 2)),
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text('Follow up',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                Text(
                                  formatDate('yyyy-MM-dd HH:mm', requestOrder.createdAt),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                            SizedBox(height: 15,),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Di Follow up oleh: '+  requestOrder.followUpBy.toString(),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 20,),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Catatan:',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Container(
                              child: Text(
                                requestOrder.followUpNotes.toString()
                              ),
                            ),
                            SizedBox(height: 15,),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Gambar:',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 15,),
                            FullScreenWidget(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  baseUrl+requestOrder.followUpPicture.toString(),
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  )

              ],
            ),
          ),
      )
          
    );
  }


}
