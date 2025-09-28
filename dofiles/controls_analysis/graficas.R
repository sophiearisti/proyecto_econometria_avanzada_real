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


#este es para la intensidad del tratamiento

panelForIntensity <- read_dta("data/controles_results/paraR.dta")

# Ver las primeras filas
head(panelForIntensity)

# Ver nombres de columnas
names(panelForIntensity)

# 1. Año de primera entrada de OXXO por ZAT
panelForIntensity <- panelForIntensity %>%
  group_by(zat) %>%
  mutate(first_treat = if (any(dummy_oxxo == 1)) min(year[dummy_oxxo == 1]) else NA_real_) %>%
  ungroup()

panelForIntensity <- panelForIntensity %>% filter(!is.na(first_treat))

panelForIntensity <- panelForIntensity %>% mutate(rel_time = (year - first_treat) / 4)


panelForIntensity_summary <- panelForIntensity %>%
  group_by(first_treat, rel_time) %>%
  summarise(
    cantidad_oxxo = mean(cantidad_oxxo, na.rm = TRUE),
    dummy_jb = mean(dummy_jb, na.rm = TRUE),
    dummy_d1 = mean(dummy_d1, na.rm = TRUE),
    dummy_ara = mean(dummy_ara, na.rm = TRUE),
    cantidad_jb = mean(cantidad_jb, na.rm = TRUE),
    cantidad_d1 = mean(cantidad_d1, na.rm = TRUE),
    cantidad_ara = mean(cantidad_ara, na.rm = TRUE)
  ) %>%
  ungroup()

# 5. Graficar cada cohorte
p <- ggplot(panelForIntensity_summary, 
       aes(x = rel_time, y = cantidad_oxxo,
           color = as.factor(first_treat),
           shape = as.factor(first_treat))) +   # <- aquí asignamos la forma
  geom_line(size = 1) +
  geom_point(size = 3) +                   # <- puntos visibles con forma
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_x_continuous(breaks = min(panelForIntensity_summary$rel_time):
                       max(panelForIntensity_summary$rel_time)) +
  labs(
    x = "Tiempo relativo (años/4)",
    y = "Promedio cantidad de OXXOs en ZAT",
    color = "Cohorte",
    shape = "Cohorte"
  ) +
  theme_minimal(base_size = 14) +
  scale_color_manual(values = c(
    "2011" = "#D7BDE2",  # lila claro
    "2015" = "#A569BD",  # morado medio
    "2019" = "#F5B7B1",  # rosa suave
    "2023" = "#7D3C98"   # morado intenso
  )) +
  scale_shape_manual(values = c(16,17,8,18))  # círculo, triángulo, estrella, diamante

# Guardar el gráfico
ggsave(filename = "data/controles_results/oxxos_intensidad_tratamiento.png",
       plot = p,
       width = 8, height = 6, dpi = 300)
#title = "Evolución relativa de cantidad de OXXOs por cohorte",
