import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<String> generateOrderPDFFromFirestore(String orderId) async {
  try {
    final orderDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('orders')
            .doc(orderId)
            .get();
    if (!orderDoc.exists) {
      throw Exception('Order not found');
    }

    final orderData = orderDoc.data()!;
    final items = List<Map<String, dynamic>>.from(orderData['items']);
    final String status = orderData['status'];
    final double total = orderData['total'];
    final Timestamp? date = orderData['date'];
    final String formattedDate =
        date != null
            ? DateTime.fromMillisecondsSinceEpoch(
              date.millisecondsSinceEpoch,
            ).toString()
            : 'Unknown Date';
    final ByteData logoData = await rootBundle.load(
      'assets/images/app_icon.png',
    );
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final image = pw.MemoryImage(logoBytes);
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Center(child: pw.Image(image, width: 100, height: 100)),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'Fresh Basket',
                style: pw.TextStyle(
                  fontSize: 30,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF328E6E),
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Grocery Order Summary',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Order ID: $orderId', style: pw.TextStyle(fontSize: 16)),
            pw.Text('Status: $status', style: pw.TextStyle(fontSize: 16)),
            pw.Text('Date: $formattedDate', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FractionColumnWidth(0.4), // Name
                1: pw.FractionColumnWidth(0.15), // Price
                2: pw.FractionColumnWidth(0.15), // Quantity
                3: pw.FractionColumnWidth(0.15), // Total
                4: pw.FractionColumnWidth(0.15), // Product ID
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Item',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Price',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Quantity',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Total',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Product ID',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                // Table Rows
                ...items.map(
                  (item) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(item['name']?.toString() ?? ''),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '\$${item['price']?.toStringAsFixed(2) ?? '0.00'}',
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(item['quantity']?.toString() ?? '0'),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '\$${(item['price'] != null && item['quantity'] != null ? item['price'] * item['quantity'] : 0.0).toStringAsFixed(2)}',
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(item['productId']?.toString() ?? ''),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ];
        },
      ),
    );
    Directory? dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download/Fresh Basket');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final file = File('${dir.path}/order_$orderId.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  } catch (e) {
    throw Exception('Error generating PDF: $e');
  }
}
