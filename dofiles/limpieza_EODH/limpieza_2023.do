********************************************************
*version 2:
*limpieza datos de la encuesta de movilidad del 2023
*******************************************************

cd "$dir_BDD_2023"

********************************************************
*Esta es la parte A e indica literalmente los datos basicos del hogar tipico
*******************************************************

import delimited "a. Modulo hogares.csv", clear

*******************************************************
//haremos drop de variables que no nos importan
*******************************************************

drop fecha tipo_enc pers18años_hg cómo_enteró cant_hg_viv

*******************************************************
//renombrar variables para no volverme loca y hacer el casting apropiedo de ellas
*******************************************************

rename pers5años_hg total_personas_mas_5

label variable total_personas_mas_5 "Número de personas de 5 años y más que viven en el hogar."

rename perstotal_hg total_personas

label variable total_personas "Número total de personas que viven en el hogar."

label variable cod_viv "codigo de la vivienda"

label variable cod_hog "codigo del hogar"

label variable cod_utam_hg "codigo UTAM del hogar"

label variable nom_utam_hg "nombre UTAM del hogar"

label variable zat_hg "ZAT del hogar"

label variable cod_upl_hg "codigo UPL del hogar"

label variable nom_upl_hg "nombre UPL del hogar"

label variable cod_mpio_hg "codigo municipio del hogar"

label variable nom_mpio_hg "nombre municipio del hogar"

label variable cod_loc_hg "codigo localidad del hogar"

label variable nom_loc_hg "nombre localidad del hogar"

rename estrato_hg estrato

replace estrato = "0" if estrato=="No aplica"

destring estrato, replace

recast byte estrato

label variable estrato "estrato del hogar"

replace estrato = . if estrato==0


label variable cod_dane_manzana_hg "codigo manzana del hogar"

label variable tipo_zona_hg "urbano o centro poblado"

label variable cod_barrio_vereda_hg "codigo barrio o vereda del hogar"

label variable nom_barrio_vereda_hg "nombre barrio o vereda del hogar"

label variable nom_barrio_vereda_hg "nombre barrio o vereda del hogar"

levelsof tipo_viv

gen tipo_vivienda=.

replace tipo_vivienda=1  if tipo_viv=="Casa"

replace tipo_vivienda=2  if tipo_viv=="Apartamento"

replace tipo_vivienda=3  if tipo_viv=="Cuarto inquilinato"

replace tipo_vivienda=4  if tipo_viv=="Cuarto otro"

replace tipo_vivienda=5  if tipo_viv=="Otro tipo"

label variable tipo_vivienda "tipo de vivienda"

label define tipo_vivienda_lbl 1 "Casa" 2 "Apartamento" 3 "Cuarto(s) en inquilinato" 4 "Cuarto(s) en otro tipo de estructura" 5 "Otro tipo de vivienda"

label values tipo_vivienda tipo_vivienda_lbl

drop tipo_viv

* Generar variable numérica vacía
gen ingreso = .

* Reemplazos según categorías de texto
replace ingreso = 0 if ingre_mes_hg == "0-400000"
replace ingreso = 1 if ingre_mes_hg == "400001-800000"
replace ingreso = 2 if ingre_mes_hg == "800001-1160000"
replace ingreso = 3 if ingre_mes_hg == "1160001-1500000"
replace ingreso = 4 if ingre_mes_hg == "1500001-2000000"
replace ingreso = 5 if ingre_mes_hg == "2000001-2500000"
replace ingreso = 6 if ingre_mes_hg == "2500001-3500000"
replace ingreso = 7 if ingre_mes_hg == "3500001-4900000"
replace ingreso = 8 if ingre_mes_hg == "4900001-6800000"
replace ingreso = 9 if ingre_mes_hg == "6800001-9000000"
replace ingreso = 10 if ingre_mes_hg == ">9000000"

* Definir etiquetas
label define ingreso_lbl ///
    0 "0-400000" ///
    1 "400001-800000" ///
    2 "800001-1160000" ///
    3 "1160001-1500000" ///
    4 "1500001-2000000" ///
    5 "2000001-2500000" ///
    6 "2500001-3500000" ///
    7 "3500001-4900000" ///
    8 "4900001-6800000" ///
    9 "6800001-9000000" ///
    10 ">9000000"

