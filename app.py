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
        facturas = ejecutar_stored_procedure('ObtenerFacturasPorCliente', cliente['Id'])
        return render_template('facturas.html', cliente=cliente, facturas=facturas)
    return "Cliente no encontrado", 404

@app.route('/factura/<int:factura_id>', methods=['GET'])
def factura_detalle(factura_id):
    factura = ejecutar_stored_procedure('ObtenerFacturaPorId', factura_id)
    if factura:
        factura = factura[0]  # Asumimos que sólo hay una factura con ese ID
        llamadas = ejecutar_stored_procedure('ObtenerLlamadasPorContrato', factura['IdContrato'])
        uso_datos = ejecutar_stored_procedure('ObtenerUsoDatosPorContrato', factura['IdContrato'])
        return render_template('factura_detalle.html', factura=factura, llamadas=llamadas, uso_datos=uso_datos)
    return "Factura no encontrada", 404

@app.route('/estado_cuenta/<empresa>', methods=['GET'])
def estado_cuenta(empresa):
    estado = ejecutar_stored_procedure('ObtenerEstadoCuenta', f"'{empresa}'")
    return render_template('estado_cuenta.html', empresa=empresa, estado=estado)

@app.route('/nuevo_cliente', methods=['POST'])
def nuevo_cliente():
    nombre = request.form['nombre']
    direccion = request.form['direccion']
    telefono = request.form['telefono']
    ejecutar_stored_procedure('InsertarNuevoCliente', f"'{nombre}', '{direccion}', '{telefono}'")
    return redirect(url_for('home'))

@app.route('/nuevo_contrato', methods=['POST'])
def nuevo_contrato():
    id_cliente = request.form['id_cliente']
    fecha_firma = request.form['fecha_firma']
    tipo_telefono = request.form['tipo_telefono']
    id_tipo_tarifa = request.form['id_tipo_tarifa']
    ejecutar_stored_procedure('InsertarNuevoContrato', f"{id_cliente}, '{fecha_firma}', '{tipo_telefono}', {id_tipo_tarifa}")
    return redirect(url_for('home'))

@app.route('/nueva_llamada', methods=['POST'])
def nueva_llamada():
    id_contrato = request.form['id_contrato']
    fecha_hora_inicio = request.form['fecha_hora_inicio']
    fecha_hora_fin = request.form['fecha_hora_fin']
    destino = request.form['destino']
    tipo_tarifa = request.form['tipo_tarifa']
    tipo_empresa_destino = request.form['tipo_empresa_destino']
    es_familiar = request.form['es_familiar']
    ejecutar_stored_procedure('RegistrarNuevaLlamada', f"{id_contrato}, '{fecha_hora_inicio}', '{fecha_hora_fin}', '{destino}', '{tipo_tarifa}', '{tipo_empresa_destino}', {es_familiar}")
    return redirect(url_for('home'))

@app.route('/nuevo_uso_datos', methods=['POST'])
def nuevo_uso_datos():
    id_contrato = request.form['id_contrato']
    fecha = request.form['fecha']
    cantidad_gigas = request.form['cantidad_gigas']
    ejecutar_stored_procedure('RegistrarUsoDatos', f"{id_contrato}, '{fecha}', {cantidad_gigas}")
    return redirect(url_for('home'))

@app.route('/pagar_factura', methods=['POST'])
def pagar_factura():
    id_contrato = request.form['id_contrato']
    ejecutar_stored_procedure('PagarFacturaPendiente', id_contrato)
    return redirect(url_for('home'))

@app.route('/cerrar_factura', methods=['POST'])
def cerrar_factura():
    fecha = request.form['fecha']
    ejecutar_stored_procedure('CerrarFactura', f"'{fecha}'")
    return redirect(url_for('home'))

if __name__ == '__main__':
    app.run(debug=True)
