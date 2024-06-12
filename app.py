from flask import Flask, jsonify, redirect, render_template, request, url_for
from flask_cors import CORS
import pyodbc

app = Flask(__name__)
CORS(app)

# Función para ejecutar procedimientos almacenados en la base de datos
def ejecutar_stored_procedure(nombre_sp, parametros=None):
    # Configurar la conexión a la base de datos
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

# Rutas en Flask
@app.route('/')
def home():
    # Renderizar el HTML del menú principal
    return render_template('menu.html')

@app.route('/facturas')
def facturas():
    facturas = ejecutar_stored_procedure('ObtenerFacturas')
    return render_template('facturas.html', facturas=facturas)

@app.route('/clientes')
def clientes():
    clientes = ejecutar_stored_procedure('ObtenerClientes')
    return render_template('clientes.html', clientes=clientes)

@app.route('/contratos')
def contratos():
    contratos = ejecutar_stored_procedure('ObtenerContratos')
    return render_template('contratos.html', contratos=contratos)

@app.route('/llamadas')
def llamadas():
    llamadas = ejecutar_stored_procedure('ObtenerLlamadas')
    return render_template('llamadas.html', llamadas=llamadas)

if __name__ == '__main__':
    app.run(debug=True)
