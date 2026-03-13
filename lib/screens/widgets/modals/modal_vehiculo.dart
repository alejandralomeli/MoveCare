import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModalInfoVehiculo extends StatelessWidget {
  final double sw;
  
  const ModalInfoVehiculo({super.key, required this.sw});

  double sp(double size, double sw) => sw * (size / 375);

  TextStyle mBold(double sw, {Color color = Colors.black, double size = 14}) {
    return GoogleFonts.montserrat(color: color, fontSize: sp(size, sw), fontWeight: FontWeight.bold);
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: mBold(sw, size: 12, color: Colors.grey[700]!)),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200], 
              borderRadius: BorderRadius.circular(10), 
              border: Border.all(color: Colors.grey[300]!)
            ),
            child: Text(value, style: mBold(sw, size: 14)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50, height: 5, 
              decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10))
            ),
          ),
          const SizedBox(height: 20),
          Text('Datos de mi Vehículo', style: mBold(sw, size: 18, color: const Color(0xFF1559B2))),
          const SizedBox(height: 15),
          
          _buildReadOnlyField('Marca', 'Nissan'),
          _buildReadOnlyField('Modelo', 'Versa 2021'),
          _buildReadOnlyField('Color', 'Plata'),
          _buildReadOnlyField('Placas', 'XYZ-987-A'),
          
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1559B2)),
              child: Text('Cerrar', style: mBold(sw, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}