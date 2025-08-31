import pandas as pd
import geopandas as gpd
from ohsome import OhsomeClient
import requests

# Cliente ohsome
client = OhsomeClient()

# Función para obtener dirección desde coordenadas (reverse geocoding con Nominatim)
def get_address(lat, lon):
    url = "https://nominatim.openstreetmap.org/reverse"
    params = {
        "lat": lat,
        "lon": lon,
        "format": "json",
        "addressdetails": 1
    }
    headers = {"User-Agent": "justoybueno-hist"}
    try:
        r = requests.get(url, params=params, headers=headers, timeout=10)
        data = r.json()
        return data.get("display_name", "")
    except:
        return ""

# Ruta del archivo
file_path = "data/negocios/justo_y_bueno_OMS.csv"

# Leemos el CSV
df = pd.read_csv(file_path)

# Aseguramos las columnas nuevas
df["latitud"] = None
df["longitud"] = None
df["direccion"] = None

# Bounding box de Colombia aprox
bbox_colombia = [[-79, -4, -66, 13]]

for i, row in df.iterrows():
    query_name = row["Nombre"]
    year = int(row["Último año renovado"])

    print(f"Procesando {i+1}/{len(df)}: {query_name} ({year})")
    
    filtro = f'name="{query_name}" and shop=*'
    fecha = f"{year-1}-01-01"

    try:
        resp = client.elements.geometry.post(
            bboxes=bbox_colombia,
            filter=filtro,
            time=fecha
        )

        features = resp.as_dict().get("features", [])
        if len(features) > 0:
            gdf = gpd.GeoDataFrame.from_features(features, crs="EPSG:4326")
            lat = gdf.geometry.y.iloc[0]
            lon = gdf.geometry.x.iloc[0]

            direccion = get_address(lat, lon)

            df.at[i, "latitud"] = lat
            df.at[i, "longitud"] = lon
            df.at[i, "direccion"] = direccion

            print(f"{query_name} ({year}) -> {lat}, {lon} | {direccion[:50]}...")
        else:
            print(f"{query_name} ({year}) no encontrado en OSM")
    except Exception as e:
        print(f"Error con {query_name}: {e}")

# Sobrescribimos el mismo archivo
df.to_csv(file_path, index=False, encoding="utf-8")
print("✅ Proceso terminado. Se sobrescribió el archivo con lat/lon/dirección.")

