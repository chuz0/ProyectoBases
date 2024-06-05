from flask import Flask, jsonify, redirect, render_template, request, url_for
from flask_cors import CORS
import pyodbc

app = Flask(__name__)
CORS(app)

def ejecutar_stored_procedure(nombre_sp, parametros=None):
    # Configuración de la conexión a la base de datos
    server = 'DESKTOP-HUTR52P'
    database = 'proyectoBD'
    username = 'hola'
    password = 'password'
    conn_str = f'DRIVER=ODBC Driver 17 for SQL Server;SERVER={server};DATABASE={database};UID={username};PWD={password}'

    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    try:
        if parametros:
            cursor.execute(f"EXEC {nombre_sp} {parametros}")
        else:
            cursor.execute(f"EXEC {nombre_sp}")

        if cursor.description:
            columnas = [column[0] for column in cursor.description]
            resultados = cursor.fetchall()
            resultados_dict = [dict(zip(columnas, fila)) for fila in resultados]
            return resultados_dict
        else:
            return None
    finally:
        cursor.close()
        conn.close()

@app.route('/')
def home():
    return "Hello, Flask!"

@app.route('/facturas/<telefono>', methods=['GET'])
def facturas(telefono):
    cliente = ejecutar_stored_procedure('BuscarClientePorTelefono', f"'{telefono}'")
    if cliente:
        cliente = cliente[0]  # Asumimos que sólo hay un cliente con ese teléfono
        facturas = ejecutar_stored_procedure('ObtenerFacturasPorCliente', cliente['id'])
        return render_template('facturas.html', cliente=cliente, facturas=facturas)
    return "Cliente no encontrado", 404

@app.route('/factura/<int:factura_id>', methods=['GET'])
def factura_detalle(factura_id):
    factura = ejecutar_stored_procedure('ObtenerFacturaPorId', factura_id)
    if factura:
        factura = factura[0]  # Asumimos que sólo hay una factura con ese ID
        llamadas = ejecutar_stored_procedure('ObtenerLlamadasPorContrato', factura['id_contrato'])
        uso_datos = ejecutar_stored_procedure('ObtenerUsoDatosPorContrato', factura['id_contrato'])
        return render_template('factura_detalle.html', factura=factura, llamadas=llamadas, uso_datos=uso_datos)
    return "Factura no encontrada", 404

@app.route('/estado_cuenta/<empresa>', methods=['GET'])
def estado_cuenta(empresa):
    estado = ejecutar_stored_procedure('ObtenerEstadoCuenta', f"'{empresa}'")
    return render_template('estado_cuenta.html', empresa=empresa, estado=estado)

if __name__ == '__main__':
    app.run(debug=True)
