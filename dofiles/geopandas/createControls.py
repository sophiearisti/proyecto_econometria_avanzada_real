import geopandas as gpd
import pandas as pd
from unidecode import unidecode
from shapely.geometry import Point

####################################################
# Primer paso:
# Crear controles geográficos: unir UPZ con Localidad y luego unir ZAT con Localidad-UPZ
#lo bueno es que la upz encaja exactamente en una localidad
# y el zat encaja exactamente en una upz
# Así que no hay ambigüedad en las uniones espaciales
####################################################

# --- 1. Cargar shapefiles ---
zat_gdf = gpd.read_file("../../data/buffer_data/zat/ZAT.shp")
localidad_gdf = gpd.read_file("../../data/buffer_data/localidades/poligonos-localidades.shp")
upz_gdf = gpd.read_file("../../data/buffer_data/upz-bogota/upz-bogota.shp")

# --- 2. Asegurar mismo CRS ---
zat_gdf = zat_gdf.to_crs(localidad_gdf.crs)
upz_gdf = upz_gdf.to_crs(localidad_gdf.crs)

# --- 3. UPZ ↔ Localidad ---
intersections = gpd.overlay(upz_gdf, localidad_gdf, how="intersection")
intersections["area_intersection"] = intersections.geometry.area
idx = intersections.groupby("codigo_upz")["area_intersection"].idxmax()

gdf_upz_loc = intersections.loc[idx, [
    "codigo_upz", "nombre", "Identificad", "Nombre_de_l", "geometry"
]].rename(columns={
    "nombre": "nombre_upz",
    "Identificad": "codigo_localidad",
    "Nombre_de_l": "nombre_localidad"
})
gdf_upz_loc["geometry_upz"] = gdf_upz_loc.geometry

# --- 4. ZAT ↔ UPZ ---
intersections2 = gpd.overlay(zat_gdf, gdf_upz_loc, how="intersection")
intersections2["area_intersection"] = intersections2.geometry.area

idx2 = intersections2.groupby("ZAT")["area_intersection"].idxmax()
gdf_zat_upz = intersections2.loc[idx2, [
    "ZAT", "codigo_upz", "nombre_upz", "codigo_localidad", "nombre_localidad", "geometry"
]]

# Guardar geometría original de ZAT y UPZ
gdf_zat_upz = gdf_zat_upz.merge(
    zat_gdf[["ZAT", "geometry"]],
    on="ZAT",
    how="left",
    suffixes=("", "_zat")
)

gdf_zat_upz = gdf_zat_upz.merge(
    gdf_upz_loc[["codigo_upz", "geometry_upz"]],
    on="codigo_upz",
    how="left"
)

# --- 5. Left join con TODOS los ZAT ---
# Nos quedamos solo con ZAT 
zat_ids = zat_gdf[["ZAT"]]

# Hacemos el merge, ahora solo ZAT + atributos de gdf_zat_upz
gdf_zat_upz_localidad = zat_ids.merge(
    gdf_zat_upz, 
    on="ZAT",
    how="left"
)

#esto es porque hay algunos zats que no pertenecen a ninguna upz

# --- 6. Exportar solo atributos ---
# esto puede servir para cualquier análisis posterior
# o para otra investigacion sobre bogota
#gdf_zat_upz_localidad.drop(columns=["geometry", "geometry_zat", "geometry_upz"]) \
#    .to_csv("../../data/buffer_data/zat_upz_localidad.csv", index=False)
    
# ver cuantos ZATS no tienen upz
#hay 222 zats sin upz, que son zonas fuera de bogota

# --- 7. Dejar solo el geometry de ZAT, si se va a ahcer el analisis con UPZ, el que se deja es ese ---
# gdf_zat_upz_localidad ya debe existir con columna 'geometry' y 'ZAT'

print(gdf_zat_upz_localidad.columns)
gdf_zat_upz_localidad = gdf_zat_upz_localidad.set_geometry('geometry_zat')

gdf_zat_upz_localidad = gdf_zat_upz_localidad.drop(columns=['geometry', 'geometry_upz'])


