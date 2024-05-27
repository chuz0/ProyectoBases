from flask import Flask, jsonify, redirect, render_template, request, url_for
from flask_cors import CORS
import pyodbc
import datetime

app = Flask(__name__)
CORS(app) 


def ejecutar_stored_procedure(nombre_sp, parametros=None):
    # Configuración de la conexión a la base de datos
    server = 'DESKTOP-HUTR52P'
    database = 'proyectoBases'
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
            resultados = cursor.fetchall()
            return resultados
        else:
            return None
    finally:
        cursor.close()
        conn.close()


if __name__ == '__main__':
    app.run(debug=True)