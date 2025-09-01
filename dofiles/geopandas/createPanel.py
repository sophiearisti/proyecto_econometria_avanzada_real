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
    2011: {'zat_destino':'zat', 'mujer':'mujer', 'edad':'edad', 'educacion':'nivel_educativo', 'formal':'formal', 'informal':'informal'},
    2019: {'zat_destino':'zat', 'Mujer':'mujer', 'edad':'edad', 'nivel_educativo':'nivel_educativo', 'formal':'formal', 'informal':'informal'},
    2023: {'zat_des':'zat', 'Mujer':'mujer', 'edad':'edad', 'max_nivel_edu_num':'nivel_educativo', 'formal':'formal', 'informal':'informal'}
}


zat_data_list = []

#crear lista de datos por año o sea concatenar todo
for year, file in data_files.items():
    df = pd.read_stata(file)
    df = df.rename(columns=rename_map[year])  # renombrar columnas
    df['year'] = year
    zat_data_list.append(df[['zat','mujer','edad','nivel_educativo','formal','informal','year']])

# Concatenar todos los años
zat_data = pd.concat(zat_data_list, ignore_index=True)


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

# Realizar la unión espacial
joined = gpd.sjoin(
    tienda_gdf,                    # GeoDataFrame con los puntos (tiendas)
    zat_gdf[['ZAT','geometry']],  # GeoDataFrame con los polígonos (ZAT) y su id
    how="left",                   # Mantener todas las filas de oxxo_gdf
    predicate="within"             # Pregunta: ¿el punto está dentro del polígono?
)

# Convertir a datetime
joined['fechadematrícula'] = pd.to_datetime(joined['fechadematrícula'], format='%Y/%m/%d', errors='coerce')

años = [2011, 2019, 2023]
oxxo_counts_list = []

#crear el panel inical sin la parte socioeconomica
for year in años:
    #fecha de matricula debe ser menor o igual al ano en ecuestion
    #Y últimoañorenovado debe ser igual o mayor al ano en cuestion
    #los dos se deben cumplir
    # Filtrar tiendas que cumplen ambas condiciones
    tienda_year = joined[
                    (joined['fechadematrícula'].dt.year <= year) & 
                    (joined['últimoañorenovado'] >= year)
                ]

    # Contar total y por cadena
    counts = tienda_year.groupby(['ZAT','cadena']).size().unstack(fill_value=0).reset_index()
    counts['year'] = year
    
    # Crear dummies
    for cadena in ['oxxo','ara','d1','jb']:
        counts[f'cantidad_{cadena}'] = counts.get(cadena, 0)
        counts[f'dummy_{cadena}'] = (counts.get(cadena,0) > 0)
    
    counts = counts.drop(columns=[c for c in ['oxxo','ara','d1','jb'] if c in counts.columns])
        
    
    oxxo_counts_list.append(counts)

oxxo_counts = pd.concat(oxxo_counts_list, ignore_index=True)

oxxo_counts.to_csv("../../data/buffer_data/oxxo_counts_disc.csv", index=False)

print(oxxo_counts)