"""
####################################################
# Segundo paso:
# Obtener el estrato promedio por ZAT
####################################################

estrato_gdf = gpd.read_file("../../data/buffer_data/estratos_por_manzana/ManzanaEstratificacion.shp")

estrato_gdf = estrato_gdf.to_crs(localidad_gdf.crs)

# imprimir columnas
print(estrato_gdf.columns)

# Valores únicos de la columna ESTRATO
print("Valores únicos en ESTRATO:")
print(estrato_gdf["ESTRATO"].unique())

# --- 1. Spatial join manzanas ↔ ZAT ---
intersections = gpd.overlay(estrato_gdf, zat_gdf, how="intersection")

# Calcular área de intersección
intersections["area_intersection"] = intersections.geometry.area

# --- 2. Para cada manzana, quedarse con el ZAT de mayor superposición ---
idx = intersections.groupby("CODIGO_MAN")["area_intersection"].idxmax()
manzana_zat = intersections.loc[idx, ["CODIGO_MAN", "ESTRATO", "ZAT"]]

# --- 3. Agrupar por ZAT y calcular promedio de estrato ---
def estrato_mean_custom(values):
    # Si todas las manzanas tienen estrato 0 → devolver 0
    if (values == 0).all():
        return None
    # Si hay mezcla, ignorar ceros y calcular promedio con los demás
    mean_val = values[values != 0].mean()
    return round(mean_val, 2)  # <-- redondear a 2 decimales

estrato_por_zat = (
    manzana_zat.groupby("ZAT")["ESTRATO"]
    .agg(estrato_mean_custom)
    .reset_index()
    .rename(columns={"ESTRATO": "estrato_mean"})
)


# --- 5. Dejamos tambien los zats que no tienen estrato---

# Hacemos el merge, ahora solo ZAT + atributos de estrato_por_zat
gdf_final_estrato = zat_gdf[["ZAT", "geometry"]].merge(
    estrato_por_zat, 
    on="ZAT",
    how="left"
)

# --- 6. Revisar resultado ---
print(gdf_final_estrato.head())
print("Número de ZAT con estrato promedio calculado:", len(gdf_final_estrato))

# --- 7. Exportar a CSV ---
gdf_final_estrato.drop(columns=["geometry"]).to_csv("../../data/buffer_data/estrato_mean_por_zat.csv", index=False)


####################################################
# Tercer paso:
# Obtener los baseline covariates antes de la llegada de OXXO
####################################################

####################################################
# POBLACION TOTAL POR UPZ
# unir poblacion 2005 y 2009 por upz
####################################################

# --- 1. Leer CSV 2005 ---
poblacion_2005 = pd.read_csv(
    "../../data/buffer_data/poblacion_por_upz_2005.csv",
    sep=';', 
    engine='python'
)

# Renombrar columnas
poblacion_2005.columns = ['id_upz', 'poblacion_2005']

# --- 2. Leer CSV 2009 ---
poblacion_2009 = pd.read_csv(
    "../../data/buffer_data/poblacion-por_upz_2009.csv",
    sep=';',
    engine='python'
)

# Limpiar nombres de columnas
poblacion_2009.columns = [
    unidecode(c.replace('"','').replace(' ','_').lower()) 
    for c in poblacion_2009.columns
]
# Renombrar columnas específicas agregando sufijo _2009
cols_to_rename = ['area_urbana', 'poblacion_urbana', 'densidad_urbana']
rename_dict = {c: c + '_2009' for c in cols_to_rename}
poblacion_2009 = poblacion_2009.rename(columns=rename_dict)

# Renombrar código UPZ para merge
poblacion_2009 = poblacion_2009.rename(columns={'codigo_upz':'id_upz'})

# Asegurar tipo int en id_upz
poblacion_2009['id_upz'] = poblacion_2009['id_upz'].astype(int)

# --- 3. Merge con población 2005 ---
poblacion_2009_2005 = pd.merge(
    poblacion_2005,
    poblacion_2009,
    on='id_upz',
    how='outer'  # conserva todas las UPZ
)

####################################################
# El siguiente csv tiene esta informacion
# TAMANO PROMEDIO DE HOGARES POR LOCALIDAD 2007 :')
# indice calidad de vida POR LOCALIDAD 2007 :')
# se unira por localidad
####################################################

baselines = pd.read_csv(
    "../../data/buffer_data/baselines_2007_localidad.csv",
    sep=';',
    engine='python'
)

print(baselines.head())
print(baselines.columns)

# --- 2. Merge con baselines 2007 ---
merge_baselines = pd.merge(
    poblacion_2009_2005,
    baselines,
    on='codigo_localidad',
    how='left'  # conserva todas las UPZ
)

# --- 4. Guardar resultado final ---
merge_baselines.to_csv(
    "../../data/buffer_data/poblacion_baselines_merge.csv",
    index=False,
    sep=';',
    encoding='utf-8'
)
"""