* Asignar etiqueta a la variable
label values ingreso ingreso_lbl

label variable ingreso "ingresos mensuales del hogar"

rename cod_hog cod_hg

drop ingre_mes_hg

cd "$dir_BDD_clean"

save "nuevo_MOD_hogar.dta", replace

********************************************************
*Esta es la parte C e indica literalmente los datos basicos de la persona
*******************************************************

cd "$dir_BDD_2023"

import delimited "c. Modulo personas.csv", clear

*******************************************************
//haremos drop de variables que no nos importan
*******************************************************

local dropVars orien_sexual identidad_etnica madre_cab_familia quien_llevarecoge_establecimient cuidado_despues_regresar dific_princ_medios_transp_discap licencia_cond_vigente posee_celular modo_principal_prepandemia modo_principal_pandemia razón_cambio_pandemia cambio_frecuencia_postpandemia cambio_modo_pico_placa cambio_modo_grandes_obra cambio_modo_seguridad acto_violencia_sexual lugar_violencia_sexual a_quien_acudio genero cuidado_entre_semana_discap rlcpd permanencia_entre_semana

foreach var of local dropVars {
    drop `var'
}

*******************************************************
//renombrar variables para no volverme loca y hacer el casting apropiedo de ellas
*******************************************************

replace estra_hg = "0" if estra_hg=="No aplica"

destring estra_hg, replace

recast byte estra_hg

label variable estra_hg "estrato del hogar"

rename estra_hg estrato

replace estrato=. if estrato==0

gen limitaciones_fisicas = cond(condicion_discapacidad == "Ninguna", 0, 1)

label variable limitaciones_fisicas "1 si la persona presenta limitaciones fisicas"

drop condicion_discapacidad

gen mujer=.

replace mujer = 1 if sexo == "Mujer"
replace mujer = 0 if sexo == "Hombre"

drop sexo

label define mujer_lbl 0 "Hombre" 1 "Mujer"

label values mujer mujer_lbl

label variable mujer "1 si es mujer"

label variable cod_per "codigo de la persona"

label variable cod_hg "codigo del hogar"

label variable nom_mun_hg "nombre municipio del hogar"

label variable cod_utam_hg "codigo UTAM del hogar"

label variable cod_upl_hg "codigo UPL del hogar"

label variable zat_hg "ZAT del hogar"

label variable edad "edad de la persona"

gen nivel_educativo = .

* Recodificación según categorías de texto
replace nivel_educativo = 1  if max_nivel_edu == "Preescolar"
replace nivel_educativo = 2  if max_nivel_edu == "Primaria incompleta"
replace nivel_educativo = 3  if max_nivel_edu == "Primaria completa"
replace nivel_educativo = 4  if inlist(max_nivel_edu, "Secundaria incompleta", "Media incompleta (10° y 11°)", "Secundaria completa")
replace nivel_educativo = 5  if inlist(max_nivel_edu, "Media completa (10° y 11°)")
replace nivel_educativo = 6  if max_nivel_edu == "Técnico/Tecnológico incompleta"
replace nivel_educativo = 7  if max_nivel_edu == "Técnico/Tecnológico completa"
replace nivel_educativo = 8  if max_nivel_edu == "Universitario incompleto"
replace nivel_educativo = 9  if max_nivel_edu == "Universitario completo"
replace nivel_educativo = 10 if max_nivel_edu == "Posgrado incompleto"
replace nivel_educativo = 11 if max_nivel_edu == "Posgrado completo"
replace nivel_educativo = 12 if max_nivel_edu == "Ninguno"

* "No aplica" se queda como missing (.)

* Asignar labels
label define educ_lbl 1 "Preescolar" ///
                     2 "Primaria incompleta" ///
                     3 "Primaria completa" ///
                     4 "Secundaria básica y media incompleta" ///
                     5 "Secundaria básica y media completa" ///
                     6 "Técnico tecnológico incompleto" ///
                     7 "Técnico tecnológico completo" ///
                     8 "Universitario incompleto" ///
                     9 "Universitario completo" ///
                     10 "Postgrado incompleto" ///
                     11 "Postgrado completo" ///
                     12 "Ninguno"

label values nivel_educativo educ_lbl

label variable nivel_educativo "maximo nivel educativo"

drop max_nivel_edu

gen ocupacion1 = .

* Estudiantes
replace ocupacion1 = 13 if strpos(ocupacion_principal, "Colegio o escuela")
replace ocupacion1 = 13 if strpos(ocupacion_principal, "Universidad") & strpos(ocupacion_principal, "Pregrado")
replace ocupacion1 = 13 if strpos(ocupacion_principal, "Universidad") & strpos(ocupacion_principal, "Posgrado")
replace ocupacion1 = 13 if strpos(ocupacion_principal, "Inst Técnico") | strpos(ocupacion_principal, "Inst Técnico / Tecnológico")
replace ocupacion1 = 13 if strpos(ocupacion_principal, "Inst educación no formal")

* Trabajadores
replace ocupacion1 = 1 if strpos(ocupacion_principal, "Obrero")
replace ocupacion1 = 29 if strpos(ocupacion_principal, "Jornalero") | strpos(ocupacion_principal, "agricultor")
replace ocupacion1 = 4 if strpos(ocupacion_principal, "Empleado doméstico")
replace ocupacion1 = 10 if strpos(ocupacion_principal, "Conductor") | strpos(ocupacion_principal, "mensajero")
replace ocupacion1 = 8 if strpos(ocupacion_principal, "Trabajador sin remuneración")
replace ocupacion1 = 28 if strpos(ocupacion_principal, "Empleado de empresa particular")
replace ocupacion1 = 27 if strpos(ocupacion_principal, "Empleado público")
replace ocupacion1 = 6 if strpos(ocupacion_principal, "Profesional independiente")
replace ocupacion1 = 5 if strpos(ocupacion_principal, "Trabajador independiente")
replace ocupacion1 = 7 if strpos(ocupacion_principal, "Patrón") | strpos(ocupacion_principal, "empleador")
replace ocupacion1 = 26 if strpos(ocupacion_principal, "Vendedor informal")

* Condiciones de inactividad
replace ocupacion1 = 18 if strpos(ocupacion_principal, "Dedicado al hogar")
replace ocupacion1 = 19 if strpos(ocupacion_principal, "Jubilado") | strpos(ocupacion_principal, "pensionado")
replace ocupacion1 = 20 if strpos(ocupacion_principal, "Buscar trabajo")
replace ocupacion1 = 21 if strpos(ocupacion_principal, "Incapacitado permanente")
replace ocupacion1 = 23 if strpos(ocupacion_principal, "Va a jardín")
replace ocupacion1 = 23 if strpos(ocupacion_principal, "Rentista")
replace ocupacion1 = 25 if strpos(ocupacion_principal, "No ocupado")
replace ocupacion1 = 24 if strpos(ocupacion_principal, "Otra actividad")

* Definir etiquetas
label define ocupacion_lbl ///
    1 "Obrero" ///
    2 "Empleado de nómina" ///
    3 "Contratista (prestación servicios)" ///
    4 "Empleado doméstico" ///
    5 "Trabajador independiente" ///
    6 "Profesional independiente" ///
    7 "Patrón o empleador" ///
    8 "Trabajo familiar (sin remuneración)" ///
    9 "Trabajo desde la casa" ///
    10 "Conductor/mensajero" ///
    13 "Estudiante en colegio o escuela" ///
    18 "Dedicado al hogar" ///
    19 "Jubilado" ///
    20 "Buscar trabajo" ///
    21 "Incapacitado permanente" ///
    23 "Rentista" ///
    24 "Otra actividad" ///
    25 "No ocupado" ///
    26 "Vendedor informal" ///
    27 "Empleado público" ///
    28 "Empleado de empresa particular" ///
    29 "Jornalero/agricultor"

label values ocupacion1 ocupacion_lbl

label variable ocupacion1 "ocupacion principal"

drop ocupacion_principal

gen actividad = .

replace actividad = 1  if strpos(actividad_economica, "Agricultura, ganadería, caza,")
replace actividad = 3  if strpos(actividad_economica,"minas")
replace actividad = 4  if strpos(actividad_economica, "manufactureras")
replace actividad = 5  if strpos(actividad_economica,"Suministro de electricidad, gas")
replace actividad = 18  if strpos(actividad_economica,"Distribución agua, evacuación tratam")
replace actividad = 6  if strpos(actividad_economica,"Construcción")
replace actividad = 7  if strpos(actividad_economica,"Comercio al por mayor y al por menor")
replace actividad = 9  if strpos(actividad_economica,"Transporte y almacenamiento")
replace actividad = 8  if strpos(actividad_economica,"Alojamiento y servicios de comida")
replace actividad = 9 if strpos(actividad_economica,"Información y comunicaciones")
replace actividad = 10 if strpos(actividad_economica,"Actividades financieras y de seguros")
replace actividad = 11 if strpos(actividad_economica,"Actividades inmobiliarias")
replace actividad = 19 if strpos(actividad_economica,"Actividades profesionales")
replace actividad = 15 if strpos(actividad_economica,"Actividades de servicios")
replace actividad = 12 if strpos(actividad_economica,"Administración pública y defensa")
replace actividad = 13 if strpos(actividad_economica,"Educación")
replace actividad = 14 if strpos(actividad_economica,"Actividades de atención de la salud")
replace actividad = 15 if strpos(actividad_economica,"Actividades artísticas")
replace actividad = 15 if strpos(actividad_economica,"Otras actividades de servicios")
replace actividad = 16 if strpos(actividad_economica,"Actividades hogares individuales")
replace actividad = 17 if strpos(actividad_economica,"Actividades de organizaciones y")

* "No aplica" → missing
//replace actividad = . if strpos(actividad_economica,"No aplica")

* Definir etiquetas
label define actividad1_lbl ///
    1 "Agricultura, ganadería, caza y silvicultura" ///
    2 "Pesca" ///
    3 "Explotación de minas y canteras" ///
    4 "Industrias manufactureras" ///
    5 "Suministro de electricidad, gas y agua" ///
    6 "Construcción" ///
    7 "Comercio al por mayor y al por menor de vehículos automotores, motocicletas, efectos personales y enseres domésticos" ///
    8 "Hoteles y restaurantes" ///
    9 "Transporte, almacenamiento y comunicaciones" ///
    10 "Intermediación financiera" ///
    11 "Actividades inmobiliarias, empresariales y de alquiler" ///
    12 "Administración pública y defensa, seguridad social de afiliación obligatoria" ///
    13 "Educación" ///
    14 "Servicios sociales y de salud" ///
    15 "Otras actividades de servicios comunitarios, sociales y personales" ///
    16 "Hogares privados con servicio doméstico" ///
    17 "Organizaciones y órganos extraterritoriales" ///
    18 "Distribución de agua; evacuación y tratamiento de aguas residuales, gestión de desechos y actividades de saneamiento ambiental" ///
    19 "Actividades profesionales, científicas y técnicas"

label values actividad actividad1_lbl

label variable actividad "actividad economica"

drop actividad_economica

rename actividad actividad_economica1

cd "$dir_BDD_clean"

save "nuevo_MOD_persona.dta", replace

********************************************************
*Esta es la parte D e indica literalmente los datos el modulo de viajes, a donde se dirige la persona
*******************************************************
cd "$dir_BDD_2023"

import delimited "d. Modulo viajes.csv", clear

*******************************************************
//haremos drop de variables que no nos importan
*******************************************************

local dropVars hora_ini hora_fin duracion_min t_acceso_min t_espera_min t_egreso_min modo_principal_agrupado modo_principal_desagrupado etapas app_antes_vj app_durante_vj genero orien_sexual identidad_etnica madre_cab_familia max_nivel_edu ocupacion_principal estra_hg

foreach var of local dropVars {
    drop `var'
}

