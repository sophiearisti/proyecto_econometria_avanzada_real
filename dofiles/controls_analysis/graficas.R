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



#esta grafica será para hacer el event study bonito con colores lindos en diferentes tinalidades de morado
#es un csv

event_study_data <- read.csv("data/controles_results/paraEventsStudyControls.csv")

head(event_study_data)

# valor del estimador
dd_val <- 0.00784

# calcular rango y marcas para el eje y, e incluir dd_val
ymin_data <- min(event_study_data$prop_independiente_total1 - 1.96*event_study_data$prop_independiente_total0, na.rm = TRUE)
ymax_data <- max(event_study_data$prop_independiente_total1 + 1.96*event_study_data$prop_independiente_total0, na.rm = TRUE)

# usar pretty() para crear marcas automáticas y asegurar que dd_val esté incluido
y_breaks <- pretty(c(ymin_data, ymax_data), n = 5)
y_breaks <- sort(unique(c(y_breaks, dd_val)))

# formato de etiquetas: 4 decimales (para que 0.0769 se vea exactamente)
y_labels <- function(x) sprintf("%.4f", x)

# gráfico
events <- event_study_data %>%
  ggplot(aes(x = exp, y = prop_independiente_total1,
             ymin = prop_independiente_total1 - 1.96*prop_independiente_total0, 
             ymax = prop_independiente_total1 + 1.96*prop_independiente_total0)) +
  
  # banda de confianza rosada
  geom_ribbon(fill = "#FADBD8", alpha = 0.4) +
  
  # línea y puntos principales (morado)
  geom_line(color = "#8E44AD", size = 1) +
  geom_point(color = "#6C3483", size = 2) +
  
  # línea horizontal del estimador DD (con leyenda)
  # línea horizontal del estimador DD (sin leyenda)
  geom_hline(yintercept = dd_val, color = "#E75480", linetype = "dashed", size = 1) +
  
  # forzar marcas del eje y e imprimir con 4 decimales
  scale_y_continuous(breaks = y_breaks, labels = y_labels) +
  
  # ejes, tema y líneas de referencia
  theme_minimal(base_size = 14) +
  xlab("Años relativos (año/4) antes y después de la llegada de OXXO a un ZAT") +
  ylab("Proporción de independientes en el ZAT") +
  geom_hline(yintercept = 0, color = "black") +
  geom_vline(xintercept = 0, color = "black") +
  scale_x_continuous(breaks = seq(min(event_study_data$exp, na.rm = TRUE),
                                  max(event_study_data$exp, na.rm = TRUE),
                                  by = 1)) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray90"),
    plot.background = element_rect(fill = "white", color = NA),
    legend.title = element_blank(),
    legend.position = "top"
  )


# Guardar el gráfico
ggsave(filename = "data/controles_results/events_study_lindo_controles.png",
       plot = events,
       width = 8, height = 6, dpi = 300)


event_study_data <- read.csv("data/controles_results/paraEventsStudySimple.csv")

head(event_study_data)

# valor del estimador
dd_val <- 0.0001989

# calcular rango y marcas para el eje y, e incluir dd_val
ymin_data <- min(event_study_data$prop_independiente_total1 - 1.96*event_study_data$prop_independiente_total0, na.rm = TRUE)
ymax_data <- max(event_study_data$prop_independiente_total1 + 1.96*event_study_data$prop_independiente_total0, na.rm = TRUE)

# usar pretty() para crear marcas automáticas y asegurar que dd_val esté incluido
y_breaks <- pretty(c(ymin_data, ymax_data), n = 5)
y_breaks <- sort(unique(c(y_breaks, dd_val)))

# formato de etiquetas: 4 decimales (para que 0.0769 se vea exactamente)
y_labels <- function(x) sprintf("%.4f", x)

# gráfico
events <- event_study_data %>%
  ggplot(aes(x = exp, y = prop_independiente_total1,
             ymin = prop_independiente_total1 - 1.96*prop_independiente_total0, 
             ymax = prop_independiente_total1 + 1.96*prop_independiente_total0)) +
  
  # banda de confianza rosada
  geom_ribbon(fill = "#FADBD8", alpha = 0.4) +
  
  # línea y puntos principales (morado)
  geom_line(color = "#8E44AD", size = 1) +
  geom_point(color = "#6C3483", size = 2) +
  
  # línea horizontal del estimador DD (con leyenda)
  # línea horizontal del estimador DD (sin leyenda)
  geom_hline(yintercept = dd_val, color = "#E75480", linetype = "dashed", size = 1) +
  
  # forzar marcas del eje y e imprimir con 4 decimales
  scale_y_continuous(breaks = y_breaks, labels = y_labels) +
  
  # ejes, tema y líneas de referencia
  theme_minimal(base_size = 14) +
  xlab("Años relativos (año/4) antes y después de la llegada de OXXO a un ZAT") +
  ylab("Proporción de independientes en el ZAT") +
  geom_hline(yintercept = 0, color = "black") +
  geom_vline(xintercept = 0, color = "black") +
  scale_x_continuous(breaks = seq(min(event_study_data$exp, na.rm = TRUE),
                                  max(event_study_data$exp, na.rm = TRUE),
                                  by = 1)) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray90"),
    plot.background = element_rect(fill = "white", color = NA),
    legend.title = element_blank(),
    legend.position = "top"
  )


# Guardar el gráfico
ggsave(filename = "data/controles_results/events_study_lindo_simple.png",
       plot = events,
       width = 8, height = 6, dpi = 300)