####################################################
# Cuarto paso:
# controles miscelaneos que pueden afectar d o y 
####################################################

####################################################
# control de acceso a transporte publico (transmilenio)
# por zat
####################################################

# coger cada estacion de transmilenio
# ver en cada delimitacion si a menos de 800 metros colinda o esta dentro de un zat
# poner variable dummy de acceso a transmilenio por zat
# poner la cantidad de estaciones de transmilenio dentro o colindando con el zat
# usar gdf_zat_upz_localidad

# --- Parámetros ---
buffer = 800  # metros
crs_metros = "EPSG:3116"  # CRS proyectado para Bogotá

# --- 1. Cargar shapefile de estaciones TransMilenio ---
datos_transmi = gpd.read_file(
    "../../data/buffer_data/estaciones transmilenio/Estaciones_Troncales_de_TRANSMILENIO.shp"
)

# --- 2. Proyectar a CRS en metros ---
datos_transmi = datos_transmi.to_crs(crs_metros)

# --- 3. Crear buffer de 400 metros alrededor de cada estación ---
datos_transmi['geometry_buffer'] = datos_transmi.geometry.buffer(buffer)

# --- 4. Preparar GeoDataFrame con buffer como geometría activa ---
datos_transmi_buffer = datos_transmi.set_geometry('geometry_buffer')

# --- 5. Seleccionar columnas necesarias para overlay ---
transmi_gdf_sel = datos_transmi_buffer[['num_est', 'geometry_buffer']].copy()
transmi_gdf_sel = transmi_gdf_sel.set_geometry('geometry_buffer')

# --- 6. Reproyectar ambos a CRS en metros ---
zat_gdf_sel = gdf_zat_upz_localidad.to_crs(crs_metros)
transmi_gdf_sel = transmi_gdf_sel.to_crs(crs_metros)

# --- 7. Overlay/intersección ---
intersections = gpd.overlay(
    zat_gdf_sel,
    transmi_gdf_sel,
    how='intersection',
    keep_geom_type=False  # conserva todos los tipos de geometría
)

# --- 8. Crear variable de área de intersección (opcional) ---
intersections["area_intersection"] = intersections.geometry.area

# --- 9. Contar estaciones por ZAT ---
stations_per_zat = intersections.groupby('ZAT')['num_est'].nunique().reset_index()
stations_per_zat = stations_per_zat.rename(columns={'num_est': 'num_est_transmi'})

# --- 10. Unir al GeoDataFrame de ZAT original ---
gdf_zat_upz_localidad = gdf_zat_upz_localidad.merge(
    stations_per_zat,
    on='ZAT',
    how='left'
)

# --- 11. Crear variable dummy de acceso a TransMilenio ---
# rellenar NaN por 0 (ZAT sin estaciones cerca)
gdf_zat_upz_localidad['num_est_transmi'] = gdf_zat_upz_localidad['num_est_transmi'].fillna(0)
gdf_zat_upz_localidad['acceso_transmi'] = (gdf_zat_upz_localidad['num_est_transmi'] > 0).astype(int)


# --- 12. Revisar resultado ---
print(gdf_zat_upz_localidad[['ZAT', 'num_est_transmi', 'acceso_transmi']].head())

# --- 13. Guardar resultado ---
gdf_zat_upz_localidad.drop(columns=["geometry_zat"]).to_csv(
    "../../data/buffer_data/zat_transmi_access.csv",
    index=False
)

####################################################
# control de acceso vias arteriales
# por zat
####################################################

#ver cuantas vias arteriales hay dentro o colindando con el zat
# lo haremos como exposicion por kilometros de via arterial
# entonces se usa el largo en metros de la via arterial dentro o colindando con el zat

datos_arterias = gpd.read_file(
    "../../data/buffer_data/vias principales/RedInfraestructuraVialArterial.shp"
)

print(datos_arterias.columns)
#solo ver datos de codigo, 'Shape_Leng', 'Shape_Area', 'geometry'
print(datos_arterias[['Shape_Leng', 'Shape_Area', 'geometry']].head())



####################################################
# Quinto paso:
# unir absolutamente todo 
####################################################




