install.packages("haven")
install.packages("sf")
install.packages("ggplot2")
install.packages("dplyr")

# Cargar librerías
library(haven)   # leer archivos .dta
library(dplyr)   # manipulación de datos
library(ggplot2) # gráficos
library(sf)        # Para manejar datos geoespaciales

# --- Cargar datos ---

# Cambiar al directorio deseado
setwd("~/Desktop/1 economia/7/econometría avanzada/proyecto_econometria_avanzada")

oxxos <- read_dta("data/negocios/bogota_y_alrededores/oxxos.dta")

# --- Preparar variables ---
oxxos <- oxxos %>%
  mutate(
    fecha_matricula = as.numeric(substr(fechadematrícula, 1, 4)),
    ultimo_ano = últimoañorenovado
  ) %>%
  select(fecha_matricula, ultimo_ano)

# --- Definir rango de años ---
inicio <- 2009
fin <- 2025
anos <- inicio:fin

# --- Contar Oxxos activos por año ---
conteo_oxxos <- sapply(anos, function(y) {
  sum(oxxos$fecha_matricula <= y & oxxos$ultimo_ano >= y, na.rm = TRUE)
})

# --- Crear data frame para graficar ---
df_plot <- data.frame(
  ano = anos,
  conteo = conteo_oxxos
)

ggplot(df_plot, aes(x = ano, y = conteo)) +
  geom_line(color = "black", size = 1.2) +       # línea lila
  geom_point(color = "purple", size = 2) +        # círculos en cada año
  labs(
    title = "Cantidad de Oxxos por año",
    x = "Año",
    y = "Cantidad de Oxxos"
  ) +
  theme_minimal()

ggsave("data/controles_results/oxxos_por_ano.png", width = 8, height = 5)



#-----Mapa de Oxxos en Bogotá-----

plot_oxxo_map <- function(year) {
  # Leer layer correspondiente al año
  gdf <- st_read("data/maps_data/joined_all_years.gpkg",
                 layer = paste0("joined_", year))
  
  # Quitar ZAT 796 y 798 porque nunca son tratado y la verdad no se ve nada
  gdf <- gdf %>%
    filter(!ZAT %in% c(796, 798))
  
  # Crear columna para presencia/ausencia de Oxxo
  gdf <- gdf %>%
    mutate(presencia_oxxo = ifelse(cantidad_oxxo > 0, 1, 0))
  
  # Graficar mapa coroplético
  ggplot(gdf) +
    geom_sf(aes(fill = cantidad_oxxo), color = "white") + # polígonos con borde blanco
    scale_fill_gradient(low = "lavender", high = "purple", 
                        na.value = "grey90", name = "Cantidad Oxxo") +
    labs(title = paste("Presencia de Oxxos por ZAT en", year)) +
    theme_minimal()
}

plot_oxxo_map <- function(year) {
  # Leer layer correspondiente al año
  gdf <- st_read("data/maps_data/joined_all_years.gpkg",
                 layer = paste0("joined_", year))
  
  # Quitar ZAT 796 y 798 (zonas rurales o reservas)
  gdf <- gdf %>%
    filter(!ZAT %in% c(796, 798))
  
  # Crear columna para presencia/ausencia de Oxxo
  gdf <- gdf %>%
    mutate(presencia_oxxo = ifelse(cantidad_oxxo > 0, 1, 0))
  
  # Graficar mapa coroplético
  ggplot(gdf) +
    geom_sf(aes(fill = cantidad_oxxo), color = "white") +
    scale_fill_gradient(
      low = "lavender", high = "purple", 
      na.value = "grey90", 
      name = "Cantidad Oxxo"
    ) +
    guides(fill = guide_colorbar(barwidth = 15, barheight = 1)) +
    labs(title = paste("Presencia de Oxxos en", year)) +
    theme_void() +
    theme(
      legend.position = "bottom",
      plot.title = element_text(hjust = 0.5)
    )
}

#"Se quitaron ZAT 796 y 798 (zonas rurales o reservas naturales)

anos <- c(2011, 2015, 2019,2023)

# Mapas por año
for (y in anos) {
  print(plot_oxxo_map(y))
  ggsave(paste0("data/controles_results/mapa_oxxos_", y, ".png"), width = 8, height = 6)
}


plot_dep_map <- function(year) {
  # Leer layer correspondiente al año
  gdf <- st_read("data/maps_data/joined_all_years.gpkg",
                 layer = paste0("joined_", year))
  
  # Quitar ZAT 796 y 798 porque nunca son tratados
  gdf <- gdf %>%
    filter(!ZAT %in% c(796, 798))
  
  # Graficar mapa coroplético
  ggplot(gdf) +
    geom_sf(aes(fill = prop_independiente_total), color = "white") +
    scale_fill_gradient(
      low = "lavender", high = "purple", 
      na.value = "grey90", 
      name = "Proporción trabajadores independientes"
    ) +
    guides(fill = guide_colorbar(barwidth = 15, barheight = 1)) +
    labs(title = paste("Proporción de independientes por ZAT en", year)) +
    theme_void() +
    theme(
      legend.position = "bottom",
      plot.title = element_text(hjust = 0.5)
    )
}

for (y in anos) {
  print(plot_dep_map(y))
  ggsave(paste0("data/controles_results/mapa_dep_", y, ".png"), width = 8, height = 6)
}



plot_oxxo_binary_map <- function(year) {
  # Leer layer correspondiente al año
  gdf <- st_read("data/maps_data/joined_all_years.gpkg",
                 layer = paste0("joined_", year))
  
  # Quitar ZAT 796 y 798 (zonas rurales o reservas)
  gdf <- gdf %>%
    filter(!ZAT %in% c(796, 798))
  
  # Crear columna para presencia/ausencia de Oxxo
  gdf <- gdf %>%
    mutate(presencia_oxxo = ifelse(cantidad_oxxo > 0, 1, 0))
  
  # Graficar mapa binario
  ggplot(gdf) +
    geom_sf(aes(fill = factor(presencia_oxxo)), color = "white") +
    scale_fill_manual(
      values = c("0" = "grey90", "1" = "purple"),
      labels = c("No tratados", "Tratados por oxxo"),
      name = "Oxxo"
    ) +
    labs(title = paste("Presencia de Oxxos en", year)) +
    theme_void() +
    theme(
      legend.position = "bottom",
      plot.title = element_text(hjust = 0.5)
    )
}

# Ejemplo: generar mapa binario para 2015
for (y in anos) {
  print(plot_oxxo_binary_map(y))
  ggsave(paste0("data/controles_results/mapa_oxxos_binary_", y, ".png"), width = 8, height = 6)
}





