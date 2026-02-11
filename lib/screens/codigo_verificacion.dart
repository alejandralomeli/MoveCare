import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CodigoVerificacion extends StatelessWidget {
  const CodigoVerificacion({super.key});

  static const Color primaryBlue = Color(0xFF1559B2);
  static const Color fieldBlue = Color(0xFFD6E8FF);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double sw = size.width;
    
    double sp(double pixels) => sw * (pixels / 375);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.40,
            child: Image.asset(
              'assets/ruta.png',
              fit: BoxFit.cover,
            ),
          ),
          
          Positioned(
            top: MediaQuery.of(context).padding.top + sp(35),
            left: sp(10),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new, 
                color: primaryBlue, 
                size: sp(20), 
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.72, 
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sp(50)),
                  topRight: Radius.circular(sp(50)),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                ]
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: sp(30)),
                child: Column(
                  children: [
                    SizedBox(height: sp(30)),

                    _buildLogo(sp),

                    SizedBox(height: sp(25)),

                    Text(
                      'Código de verificación',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: sp(22),
                      ),
                    ),

                    SizedBox(height: sp(10)),

                    Text(
                      'Código de verificación enviado a:\nmovecare@gmail.com',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.black87,
                        fontSize: sp(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: sp(35)),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sp(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCodeBox(context, sp, first: true, last: false),
                          _buildCodeBox(context, sp, first: false, last: false),
                          _buildCodeBox(context, sp, first: false, last: false),
                          _buildCodeBox(context, sp, first: false, last: true),
                        ],
                      ),
                    ),

                    SizedBox(height: sp(40)),

                    SizedBox(
                      width: sw * 0.75,
                      height: sp(55),
                      child: ElevatedButton(
                        onPressed: () {
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sp(30)),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Confirmar código',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: sp(16),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: sp(30)),

                    _buildResendFooter(sp),
                    SizedBox(height: sp(30)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(double Function(double) sp) {
    return Center(
      child: Container(
        width: sp(90), 
        height: sp(90),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F1FF),
          borderRadius: BorderRadius.circular(sp(25)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Padding(
          padding: EdgeInsets.all(sp(15)),
          child: Image.asset('assets/movecare.png', fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildCodeBox(BuildContext context, double Function(double) sp, {required bool first, required bool last}) {
    return Container(
      height: sp(65),
      width: sp(60),
      decoration: BoxDecoration(
        color: fieldBlue.withOpacity(0.3),
        border: Border.all(color: primaryBlue, width: 1.5),
        borderRadius: BorderRadius.circular(sp(15)),
      ),
      child: TextField(
        autofocus: first,
        onChanged: (value) {
          if (value.length == 1 && !last) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && !first) {
            FocusScope.of(context).previousFocus();
          }
        },
        showCursor: false,
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(
          fontSize: sp(24),
          fontWeight: FontWeight.bold,
          color: primaryBlue
        ),
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildResendFooter(double Function(double) sp) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '00:29 ',
          style: GoogleFonts.montserrat(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: sp(13),
          ),
        ),
        Text(
          'Reenviar código de confirmación',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: Colors.black54,
            fontSize: sp(13),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}