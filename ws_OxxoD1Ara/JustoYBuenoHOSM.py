import pandas as pd
import geopandas as gpd
from ohsome import OhsomeClient
import time

# Cliente
client = OhsomeClient()

# Leemos el csv original
df = pd.read_csv("../data/negocios/justo_y_bueno_OMS.csv")

# Asegurar columnas nuevas
df["latitud"] = None
df["longitud"] = None
df["direccion"] = None

# Sacamos los años únicos
years = sorted(df["Último año renovado"].dropna().unique())
print(f"Años únicos en el dataset: {years}")

# Bounding box Colombia
bbox_colombia = [[-79, -4, -66, 13]]

# Cache para no repetir consultas
year_data = {}

for year in years:
    fecha = f"{int(year)-1}-12-31"  # hasta diciembre del año anterior
    print(f"\n🔎 Descargando shops de Colombia para {fecha}...")
    try:
        resp = client.elements.geometry.post(
            bboxes=bbox_colombia,
            filter="shop=*",
            time=fecha
        )
        features = resp.as_dict().get("features", [])
        gdf = gpd.GeoDataFrame.from_features(features, crs="EPSG:4326")
        year_data[year] = gdf
        print(f"   → {len(gdf)} elementos encontrados")
    except Exception as e:
        print(f"Error descargando {year}: {e}")
    time.sleep(1)  # pequeña pausa entre años

# Ahora hacemos el match nombre por nombre
for i, row in df.iterrows():
    nombre = str(row["Nombre"]).strip()
    year = row["Último año renovado"]

    if year not in year_data:
        continue

    gdf_year = year_data[year]

    # buscamos coincidencia exacta en el tag name
    candidatos = gdf_year[gdf_year["tags"].apply(lambda d: d.get("name") == nombre if isinstance(d, dict) else False)]

    if not candidatos.empty:
        lat = candidatos.geometry.y.iloc[0]
        lon = candidatos.geometry.x.iloc[0]
        df.at[i, "latitud"] = lat
        df.at[i, "longitud"] = lon
        # dirección aproximada = concatenar tags de ciudad/barrio si existen
        direccion = candidatos["tags"].iloc[0].get("addr:city", "") + " " + candidatos["tags"].iloc[0].get("addr:street", "")
        df.at[i, "direccion"] = direccion.strip()
        print(f"✔ {nombre} ({year}) -> {lat}, {lon}")
    else:
        print(f"✘ {nombre} ({year}) no encontrado")

# Guardamos el CSV sobrescribiendo
output_file = "data/negocios/justo_y_bueno_OSM.csv"
df.to_csv(output_file, index=False, encoding="utf-8")
print(f"\n✅ CSV enriquecido guardado en {output_file}")
