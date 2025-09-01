#vamos a usar geopandas para unir absolutamente todos 
import geopandas as gpd
import pandas as pd
import itertools

# shapefile de ZAT
zat_gdf = gpd.read_file("../../data/buffer_data/zat/ZAT.shp")

#ver los datos del shapefile y ase obtener el geometry y el nombre del id del zat
print(zat_gdf.columns)

# Leer los .dta de información socioeconómica para cada año
data_files = {2011: "../../data/buffer_data/collapsed_2011.dta", 2019: "../../data/buffer_data/collapsed_2019.dta", 2023: "../../data/buffer_data/collapsed_2023.dta"}

# Nombres que queremos uniformes: 'zat', 'mujer', 'edad', 'nivel_educativo', 'formal', 'informal'
rename_map = {
    2011: {'zat_destino':'ZAT', 'mujer':'mujer', 'edad':'edad', 'educacion':'nivel_educativo', 'formal':'formal', 'informal':'informal'},
    2019: {'zat_destino':'ZAT', 'Mujer':'mujer', 'edad':'edad', 'nivel_educativo':'nivel_educativo', 'formal':'formal', 'informal':'informal'},
    2023: {'zat_des':'ZAT', 'Mujer':'mujer', 'edad':'edad', 'max_nivel_edu_num':'nivel_educativo', 'formal':'formal', 'informal':'informal'}
}


zat_data_list = []

#crear lista de datos por año o sea concatenar todo
for year, file in data_files.items():
    df = pd.read_stata(file)
    df = df.rename(columns=rename_map[year])  # renombrar columnas
    df['year'] = year
    zat_data_list.append(df[['ZAT','mujer','edad','nivel_educativo','formal','informal','year']])

# Concatenar todos los años
zat_data_seconomic = pd.concat(zat_data_list, ignore_index=True)

# Lista de archivos por cadena
tiendas_files = {
    'oxxo': '../../data/negocios/bogota_y_alrededores/oxxos.dta',
    'ara': '../../data/negocios/bogota_y_alrededores/tienda_ara.dta',
    'd1': '../../data/negocios/bogota_y_alrededores/D1.dta',
    'jb': '../../data/negocios/bogota_y_alrededores/justo_y_bueno.dta'
}

# Leer todos y concatenar
tienda_list = []

#crear un df con todas las cadenas en un sol lugar
for cadena, file in tiendas_files.items():
    df = pd.read_stata(file)
    df['cadena'] = cadena
    df['geometry'] = gpd.points_from_xy(df.longitud, df.latitud)
    gdf = gpd.GeoDataFrame(df, geometry='geometry', crs="EPSG:4326")
    tienda_list.append(gdf)

tienda_gdf = pd.concat(tienda_list, ignore_index=True)

print(tienda_gdf.columns)

tienda_gdf = tienda_gdf.to_crs(epsg=3116)
zat_gdf = zat_gdf.to_crs(epsg=3116)

# Convertir fecha de matrícula
tienda_gdf['fechadematrícula'] = pd.to_datetime(
    tienda_gdf['fechadematrícula'], format='%Y/%m/%d', errors='coerce'
)


años = [2011, 2019, 2023]
oxxo_counts_list = []
joined_list = []  # Aquí guardaremos cada joined

