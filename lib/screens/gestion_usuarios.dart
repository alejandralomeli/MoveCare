import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GestionUsuarios extends StatefulWidget {
  const GestionUsuarios({super.key});

  @override
  State<GestionUsuarios> createState() => _GestionUsuariosState();
}

class _GestionUsuariosState extends State<GestionUsuarios> {
  static const Color primaryBlue = Color(0xFF64A1F4);
  static const Color fieldBlue = Color(0xFFD6E8FF);
  static const Color statusRed = Color(0xFFEF5350);

  double sp(double size, BuildContext context) =>
      MediaQuery.of(context).size.width * (size / 375);

  void _mostrarDialogoRechazo(String usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Rechazar a $usuario',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold, color: primaryBlue),
        ),
        content: TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Escribe el motivo del rechazo...',
            filled: true,
            fillColor: fieldBlue,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: statusRed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(context),
            child: const Text('Enviar y Rechazar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Solicitudes de Registro',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: primaryBlue,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Conductores', icon: Icon(Icons.directions_car)),
              Tab(text: 'Pasajeros', icon: Icon(Icons.person_pin_circle)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildListado(tipo: 'Conductor'),
            _buildListado(tipo: 'Pasajero'),
          ],
        ),
      ),
    );
  }

  Widget _buildListado({required String tipo}) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: 5, 
      itemBuilder: (context, index) {
        String subitulo = tipo == 'Conductor' 
            ? 'Van Toyota Hiace - Placas ABC-123' 
            : 'Usuario Final - Particular';

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: tipo == 'Conductor' ? fieldBlue : Colors.orange.shade100,
                      radius: 25,
                      child: Icon(
                        tipo == 'Conductor' ? Icons.drive_eta : Icons.person,
                        color: tipo == 'Conductor' ? primaryBlue : Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$tipo #${index + 1}',
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(subitulo,
                              style: GoogleFonts.montserrat(
                                  fontSize: 12, color: Colors.black87)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility, color: primaryBlue),
                      onPressed: () {
                        // Ver detalles del documento o perfil
                      },
                    ),
                  ],
                ),
                const Divider(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _mostrarDialogoRechazo('$tipo #${index + 1}'),
                      child: const Text('Rechazar',
                          style: TextStyle(color: statusRed, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                      
                      },
                      child: const Text('Aceptar Usuario',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}