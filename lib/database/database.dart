import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database db;

class DatabaseCreator {
  ////////////////--TABLA EMPLEADO--///////////////////
  static const tableEmpleado = 'empleado'; /////// NOMBRE DE LA TABLA
  static const empleado_dni = 'empleado_dni';
  static const empleado_nombre = 'empleado_nombre';
  static const empleado_apellido = 'empleado_apellido';
  static const empleado_telefono = 'empleado_telefono';
  static const empleado_email = 'empleado_email';
  static const empleado_contrasena = 'empleado_contraseña';
  static const empleado_imei = 'empleado_imei';
  static const empleado_token = 'empleado_token';
  static const empleado_foto = 'empleado_foto';
  static const empleado_ultimo_ingreso = 'empleado_ultimo_ingreso';
  static const empleado_tokencelular = 'empleado_tokencelular';
  static const usuario_dni_jefe = 'usuario_dni_jefe';
  static const tipo_id_cargo = 'tipo_id_cargo';
  static const id_turno = 'id_turno';
  static const id_area = 'id_area';
  static const id_empresa = 'id_empresa';
  static const hora_inicio = 'hora_inicio';
  static const hora_fin = 'hora_fin';
  ////////////////--TABLA MARCADO--///////////////////
  static const tableMarcado = 'marcado'; /////// NOMBRE DE LA TABLA
  static const marcado_id_telefono = 'marcado_id_telefono';
  static const marcado_dni = 'marcado_dni';
  static const marcado_latitud = 'marcado_latitud';
  static const marcado_longitud = 'marcado_longitud';
  static const marcado_dataQR = 'marcado_dataQR';
  static const marcado_fecha_hora = 'marcado_fecha_hora'; //DATE
  static const marcado_tipo = 'marcado_tipo';
  static const marcado_motivo = 'marcado_motivo';
  static const marcado_temperatura = 'marcado_temperatura'; // DOUBLE
  static const marcado_tiempo = 'marcado_tiempo'; //TIME
  ////////////////--TABLA NOTIFICACION--///////////////////
  static const tableNotificacion = 'notifications'; /////// NOMBRE DE LA TABLA
  static const dni_user_notification = 'dni_user_notification';
  static const fecha_notification = 'fecha_notification';
  static const latitud_notification = 'latitud_notification';
  static const longtitud_notification = 'longtitud_notification';
  static const titulo_notification = 'titulo_notification';
  static const cuerpo_notification = 'cuerpo_notification';

  static void databaseLog(String functionName, String sql,
      [List<Map<String, dynamic>> selectQueryResult,
      int insertAndUpdateQueryResult,
      List<dynamic> params]) {
    print(functionName);
    print(sql);
    if (params != null) {
      print(params);
    }
    if (selectQueryResult != null) {
      print(selectQueryResult);
    } else if (insertAndUpdateQueryResult != null) {
      print(insertAndUpdateQueryResult);
    }
  }

  Future<void> createEmpleadoTable(Database db) async {
    final queryEmpleado = '''CREATE TABLE $tableEmpleado
    (
      $empleado_dni TEXT PRIMARY KEY,
      $empleado_nombre TEXT,
      $empleado_apellido TEXT,
      $empleado_telefono TEXT,
      $empleado_email TEXT,
      $empleado_contrasena TEXT,
      $empleado_imei TEXT,
      $empleado_token TEXT,
      $empleado_foto TEXT,
      $empleado_ultimo_ingreso TEXT,
      $empleado_tokencelular TEXT,
      $usuario_dni_jefe TEXT,
      $tipo_id_cargo INTEGER,
      $id_turno INTEGER,
      $id_area INTEGER,
      $id_empresa TEXT,
      $hora_inicio TEXT,
      $hora_fin TEXT
    )''';
    await db.execute(queryEmpleado);
  }

  Future<void> createMarcadoTable(Database db) async {
    final queryMarcado = '''CREATE TABLE $tableMarcado
    (
      $marcado_id_telefono TEXT ,
      $marcado_dni TEXT ,
      $marcado_latitud TEXT ,
      $marcado_longitud TEXT ,
      $marcado_dataQR TEXT ,
      $marcado_fecha_hora TEXT ,
      $marcado_tipo TEXT ,
      $marcado_motivo TEXT ,
      $marcado_temperatura NUMBER ,
      $marcado_tiempo TEXT 
    )''';
    await db.execute(queryMarcado);
  }

  Future<void> createNotificationTable(Database db) async {
    final queryNotificacion = '''CREATE TABLE $tableNotificacion
    (
      $tableNotificacion TEXT,
      $dni_user_notification TEXT,
      $fecha_notification TEXT,
      $latitud_notification TEXT,
      $longtitud_notification TEXT,
      $titulo_notification TEXT,
      $cuerpo_notification TEXT
    )''';
    await db.execute(queryNotificacion);
  }

  Future<String> getDatabasePath(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    if (await Directory(dirname(path)).exists()) {
    } else {
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }

  Future<void> initDatabase() async {
    final path = await getDatabasePath('todo_db');
    db = await openDatabase(path, version: 1, onCreate: onCreate);
    print(db);
  }

  Future<void> onCreate(Database db, int version) async {
    await createEmpleadoTable(db);
    await createMarcadoTable(db);
    await createNotificationTable(db);
  }
}
