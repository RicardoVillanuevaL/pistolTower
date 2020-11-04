
import 'package:pistol_tower/Moldelos/MarcationModel.dart';
import 'package:pistol_tower/Moldelos/PerfilModel.dart';
import 'package:pistol_tower/database/database.dart';

class RepositoryServicesLocal {
  static Future<PerfilModel> consultarEmpleado(String dni) async {
    PerfilModel result = PerfilModel();
    try {
      final query = '''SELECT * FROM ${DatabaseCreator.tableEmpleado}
              WHERE ${DatabaseCreator.empleado_dni} = ? ''';
      List<dynamic> params = [dni];
      final data = await db.rawQuery(query, params);
      result = PerfilModel.fromJsonLocal(data.first);
    } catch (e) {
      print(e);
      result.empleadoNombre = dni;
      result.empleadoDni = dni;
      result.empleadoApellido = ' ';
      result.empleadoTelefono = ' ';
    }
    return result;
  }

  static Future<bool> actualizarTipodeUsuario(var dni, var value) async {
    bool success;
    try {
      final query = '''UPDATE ${DatabaseCreator.tableEmpleado}
      SET ${DatabaseCreator.id_empresa} = $value
      WHERE ${DatabaseCreator.empleado_dni} = ?''';
      // List<String> params = [value.toString(), dni];
      List<String> params = [dni];
      // final result = await db.rawUpdate(query);
      final result = await db.rawUpdate(query, params);
      DatabaseCreator.databaseLog(
          'actualizar tipo empleado', query, null, result, params);
      success = true;
    } catch (e) {
      print('ERROR' + e);
      success = false;
    }
    return success;
  }

  static Future<List<PerfilModel>> updatesEmployee() async {
    final query = '''SELECT * FROM ${DatabaseCreator.tableEmpleado} 
        WHERE ${DatabaseCreator.empleado_dni} = ${DatabaseCreator.empleado_nombre}''';
    final data = await db.rawQuery(query);

    List<PerfilModel> listEmployee = List();
    for (final nodo in data) {
      final temp = PerfilModel.fromJsonLocal(nodo);
      listEmployee.add(temp);
    }
    return listEmployee;
  }

  static Future<List<PerfilModel>> sincroEmployee() async {
    final query = '''SELECT * FROM ${DatabaseCreator.tableEmpleado} 
        WHERE ${DatabaseCreator.empleado_dni} <> ${DatabaseCreator.empleado_nombre}''';
    final data = await db.rawQuery(query);

    List<PerfilModel> listEmployee = List();
    for (final nodo in data) {
      final temp = PerfilModel.fromJsonLocal(nodo);
      listEmployee.add(temp);
    }
    return listEmployee;
  }

  static Future<List<PerfilModel>> selectAllEmployee() async {
    final query = '''SELECT * FROM ${DatabaseCreator.tableEmpleado}''';
    final data = await db.rawQuery(query);

    List<PerfilModel> listEmployee = List();
    for (final nodo in data) {
      final temp = PerfilModel.fromJsonLocal(nodo);
      listEmployee.add(temp);
    }
    return listEmployee;
  }

  static Future<bool> generarIndicadorEmpleado() async {
    bool success;
    try {
      final sql = '''UPDATE ${DatabaseCreator.tableEmpleado} 
      SET ${DatabaseCreator.id_turno} = 1''';
      final result = await db.rawUpdate(sql);
      DatabaseCreator.databaseLog(
          'indicador creado empleado', sql, null, result);
      success = true;
    } catch (e) {
      print(e);
      success = false;
    }
    return success;
  }

  static Future<bool> generarIndicadorMarcado() async {
    bool success;
    try {
      final sql = '''UPDATE ${DatabaseCreator.tableMarcado} 
      SET ${DatabaseCreator.marcado_dataQR} = ?''';
      List<dynamic> params = ['REGISTRO SUBIDO EXITOSO'];
      final result = await db.rawUpdate(sql, params);
      DatabaseCreator.databaseLog(
          'indicador creado MARCADO', sql, null, result, params);
      success = true;
    } catch (e) {
      print(e);
      success = false;
    }
    return success;
  }

  static Future<bool> actualizarData(PerfilModel model) async {
    bool success;
    try {
      final sql = '''UPDATE ${DatabaseCreator.tableEmpleado} 
      SET ${DatabaseCreator.empleado_nombre} = ?,
      ${DatabaseCreator.empleado_apellido} = ?,
      ${DatabaseCreator.empleado_telefono} = ?
      WHERE ${DatabaseCreator.empleado_dni} = ?
      ''';
      List<dynamic> params = [
        model.empleadoNombre,
        model.empleadoApellido,
        model.empleadoTelefono,
        model.empleadoDni
      ];
      final result = await db.rawUpdate(sql, params);
      DatabaseCreator.databaseLog(
          'actualizar empleado', sql, null, result, params);
      success = true;
    } catch (e) {
      print(e);
      success = false;
    }
    return success;
  }

  static Future<void> addEmpleado(PerfilModel model) async {
    final query = '''INSERT INTO ${DatabaseCreator.tableEmpleado} (
      ${DatabaseCreator.empleado_dni},
      ${DatabaseCreator.empleado_nombre},
      ${DatabaseCreator.empleado_apellido},
      ${DatabaseCreator.empleado_telefono},
      ${DatabaseCreator.id_empresa}
      ) VALUES (?,?,?,?,?)''';
    List<dynamic> params = [
      model.empleadoDni,
      model.empleadoNombre,
      model.empleadoApellido,
      model.empleadoTelefono,
      model.idEmpresa
    ];
    try {
      final result = await db.rawInsert(query, params);
      DatabaseCreator.databaseLog('Add Empleado', query, null, result, params);
    } catch (e) {
      print(e);
    }
  }

  static Future<List<MarcationModel>> listarMarcaciones() async {
    final query = '''SELECT * FROM ${DatabaseCreator.tableMarcado}''';
    final data = await db.rawQuery(query);

    List<MarcationModel> listMarcaciones = List();
    for (final nodo in data) {
      final temp = MarcationModel.fromJsonLocal(nodo);
      listMarcaciones.add(temp);
    }
    print(listMarcaciones.length);
    return listMarcaciones;
  }


  static Future<void> addMarcado(MarcationModel model) async {
    final query = '''INSERT INTO ${DatabaseCreator.tableMarcado} (
      ${DatabaseCreator.marcado_id_telefono},
      ${DatabaseCreator.marcado_dni},
      ${DatabaseCreator.marcado_latitud},
      ${DatabaseCreator.marcado_longitud},
      ${DatabaseCreator.marcado_dataQR},
      ${DatabaseCreator.marcado_fecha_hora},
      ${DatabaseCreator.marcado_tipo},
      ${DatabaseCreator.marcado_motivo},
      ${DatabaseCreator.marcado_temperatura},
      ${DatabaseCreator.marcado_tiempo}
    ) VALUES (?,?,?,?,?,?,?,?,?,?)''';
    List<dynamic> params = [
      model.marcadoIdTelefono,
      model.marcadoDni,
      model.marcadoLatitud,
      model.marcadoLongitud,
      model.marcadoDataQr,
      model.marcadoFechaHora,
      model.marcadoTipo,
      model.marcadoMotivo,
      model.marcadoTemperatura,
      model.marcadoTiempo
    ];
    final result = await db.rawInsert(query, params);
    DatabaseCreator.databaseLog('Add Marcado', query, null, result, params);
  }

}

final localServices = RepositoryServicesLocal();