#crear el panel inical sin la parte socioeconomica
for year in años:
    # Copiar todo el GeoDataFrame de ZAT y agregar año
    zat_year = zat_gdf[['ZAT','geometry']].copy()
    zat_year['year'] = year
    
    # Filtrar tiendas vigentes en ese año
    tiendas_year = tienda_gdf[
        (tienda_gdf['fechadematrícula'].dt.year <= year) &
        (tienda_gdf['últimoañorenovado'] >= year)
    ]
    
    # Spatial join: ahora left_df sigue siendo GeoDataFrame
    joined = gpd.sjoin(
        zat_year,              # polígonos con geometría
        tiendas_year,          # puntos
        how="left",
        predicate="contains"
    )

    joined_list.append(joined)

    # Contar tiendas por ZAT y cadena
    counts = joined.groupby(['ZAT','cadena']).size().unstack(fill_value=0).reset_index()
    
    # Merge con todos los ZAT (para asegurarnos de que los que no tengan tiendas aparezcan)
    counts = zat_year[['ZAT','year']].merge(counts, on='ZAT', how='left').fillna(0)
    
    # Crear columnas de cantidad y dummy
    for cadena in ['oxxo','ara','d1','jb']:
        counts[f'cantidad_{cadena}'] = counts.get(cadena, 0)
        counts[f'dummy_{cadena}'] = (counts[f'cantidad_{cadena}'] > 0).astype(int)
    
    # Eliminar columnas originales de cadena
    counts = counts.drop(columns=[c for c in ['oxxo','ara','d1','jb'] if c in counts.columns])
    
    oxxo_counts_list.append(counts)

# Concatenar todos los años
tiendas_counts = pd.concat(oxxo_counts_list, ignore_index=True)

# Guardar
tiendas_counts.to_csv("../../data/buffer_data/oxxo_counts.csv", index=False)
print(tiendas_counts)

#finalmente hacer el merge con zat_data_list
#zat_data en este es segun zat y year 
# oxxo_counts es en ZAT y year

# Asegurarse de que las columnas de ZAT y year tengan mismo tipo
zat_data_seconomic['ZAT'] = zat_data_seconomic['ZAT'].fillna(-1).astype(int)
zat_data_seconomic['year'] = zat_data_seconomic['year'].astype(int)

tiendas_counts['ZAT'] = tiendas_counts['ZAT'].astype(int)
tiendas_counts['year'] = tiendas_counts['year'].astype(int)

# Merge: todos los ZAT x year de oxxo_counts, si no hay info socioeconómica queda NaN
panel = pd.merge(
    tiendas_counts,
    zat_data_seconomic,
    on=['ZAT', 'year'],
    how='left'  # mantener todos los ZAT con tiendas (o sin, si ya estaban en oxxo_counts)
)

# Guardar el panel final
panel.to_csv("../../data/buffer_data/panel_final.csv", index=False)
print(panel.head())

#crear datos para mapas para ver todo por ano
#joined_all_years = pd.concat(joined_list, ignore_index=True)

# Guardar a CSV (solo columnas no geométricas) o a GeoPackage para mantener geometría
#joined_all_years.to_csv("../../data/maps_data/joined_all_years.csv", index=False)
# o
#joined_all_years.to_file("../../data/maps_data/joined_all_years.gpkg", layer='joined', driver="GPKG")


# Ruta del GeoPackage
gpkg_path = "../../data/maps_data/joined_all_years.gpkg"

# Guardar cada año como capa separada
for year, gdf in zip(años, joined_list):
    gdf.to_file(gpkg_path, layer=f"joined_{year}", driver="GPKG")
    
""" 
#ahora dibujar el mapa
import matplotlib.pyplot as plt
import os

años = [2011, 2019, 2023]
output_dir = "../../data/maps_data/"

# Crear carpeta si no existe
os.makedirs(output_dir, exist_ok=True)

for i, year in enumerate(años):
    joined = joined_list[i]
    
    fig, ax = plt.subplots(figsize=(10,10))
    
    # Dibujar polígonos de ZAT en morado/lila
    joined.plot(ax=ax, color="#CFA0E9", edgecolor="black")  # #CFA0E9 es lila
    
    # Dibujar puntos de tiendas en rojo
    tiendas = joined[joined['nombre'].notnull()]
    tiendas.plot(ax=ax, color="red", markersize=20, label="Tiendas")
    
    ax.set_title(f"ZAT con tiendas activas en {year}", fontsize=16)
    ax.legend()
    plt.axis('off')
    
    # Guardar el mapa
    output_path = os.path.join(output_dir, f"map_zat_tiendas_{year}.png")
    plt.savefig(output_path, bbox_inches="tight", dpi=300)
    plt.close(fig)

print("Mapas guardados en", output_dir)
"""  


