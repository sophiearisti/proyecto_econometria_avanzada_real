# Script para obtener coordenadas y dirección de tiendas OXXO desde Google Places API
import requests
import csv
import os
import time
from dotenv import load_dotenv

load_dotenv()  # load from .env file
apiKey = os.getenv("GOOGLE_MAPS_API_KEY")

input_file_list=["../data/negocios/tienda_ara.csv", "../data/negocios/D1.csv", "../data/negocios/justo_y_bueno.csv", "../data/negocios/oxxo.csv"]
temp_file_list=["../data/negocios/tienda_ara_shops_progress.csv", "../data/negocios/d1_shops_progress.csv", "../data/negocios/justo_y_bueno_shops_progress.csv", "../data/negocios/oxxo_shops_progress.csv"]

batch_size = 100  # Guardar resultados cada 100 filas
sleep_time = 0.1  # Pausa entre consultas para no exceder límites

def obtain_coordinates(input_file, temp_file):
    # Ver si hay un CSV de progreso
    if os.path.exists(temp_file):
        with open(temp_file, newline='', encoding='utf-8') as f:
            reader = list(csv.DictReader(f))
            start_index = len(reader)
    else:
        start_index = 0

    with open(input_file, newline='', encoding='utf-8') as csvfile_in:
        reader = list(csv.DictReader(csvfile_in))

        # Nuevos encabezados ordenados
        original_fields = list(reader[0].keys())
        fieldnames = original_fields + ["latitud", "longitud", "direccion"]

        results = []
        if start_index > 0:
            with open(temp_file, newline='', encoding='utf-8') as f:
                results = list(csv.DictReader(f))

        for i in range(start_index, len(reader)):
            row = reader[i]

            # Construir query
            #OJO QUE TOCA QUITAR {row['Cámara de Comercio']} NO NECESARIAMENTE FUNCIONA
            query = f"{row['Nombre']}, Colombia"
            url = f"https://maps.googleapis.com/maps/api/place/textsearch/json?query={query}&key={apiKey}&language=es"

            try:
                response = requests.get(url)
                data = response.json()

                if data['status'] == 'OK' and len(data['results']) > 0:
                    results_list = data['results']
                    chosen = None

                    # Si está cancelada en el CSV, buscamos resultados cerrados
                    if row['Estado de la matrícula'].strip().upper() == "CANCELADA":
                        for res in results_list:
                            if res.get("business_status") in ["CLOSED_TEMPORARILY", "CLOSED_PERMANENTLY"]:
                                chosen = res
                                break

                    # Si no encontramos cerrado, o no estaba cancelada → tomamos el primero
                    if not chosen:
                        chosen = results_list[0]

                    row['latitud'] = chosen['geometry']['location']['lat']
                    row['longitud'] = chosen['geometry']['location']['lng']
                    row['direccion'] = chosen.get('formatted_address', "")
                else:
                    row['latitud'] = ""
                    row['longitud'] = ""
                    row['direccion'] = ""
            except Exception as e:
                print(f"Error en la fila {i}: {e}")
                row['latitud'] = ""
                row['longitud'] = ""
                row['direccion'] = ""

            results.append(row)

            # Guardado parcial cada batch_size filas
            if (i + 1) % batch_size == 0 or (i + 1) == len(reader):
                with open(temp_file, 'w', newline='', encoding='utf-8') as f:
                    writer = csv.DictWriter(f, fieldnames=fieldnames)
                    writer.writeheader()
                    writer.writerows(results)
                print(f"Guardadas {i + 1} filas de {len(reader)}")

            time.sleep(sleep_time)

    # Reemplazamos el archivo original con el enriquecido
    os.replace(temp_file, input_file)
    print("✅ Proceso terminado. El CSV ahora tiene latitude, longitude y formatted_address.")

print("Iniciando proceso de obtención de coordenadas y direcciones...")
for input_file, temp_file in zip(input_file_list, temp_file_list):
    obtain_coordinates(input_file, temp_file)
print("Todos los archivos han sido procesados.")