*******************************************************
//renombrar variables para no volverme loca y hacer el casting apropiedo de ellas
*******************************************************

label variable cod_hg "codigo del hogar"

gen mujer=.

replace mujer = 1 if sexo == "Mujer"
replace mujer = 0 if sexo == "Hombre"

drop sexo

label define mujer_lbl 0 "Hombre" 1 "Mujer"
label values mujer mujer_lbl

label variable mujer "1 si es mujer"

label variable nom_mun_hg "nombre municipio del hogar"

label variable cod_utam_hg "codigo UTAM del hogar"

label variable cod_upl_hg "codigo UPL del hogar"

label variable zat_hg "ZAT del hogar"

rename cod_pers cod_per

label variable cod_per "codigo de la persona"

* Variables de viaje y ubicación
label variable cod_vj "Código del viaje"
label variable orden_vj "Orden del viaje"
label variable otro_vj "Otro viaje"
label variable zat_ori "ZAT de origen"
label variable utam_ori "UTAM de origen"
label variable upl_ori "UPL de origen"
label variable nom_mun_ori "Nombre municipio de origen"
label variable localidad_ori "Localidad de origen"
rename zat_des zat_destino
label variable zat_destino "ZAT de destino"
label variable utam_des "UTAM de destino"
label variable upl_des "UPL de destino"
label variable localidad_des "Localidad de destino"
label variable nom_mun_des "Nombre municipio de destino"

