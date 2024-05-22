import 'dart:math';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_fast_forms/flutter_fast_forms.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart';
import 'package:intl/intl.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';

const String SUPABASE_URL = 'https://rknmjqfaxehhwcdyfjnn.supabase.co';
const String SUPABASE_ANON_KEY =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJrbm1qcWZheGVoaHdjZHlmam5uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTU5MDc4MDcsImV4cCI6MjAzMTQ4MzgwN30._c2qx5YtBQXulKPc2e1IGhCvedl63Az1S37JvVxSgiM';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );

  runApp(MaterialApp(
    home: BottomNavBar(),
    debugShowCheckedModeBanner: false,
  ));
}

final supabase = Supabase.instance.client;

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _page = 1;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  String _appBarIconPath = 'assets/pngegg.png';
  // Lista de widgets para cada página
  final List<Widget> _pageContents = [
    Page1(),
    Page2(),
    Page3(),
    Page4(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(_appBarIconPath, width: 24, height: 24),
            SizedBox(width: 8),
            Text(
              'MovíMan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 1,
        height: 60.0,
        items: <Widget>[
          Icon(Icons.add, size: 30),
          Icon(Icons.list_alt_rounded, size: 30),
          Icon(Icons.perm_identity, size: 30),
          Icon(Icons.add_task_sharp, size: 30),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 172, 176, 184),
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        letIndexChange: (index) => true,
      ),
      body: Container(
        color: Color.fromARGB(255, 223, 225, 228),
        child: Center(
          child: _pageContents[
              _page], // Mostrar contenido basado en la página seleccionada
        ),
      ),
    );
  }
}

