import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/Services/Database.dart';
import 'package:myapp/Pages/info_compra_user.dart';


class HistorialCompraUser extends StatefulWidget {
  @override
  _HistorialCompraUserState createState() => _HistorialCompraUserState();
}

class _HistorialCompraUserState extends State<HistorialCompraUser> {
  late ProductsRepository _productsRepository;
  late Future<List<Map<String, dynamic>>> _comprasFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _productsRepository = ProductsRepository(Supabase.instance.client);
    _fetchClienteIdAndCompras();
  }

  Future<void> _fetchClienteIdAndCompras() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;

      if (user != null && user.userMetadata != null) {
        final userEmail = user.userMetadata?['email'];
        if (userEmail != null) {

          final clienteId = await _productsRepository.getUserIdByEmail(
              userEmail);


          if (clienteId != null) {
            setState(() {

              _comprasFuture = _productsRepository.fetchCompras(clienteId);
            });
          } else {

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ID del cliente no encontrado.')),
            );
          }
        }
      }
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener el cliente ID: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial Carrito'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              // Mostrar diálogo de confirmación
              bool? confirmDelete = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirmar eliminación'),
                    content: Text('¿Estás seguro de que deseas eliminar el historial?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: Text('Eliminar'),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );


              if (confirmDelete == true) {
                try {

                  await _deleteAllCompras();


                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Historial eliminado exitosamente'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {

                  print('Error al eliminar el historial: $e');
                }
              }
            },
            tooltip: 'Eliminar producto',
          ),

        ],
      ),
      body: Stack(
        children: [
          // Fondo de imagen
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'), // Ajusta la ruta a tu imagen
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _comprasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay compras disponibles.'));
                }

                final compras = snapshot.data!;

                return ListView.builder(
                  itemCount: compras.length,
                  itemBuilder: (context, index) {
                    final compra = compras[index];
                    return ListTile(
                      contentPadding: EdgeInsets.all(8.0),

                      leading: Card(
                        margin: EdgeInsets.zero,
                        elevation: 4,
                        child: Image.asset(
                          'assets/images/carrito.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text('ID Compra: ${compra['idcompra']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fecha: ${compra['fechacompra']}'),
                          Text('Costo Total: ${compra['costocarrito'].toStringAsFixed(2)}'),
                          Text('Cantidad de Productos: ${compra['cantidad_productos']}'),
                        ],
                      ),
                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubHistorialUser(idCompra: compra['idcompra']),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _deleteAllCompras() async {
    try {

      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user != null && user.userMetadata != null) {
        final userEmail = user.userMetadata?['email'];
        if (userEmail != null) {
          final clienteId = await _productsRepository.getUserIdByEmail(
              userEmail);
          if (clienteId != null) {
            await _productsRepository.deleteAllCompras(clienteId);
            setState(() {

              _fetchClienteIdAndCompras();
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar compras: $e')),
      );
    }
  }
}