* Motivo y frecuencia del viaje

gen razon_viaje=.

replace razon_viaje= 3 if strpos(motivo_viaje, "Estudiar")
replace razon_viaje= 15 if strpos(motivo_viaje, "A acompañar a")
replace razon_viaje= 14 if strpos(motivo_viaje, "religioso")
replace razon_viaje= 4 if strpos(motivo_viaje, "médicos")
replace razon_viaje= 13 if strpos(motivo_viaje, "buscar trabajo")
replace razon_viaje= 8 if strpos(motivo_viaje, "dejar algo")
replace razon_viaje= 16 if strpos(motivo_viaje, "deportivas")
replace razon_viaje= 12 if strpos(motivo_viaje, "recreativas")
replace razon_viaje= 11 if strpos(motivo_viaje, "trámite")
replace razon_viaje= 10 if strpos(motivo_viaje, "compras")
replace razon_viaje= 6 if strpos(motivo_viaje, "hogar")
replace razon_viaje= 1 if strpos(motivo_viaje, "A trabajar")
replace razon_viaje= 5 if strpos(motivo_viaje, "visitar")
replace razon_viaje= 17 if strpos(motivo_viaje, "vehículo")

drop motivo_viaje

label variable razon_viaje "Motivo principal del viaje" 

label define razon_viaje_lbl 1 "Trabajar" ///
                             2 "Asuntos de trabajo" ///
                             3 "Estudiar" ///
                             4 "Recibir atención en salud" ///
                             5 "Ver a alguien" ///
                             6 "Volver a casa" ///
                             7 "Buscar/Dejar a alguien" ///
                             8 "Buscar/Dejar algo" ///
                             9 "Comer/Tomar algo" ///
                             10 "Compras" ///
                             11 "Trámites" ///
                             12 "Recreación y cultura" ///
                             13 "Buscar trabajo" ///
                             14 "Actividades con fines religiosos" ///
                             15 "Cuidado de personas" ///
                             16 "Actividad física y deporte" ///
                             77 "Otro" ///
							 17 "Conduzco vehículo como forma de trabajo"



label variable motivo_viaje_cuidado "Motivo relacionado con cuidado"
label variable frecuencia_viaje "Frecuencia del viaje"

* Datos personales
label variable edad "Edad de la persona"

* Claves y códigos
label variable key_hg "Clave del hogar"
label variable key_pers "Clave de la persona"
label variable key_pers_viaja "Clave de la persona que viaja"
label variable key_viaje "Clave del viaje"


cd "$dir_BDD_clean"

save "nuevo_MOD_viajes.dta", replace


********************************************************
*Esta es la parte E e indica literalmente los datos el modulo de estapas de los viajes
*******************************************************

*NO LA VAMOS A USAR PORQU CON LOS OTROS DATOS ES SUFICIENTE PARA CREAR LA BDD