// Definir diferentes diseños de página como widgets separados
class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> titles = [
      "Mantenimiento",
      "Equipo",
      "Requisito y Procedimiento"
    ];

    final List<String> gifPaths = [
      'assets/siga_mante.gif',
      'assets/importancia-trabajo-en-equipo.jpg',
      'assets/requisito.gif'
    ];

    final List<Widget> images =
        gifPaths.map((path) => Image.asset(path, fit: BoxFit.cover)).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: VerticalCardPager(
                  titles: titles,
                  images: images,
                  textStyle: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                  onPageChanged: (page) {},
                  onSelectedItem: (index) {
                    if (titles[index] == "Mantenimiento") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MaintenancePage(),
                        ),
                      );
                    } else if (titles[index] == "Equipo") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamPage(
                            teamLeader: '',
                            teamName: '',
                            equipmentName: '',
                            maintenanceDetails: '',
                          ),
                        ),
                      );
                    } else if (titles[index] == "Requisito y Procedimiento") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Requisito(),
                        ),
                      );
                    }
                  },
                  initialPage: 1,
                  align: ALIGN.CENTER,
                  physics: ClampingScrollPhysics(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MaintenancePage extends StatefulWidget {
  @override
  _MaintenancePageState createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tipoMantenimientoController =
      TextEditingController();
  final TextEditingController _nivelMantenimientoController =
      TextEditingController();
  final TextEditingController _frecuenciaController = TextEditingController();
  final TextEditingController _equipoEncargadoController =
      TextEditingController(); // Nuevo controlador
  late DateTime _ultimaVez;

  @override
  void initState() {
    super.initState();
    _ultimaVez = DateTime.now();
  }

  Future<void> _guardarDatos() async {
    final tipoMantenimiento = _tipoMantenimientoController.text;
    final nivelMantenimiento = _nivelMantenimientoController.text;
    final frecuencia = _frecuenciaController.text;
    final equipoEncargado = _equipoEncargadoController.text; // Nuevo dato
    Fluttertoast.showToast(msg: "Datos guardados correctamente");
    final response =
        await Supabase.instance.client.from('mantenimiento').insert({
      'tipo': tipoMantenimiento,
      'nivel': nivelMantenimiento,
      'frecuencia': frecuencia,
      'encargado': equipoEncargado, // Guardar el nuevo dato
      'ultimo':
          DateFormat('yyyy-MM-dd').format(_ultimaVez), // Formatear la fecha
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mantenimiento"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tipoMantenimientoController,
                decoration: InputDecoration(
                  labelText: 'Tipo de Mantenimiento',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _nivelMantenimientoController,
                decoration: InputDecoration(
                  labelText: 'Nivel de Mantenimiento',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10), // Añadir un espacio
              TextFormField(
                controller: _equipoEncargadoController,
                decoration: InputDecoration(
                  labelText: 'Equipo encargado',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _frecuenciaController,
                decoration: InputDecoration(
                  labelText: 'Cuantas veces se hace',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Última vez de Mantenimiento',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd')
                      .format(_ultimaVez), // Formatear la fecha
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _ultimaVez,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _ultimaVez = pickedDate;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarDatos,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeamPage extends StatelessWidget {
  final String teamLeader;
  final String teamName;
  final String maintenanceDetails;
  final String equipmentName;

  final TextEditingController _teamLeaderController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _maintenanceDetailsController =
      TextEditingController();
  final TextEditingController _equipmentNameController =
      TextEditingController();

  TeamPage({
    required this.teamLeader,
    required this.teamName,
    required this.maintenanceDetails,
    required this.equipmentName,
  }) {
    _teamLeaderController.text = teamLeader;
    _teamNameController.text = teamName;
    _maintenanceDetailsController.text = maintenanceDetails;
    _equipmentNameController.text = equipmentName;
  }

  Future<void> _guardarDatos() async {
    Fluttertoast.showToast(msg: "Datos guardados correctamente");
    final response = await Supabase.instance.client.from('equipo').insert({
      'responsable': _teamLeaderController.text,
      'nombre': _teamNameController.text,
      'caracteristica': _maintenanceDetailsController.text,
      'realizar': _equipmentNameController.text,
    });

    if (response.error == null) {
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Equipo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: GlobalKey<FormState>(),
          child: Column(
            children: [
              TextFormField(
                controller: _equipmentNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del equipo',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _teamLeaderController,
                decoration: InputDecoration(
                  labelText: 'Responsable del equipo',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _teamNameController,
                decoration: InputDecoration(
                  labelText: 'Características generales',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _maintenanceDetailsController,
                decoration: InputDecoration(
                  labelText: 'Mantenimiento a realizar',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(
                  height:
                      20), // Espacio entre el último campo de texto y el botón
              ElevatedButton(
                onPressed: () => _guardarDatos(),
                child: Text('Guardar'), // Texto del botón
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Requisito extends StatelessWidget {
  final TextEditingController _requisitoController = TextEditingController();
  final TextEditingController _procedimientoController =
      TextEditingController();

  Future<void> _guardarDatos(BuildContext context) async {
    Fluttertoast.showToast(msg: "Datos guardados correctamente");
    final response = await Supabase.instance.client.from('requisito').insert({
      'requisito': _requisitoController.text,
      'procedimiento': _procedimientoController.text,
    });

    if (response.error == null) {
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Requisito y mantenimiento"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Requisito:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _requisitoController,
              decoration: InputDecoration(
                labelText: 'Requisito',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Procedimiento:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _procedimientoController,
              decoration: InputDecoration(
                labelText: 'Procedimiento',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _guardarDatos(context),
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class Page2 extends StatefulWidget {
  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  late Future<List<Map<String, dynamic>>> _mantenimientos;

  @override
  void initState() {
    super.initState();
    _mantenimientos = _fetchMantenimientos();
  }

  Future<List<Map<String, dynamic>>> _fetchMantenimientos() async {
    final response = await Supabase.instance.client
        .from('mantenimiento')
        .select(); // Asegúrate de llamar a `execute` para obtener los datos

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Mantenimiento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _mantenimientos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay datos disponibles'));
                  }

                  final data = snapshot.data!;
                  return PaginatedDataTable(
                    rowsPerPage: 5,
                    columns: [
                      DataColumn(label: Text('Tipo de mantenimiento')),
                      DataColumn(label: Text('Nivel de mantenimiento')),
                      DataColumn(label: Text('Cuantas veces se hace')),
                      DataColumn(label: Text('Última vez que se hizo')),
                      DataColumn(label: Text('Equipo encargado')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    source: MyDataTableSource(data),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> data;

  MyDataTableSource(this.data);

  @override
  DataRow getRow(int index) {
    final mantenimiento = data[index];

    return DataRow(cells: [
      DataCell(Text(
          mantenimiento['tipo'])), // 'tipo' en lugar de 'tipo_mantenimiento'
      DataCell(Text(mantenimiento['nivel'])),
      // 'nivel' en lugar de 'nivel_mantenimiento'
      DataCell(Text(mantenimiento['frecuencia'].toString())),

      DataCell(Text(mantenimiento['ultimo'])),
      DataCell(Text(mantenimiento['encargado']
          .toString())), // 'ultimo' en lugar de 'ultima_vez'
      DataCell(
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Lógica para editar la fila
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Lógica para eliminar la fila
              },
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

class Page3 extends StatefulWidget {
  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  late Future<List<Map<String, dynamic>>> _equipos;

  @override
  void initState() {
    super.initState();
    _equipos = _fetchEquipos();
  }

  Future<List<Map<String, dynamic>>> _fetchEquipos() async {
    final response = await Supabase.instance.client
        .from(
            'equipo') // Reemplaza 'equipos' con el nombre de tu tabla de equipos en Supabase
        .select();

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Lista de Equipos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _equipos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay datos disponibles'));
                  }

                  final data = snapshot.data!;
                  return PaginatedDataTable(
                    rowsPerPage: 5,
                    columns: [
                      DataColumn(
                        label: Text('Nombre del equipo'),
                      ),
                      DataColumn(
                        label: Text('Responsable del equipo'),
                      ),
                      DataColumn(
                        label: Text('Caracteristica generales'),
                      ),
                      DataColumn(
                        label: Text('Mantenimiento a realizar'),
                      ),
                      DataColumn(
                        label: Text('Acciones'),
                      ),
                    ],
                    source: MyDataTableSourcee(data),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyDataTableSourcee extends DataTableSource {
  final List<Map<String, dynamic>> data;

  MyDataTableSourcee(this.data);

  @override
  DataRow getRow(int index) {
    if (data.isEmpty || index >= data.length || data[index] == null) {
      return DataRow(cells: []);
    }

    final equipo = data[index];

    return DataRow(cells: [
      DataCell(Text(
          equipo['nombre'] ?? '')), // Verificación de nulidad para 'nombre'
      DataCell(Text(equipo['responsable'] ??
          '')), // Verificación de nulidad para 'responsable'
      DataCell(Text(equipo['caracteristica'] ?? '')),
      DataCell(Text(equipo['realizar'] ??
          '')), // Verificación de nulidad para 'mantenimiento'
      DataCell(
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Lógica para editar la fila
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Lógica para eliminar la fila
              },
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

class Page4 extends StatefulWidget {
  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  late Future<List<Map<String, dynamic>>> _requisitos;

  @override
  void initState() {
    super.initState();
    _requisitos = _fetchRequisitos();
  }

  Future<List<Map<String, dynamic>>> _fetchRequisitos() async {
    final response = await Supabase.instance.client
        .from(
            'requisito') // Reemplaza 'requisitos' con el nombre de tu tabla en Supabase
        .select();

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Lista de Requisitos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _requisitos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay datos disponibles'));
                  }

                  final data = snapshot.data!;
                  return PaginatedDataTable(
                    rowsPerPage: 5,
                    columns: [
                      DataColumn(
                        label: Text('Requisito'),
                      ),
                      DataColumn(
                        label: Text('Procedimiento'),
                      ),
                      DataColumn(
                        label: Text('Acciones'),
                      ),
                    ],
                    source: MyDataTableSourceee(data),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyDataTableSourceee extends DataTableSource {
  final List<Map<String, dynamic>> data;

  MyDataTableSourceee(this.data);

  @override
  DataRow getRow(int index) {
    final requisito = data[index];

    return DataRow(cells: [
      DataCell(Text(requisito['requisito'] ??
          '')), // Reemplaza 'requisito' con el nombre de tu columna
      DataCell(Text(requisito['procedimiento'] ??
          '')), // Reemplaza 'procedimiento' con el nombre de tu columna
      DataCell(
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Lógica para editar la fila
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Lógica para eliminar la fila
              },
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
