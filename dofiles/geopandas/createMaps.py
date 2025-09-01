import folium
import geopandas as gpd

# Colores por cadena
colores_cadena = {
    'oxxo': 'red',
    'd1': 'blue',
    'jb': 'black',
    'ara': 'orange'
}

años = [2011, 2019, 2023]

for year in años:
    # Cargar la capa correspondiente a cada año
    gdf = gpd.read_file(
        "../../data/maps_data/joined_all_years.gpkg",
        layer=f"joined_{year}"
    )

    # Crear mapa centrado en Bogotá
    m = folium.Map(location=[4.6, -74.1], zoom_start=11)

    # Dibujar polígonos ZAT
    folium.GeoJson(
        gdf[['geometry','ZAT']],
        style_function=lambda x: {
            'fillColor':'purple',
            'color':'black',
            'weight':1,
            'fillOpacity':0.4
        }
    ).add_to(m)

    # Dibujar puntos de las tiendas según su cadena
    tiendas = gdf[~gdf['index_right'].isna()]
    for _, row in tiendas.iterrows():
        cadena = row['cadena'].lower()  # asegurar minúsculas
        color = colores_cadena.get(cadena, 'gray')  # default gris si no está
        folium.CircleMarker(
            location=[row['latitud'], row['longitud']],
            radius=3,
            color=color,
            fill=True,
            fill_color=color,
            fill_opacity=0.7,
            popup=row['cadena']
        ).add_to(m)

    # Guardar HTML por año
    m.save(f"../../data/maps_data/map_{year}.html")
