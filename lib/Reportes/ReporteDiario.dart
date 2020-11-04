import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pistol_tower/Moldelos/MarcationModel.dart';
import 'package:pistol_tower/Moldelos/PerfilModel.dart';
import 'package:pistol_tower/database/servicesLocal.dart';
import 'package:pistolero_tower/Modelos/MarcacionModel.dart';
import 'package:pistolero_tower/Modelos/PerfilMode.dart';
import 'package:pistolero_tower/Servicios%20Locales/serviciosLocales.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pistolero_tower/Notificaciones e Historial/DialogosNotificaciones.dart'
    as dialog;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

class ReporteDiario extends StatefulWidget {
  ReporteDiario({Key key}) : super(key: key);

  @override
  _ReporteDiarioState createState() => _ReporteDiarioState();
}

class _ReporteDiarioState extends State<ReporteDiario> {
  String fechadelTitulo = DateFormat.yMMMd().format(new DateTime.now());
  String fechaActual = DateFormat.yMd().format(new DateTime.now());
  List<MarcationModel> listaMarcaciones = List();
  List<PerfilModel> listaTrabajadores = List();
  int stateView;
  bool prueba = true;
  File file;

  @override
  void initState() {
    stateView = 0;
    cargarDatos();
    super.initState();
  }

  void cargarDatos() async {
    print('$fechadelTitulo  $fechaActual');
    listaMarcaciones =
        await RepositoryServicesLocal.listarMarcacionesFecha(fechaActual);
    listaTrabajadores = await RepositoryServicesLocal.selectAllEmployee();
    if (listaMarcaciones.length != 0) {
      setState(() {
        stateView = 1;
      });
    } else {
      setState(() {
        stateView = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte $fechaActual'),
        actions: [
          IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                if (stateView == 0) {
                  print('ESTA CARGANDO');
                } else {
                  openCalendar();
                }
              }),
          IconButton(
              icon: Icon(Icons.picture_as_pdf),
              onPressed: () async {
                if (stateView == 0) {
                  print('ESTA CARGANDO');
                } else if (stateView == 1) {
                  generarPDF();
                } else if (stateView == 2) {
                  dialog.alertaImagen(
                      context,
                      'Advertencia',
                      'No se puede generar un PDF sin datos',
                      'assets/connectionError.png');
                }
              }),
        ],
      ),
      body: listadoMarcaciones()
    );
  }

  Widget encabezadoMarcaciones() {
    if (stateView == 0) {
      return CircularProgressIndicator();
    } else if (stateView == 1) {
      return Text('Registros de hoy: ${listaMarcaciones.length}');
    } else if (stateView == 2) {
      return Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            'No existen registros de este dia',
            style: TextStyle(color: Colors.red, fontSize: 20),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  listadoMarcaciones() {
    if (stateView == 0) {
      return CircularProgressIndicator();
    } else if (stateView == 1) {
      return Container(
        height: 400,
        child: ListView.builder(
          itemCount: listaMarcaciones.length,
          itemBuilder: (context, index) {
            final temp = listaMarcaciones[index];
            return ListTile(
              title: Text(nombresCompletos(temp.marcadoDni)),
              subtitle: Text(temp.marcadoDni),
              trailing: Text(temp.marcadoTemperatura.toString()),
            );
          },
        ),
      );
    } else if (stateView == 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 30),
        child: Text(
          'NO HAY DATOS REGISTRADOS ESTE DIA',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      );
    }
  }

  String nombresCompletos(String dni) {
    String result;
    for (var i = 0; i < listaTrabajadores.length; i++) {
      final temp = listaTrabajadores[i];
      if (temp.empleadoDni == dni) {
        result = '${temp.empleadoApellido} ${temp.empleadoNombre}';
      }
    }
    return result;
  }

  Future<void> generarPDF() async {
    final String dir = (await getExternalStorageDirectory()).path;
    print(dir);
    final String path = '$dir/Reporte.pdf';
    file = File(path);
    print('empezo la masacre');
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();
    //Get page client size
    final Size pageSize = page.getClientSize();
    //Draw rectangle
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        pen: PdfPen(PdfColor(142, 170, 219, 255)));
    //Generate PDF grid.
    final PdfGrid grid = getGrid();
    //Draw the header section by creating text element
    final PdfLayoutResult result = drawHeader(page, pageSize, grid);
    //Draw grid
    drawGrid(page, grid, result);
    //Add invoice footer
    final List<int> bytes = document.save();
    //Dispose the document.
    document.dispose();
    //Get the storage folder location using path_provider package.

    await file.writeAsBytes(bytes);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => VizorPdf(
              path: path,
            )));
  }

  void openCalendar() {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(2020, 11, 1),
        maxTime: DateTime.now(),
        theme: DatePickerTheme(
            headerColor: Colors.green,
            backgroundColor: Colors.white,
            itemStyle: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            doneStyle: TextStyle(color: Colors.white, fontSize: 16)),
        onChanged: (date) {
      setState(() {
        listaMarcaciones = [];
        stateView = 0;
        fechaActual = DateFormat.yMd().format(date);
        fechadelTitulo = DateFormat.yMMMd().format(date);
        cargarDatos();
      });
    }, onConfirm: (date) {
      listaMarcaciones = [];
      stateView = 0;
      fechaActual = DateFormat.yMd().format(date);
      fechadelTitulo = DateFormat.yMMMd().format(date);
      cargarDatos();
    }, currentTime: DateTime.now(), locale: LocaleType.es);
  }

  PdfLayoutResult drawHeader(PdfPage page, Size pageSize, PdfGrid grid) {
    page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(91, 126, 215, 255)),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 115, 90));
    page.graphics.drawString(
        'Reporte de Marcaciones', PdfStandardFont(PdfFontFamily.helvetica, 30),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(25, 0, pageSize.width - 115, 90),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 90),
        brush: PdfSolidBrush(PdfColor(65, 104, 205)));
    page.graphics.drawString('', PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 100),
        brush: PdfBrushes.white,
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle));
    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    const String address = '';
    final String invoiceNumber = 'Fecha: $fechadelTitulo';
    final Size contentSize = contentFont.measureString(invoiceNumber);

    PdfTextElement(text: invoiceNumber, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(pageSize.width - (contentSize.width + 30), 120,
            contentSize.width + 30, pageSize.height - 120));
    return PdfTextElement(text: address, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(30, 120,
            pageSize.width - (contentSize.width + 30), pageSize.height - 120));
  }

  void drawGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {};
    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0));
  }

  PdfGrid getGrid() {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 5);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'DNI';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'Apellido y Nombres';
    headerRow.cells[1].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[2].value = 'Hora';
    headerRow.cells[2].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[3].value = 'Tipo';
    headerRow.cells[3].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[4].value = 'Temperatura';
    headerRow.cells[4].stringFormat.alignment = PdfTextAlignment.center;

    for (var item in listaMarcaciones) {
      addRegistros(item.marcadoDni, nombresCompletos(item.marcadoDni),
          item.marcadoTiempo, item.marcadoTipo, item.marcadoTemperatura, grid);
    }

    //Apply the table built-in style
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    //Set gird columns width
    grid.columns[1].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    return grid;
  }

  void addRegistros(String dni, String nombres, String tiempo, String tipo,
      double total, PdfGrid grid) {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = dni;
    row.cells[1].value = nombres;
    row.cells[2].value = tiempo;
    row.cells[3].value = tipo;
    row.cells[4].value = total.toString();
  }
}

class VizorPdf extends StatelessWidget {
  final String path;
  const VizorPdf({Key key, this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
      appBar: AppBar(
        title: Text("Vista Previa"),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              share();
            },
          ),
        ],
      ),
      path: path,
    );
  }
  Future<void> share() async {
    try {
      File file = File(path);
      Uint8List listByte = file.readAsBytesSync();
      final ByteData bytes = ByteData.view(listByte.buffer);
      await Share.file(
          'Reporte', 'Reporte.pdf', bytes.buffer.asUint8List(), 'text/pdf');
    } catch (e) {
      print('error: $e');
    }
  }
}
