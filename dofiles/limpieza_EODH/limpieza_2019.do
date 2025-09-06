*********************************************************
//VERSION 2

//LIMPIEZA BDD 2019
*********************************************************


cd "$dir_BDD_2019"

*********************************************************
//limpieza etapas muestra donde se baja la persona
*********************************************************

import delimited "EtapasEODH2019.csv", clear

*********************************************************
//drop de variables que no se necesitan
*********************************************************

local dropVars p18_id_medio_transporte p18_medio_transporte_cual p20_estacion_abordo_vehic p21_tiempo_arrancar_vehic p22_cuanto_pago p23_modalidad_pago p24_medio_pago p26a_propiedad_vehiculo p26c_pago_estacionamiento p26d_modalidad_pago p26e_medio_pago_util p27_experiencia_medio_transporte p26b_estacion_vehiculo

foreach var of local dropVars {
    drop `var'
}


*******************************************************
//renombrar variables para no volverme loca y hacer el casting apropiedo de ellas
*******************************************************

rename p19_camino_cuadras camino_cuadras

destring camino_cuadras, replace

recast byte camino_cuadras

label variable camino_cuadras "Cantidad de cuadras caminadas después del medio de transporte"

rename p19_camino_minutos camino_minutos

label variable camino_minutos "Cantidad de minutos caminadas después del medio de transporte"

rename p25_lugar_descenso lugar_descenso

label variable lugar_descenso "Lugar de descenso del vehículo"


cd "$dir_BDD_clean"

save "etapas_clean.dta", replace

********************************************************
*Esta es la parte que indica literalmente los datos basicos del hogar tipico
*******************************************************

cd "$dir_BDD_2019"

import delimited "HogaresEODH2019.csv", clear

*********************************************************
//drop de variables que no se necesitan
*********************************************************

local dropVars p2_supervisor p5_fecha p8_hora_inicio_encuesta p6_hogares_vivienda colaboracion p4_nro_manzana

foreach var of local dropVars {
    drop `var'
}

drop p1*

*******************************************************
//renombrar variables para no volverme loca y hacer el casting apropiado de ellas
*******************************************************

rename p3_nro_mapa nro_mapa

label variable nro_mapa "Número de estado, número de sector, número de seccion, número de manzana"

rename p7_barrio_vivienda barrio_vivienda

label variable barrio_vivienda "Barrio/vereda"

label variable zat_hogar "Zat de la vivienda"

rename p3_id_tipo_vivienda tipo_vivienda

label variable tipo_vivienda "Tipo de la vivienda (casa, apartamento, cuarto en inquilinato, etc.)."

replace tipo_vivienda=5 if tipo_vivienda==6

label define tipo_vivienda_lbl 1 "Casa" 2 "Apartamento" 3 "Cuarto(s) en inquilinato" 4 "Cuarto(s) en otro tipo de estructura" 5 "Otro tipo de vivienda"

label values tipo_vivienda tipo_vivienda_lbl

rename p4_id_vivienda_propia tipo_propiedad_vivienda

destring tipo_propiedad_vivienda, replace

recast byte tipo_propiedad_vivienda

**********************************************************************************
*para dejar nivel tipo_propiedad_vivienda de la misma forma que en el 2011
**********************************************************************************

replace tipo_propiedad_vivienda = 3 if tipo_propiedad_vivienda == 4

replace tipo_propiedad_vivienda = 4 if tipo_propiedad_vivienda == 5

replace tipo_propiedad_vivienda = 5 if tipo_propiedad_vivienda == 6

label variable tipo_propiedad_vivienda "tipo de propiedad vivienda"

label define tipo_propiedad_vivienda_lbl 1 "Propia pagada" 2 "Propia pagando" 3 "Arriendo o subarriendo" 4 "En usufructo" 5 "Ocupante de hecho" 7 "Agregado, cuidandero o mayordomo"

label values tipo_propiedad_vivienda tipo_propiedad_vivienda_lbl

rename p5_estrato estrato

replace estrato=. if estrato==0

label variable estrato "Estrato (1, 2, 3, 4, 5, o 6)"

rename p8_mayores_cinco_anios total_personas_mas_5

label variable total_personas_mas_5 "Número de personas de 5 años y más que viven en el hogar."

rename p7_total_personas total_personas

label variable total_personas "Número total de personas que viven en el hogar."

rename id_rango_ingresos ingreso

label variable ingreso "Ingresos por hogar."

replace ingreso = . if ingreso == 10

replace ingreso = . if ingreso == 9

label define ingreso_lbl 0 "$ 0 - $ 828.116" ///
                         1 "$ 828.117 - $ 1.500.000" ///
                         2 "$ 1.500.001 - $ 2.000.000" ///
                         3 "$ 2.000.001 - $ 2.500.000" ///
                         4 "$ 2.500.001 - $ 3.500.000" ///
                         5 "$ 3.500.001 - $ 4.900.000" ///
                         6 "$ 4.900.001 - $ 6.800.000" ///
                         7 "$ 6.800.001 - $ 9.000.000" ///
                         8 "Más de $9.000.000"

label values ingreso ingreso_lbl

label variable vivienda "Número de vivienda"

label variable municipio "municipio"

label variable localidad "localidad"

cd "$dir_BDD_clean"

save "origen_hogar_clean.dta", replace

********************************************************
*Esta es la parte que indica literalmente los datos SOCIOECONOMICOS de las personas por id y hogar
*******************************************************

cd "$dir_BDD_2019"

import delimited "PersonasEODH2019.csv", clear

*********************************************************
//drop de variables que no se necesitan
*********************************************************
rename p8me_poblacion_pertenece_6 discapacidad

drop p15* p16* p17* p14* p13* p12* p8* p10* p8* p9* p11* p7m* v*
*******************************************************
//renombrar variables para no volverme loca y hacer el casting apropiado de ellas
*******************************************************

rename p3_id_parentesco_jh parentesco

label variable parentesco "Parentesco con el jefe(a) del hogar"

label define parentesco_lbl 1 "Jefe" ///
                           2 "Cónyuge o compañero(a)" ///
                           3 "Hijos(as)" ///
                           4 "Nietos(as)" ///
                           5 "Padres" ///
                           6 "Hermanos(as)" ///
                           7 "Yerno o nuera" ///
                           8 "Abuelos(as)" ///
                           9 "Suegros(as)" ///
                           10 "Tíos(as)" ///
                           11 "Sobrinos(as)" ///
                           12 "Primos(as)" ///
                           13 "Cuñados(as)" ///
                           14 "Otros parientes" ///
                           15 "Servicio doméstico" ///
                           16 "Hijos servicio doméstico" ///
                           17 "No parientes"

replace parentesco = . if parentesco == 99

label values parentesco parentesco_lbl

rename p4_edad edad

label variable edad "Edad en años cumplidos."

rename p5_id_nivel_educativo nivel_educativo

label variable nivel_educativo "Máximo nivel educativo alcanzado."

**********************************************************************************
*para dejar nivel educativo de la misma forma que en el 2011
**********************************************************************************

replace nivel_educativo = . if nivel_educativo == 99
replace nivel_educativo = 4 if nivel_educativo == 4 | nivel_educativo == 6 | nivel_educativo == 5
replace nivel_educativo = 5 if nivel_educativo == 7 
replace nivel_educativo = 6 if nivel_educativo == 8
replace nivel_educativo = 7 if nivel_educativo == 9
replace nivel_educativo = 8 if nivel_educativo == 10
replace nivel_educativo = 9 if nivel_educativo == 11
replace nivel_educativo = 10 if nivel_educativo == 12
replace nivel_educativo = 11 if nivel_educativo == 13
replace nivel_educativo = 12 if nivel_educativo == 14

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

rename p6_id_ocupacion ocupacion1

recode ocupacion1 ///
    (11 = 1) (13 = 4) (19 = 5) (18 = 6) (20 = 7) (15 = 8) (14 = 10) ///
    (1 = 13) (2 = 14) (3 = 15) (4 = 16) (5 = 17) (31 = 18) (32 = 19) ///
    (33 = 20) (34 = 21) (35 = 22) (36 = 23) (38 = 24) (37 = 25) ///
    (21 = 26) (17 = 27) (16 = 28) (12 = 29), gen(ocupacion_new1)

drop ocupacion1

rename ocupacion_new1 ocupacion1

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
    14 "Estudiante en Universidad - pregrado" ///
    15 "Estudiante en Universidad - postgrado" ///
    16 "Estudiante en Instituto técnico/tecnológico" ///
    17 "Estudiante en Instituto educación no formal" ///
    18 "Dedicado al hogar" ///
    19 "Jubilado" ///
    20 "Buscar trabajo" ///
    21 "Incapacitado permanente" ///
    22 "Va a jardín" ///
    23 "Rentista" ///
    24 "Otra actividad" ///
    25 "No ocupado" ///
    26 "Vendedor informal" ///
    27 "Empleado público" ///
    28 "Empleado de empresa particular" ///
    29 "Jornalero/agricultor"
											

label variable ocupacion1 "Ocupación principal en la semana anterior"

label values ocupacion1 ocupacion_lbl
 
rename p6_id_ocupacion_o1 ocupacion2

label variable ocupacion2 "Otra ocupación"

recode ocupacion2 ///
    (11 = 1) (13 = 4) (19 = 5) (18 = 6) (20 = 7) (15 = 8) (14 = 10) ///
    (1 = 13) (2 = 14) (3 = 15) (4 = 16) (5 = 17) (31 = 18) (32 = 19) ///
    (33 = 20) (34 = 21) (35 = 22) (36 = 23) (38 = 24) (37 = 25) ///
    (21 = 26) (17 = 27) (16 = 28) (12 = 29), gen(ocupacion_new2)
	
drop ocupacion2

rename ocupacion_new2 ocupacion2

label values ocupacion2 ocupacion_lbl

rename p6_id_ocupacion_o2 ocupacion3

label variable ocupacion3 "Otra ocupación"

recode ocupacion3 ///
    (11 = 1) (13 = 4) (19 = 5) (18 = 6) (20 = 7) (15 = 8) (14 = 10) ///
    (1 = 13) (2 = 14) (3 = 15) (4 = 16) (5 = 17) (31 = 18) (32 = 19) ///
    (33 = 20) (34 = 21) (35 = 22) (36 = 23) (38 = 24) (37 = 25) ///
    (21 = 26) (17 = 27) (16 = 28) (12 = 29), gen(ocupacion_new3)

drop ocupacion3

rename ocupacion_new3 ocupacion3

label values ocupacion3 ocupacion_lbl

rename p6_id_ocupacion_o3 ocupacion4

label variable ocupacion4 "Otra ocupación"

recode ocupacion4 ///
    (11 = 1) (13 = 4) (19 = 5) (18 = 6) (20 = 7) (15 = 8) (14 = 10) ///
    (1 = 13) (2 = 14) (3 = 15) (4 = 16) (5 = 17) (31 = 18) (32 = 19) ///
    (33 = 20) (34 = 21) (35 = 22) (36 = 23) (38 = 24) (37 = 25) ///
    (21 = 26) (17 = 27) (16 = 28) (12 = 29), gen(ocupacion_new4)
	
drop ocupacion4

rename ocupacion_new4 ocupacion4

label values ocupacion4 ocupacion_lbl


gen mujer=.

replace mujer = 1 if sexo == "Mujer"
replace mujer = 0 if sexo == "Hombre"

drop sexo

label define mujer_lbl 0 "Hombre" 1 "Mujer"
label values mujer mujer_lbl

label variable mujer "1 si es mujer"

rename p7_id_actividad_economica actividad_economica1

recode actividad ///
    (1 = 1) (2 = 3) (3 = 4) (4 = 5) (5 = 18) (6 = 6) (7 = 7) ///
    (8 = 9) (9 = 8) (10 = 9) (11 = 10) (12 = 11) (13 = 19) ///
    (14 = 15) (15 = 12) (16 = 13) (17 = 14) (18 = 15) (19 = 15) ///
    (20 = 16) (21 = 17), gen(actividad_new)
	
drop actividad_economica1

rename actividad_new actividad_economica1

replace actividad_economica1=. if actividad_economica1==99

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

label values actividad_economica1 actividad_lbl

***************************************************************

*los labels aqui se tuvieron que buscar en su mayoria por medio 
*de las cartillas de prguntas y formualarios. En el diccionario de datos
*no habia info alguna :')
***************************************************************

*FALTA ORIGEN LUGAR PERO NI IDEA

rename p7v_lugar_inicio_dia lugar_origen

label define lugar_lbl 1 "Hogar" 2 "Otro"

label values lugar_origen lugar_lbl

	cd "$dir_BDD_clean"

	save "persona_clean.dta", replace

********************************************************
*Esta es la parte que indica literalmente el movimiento de las personas
*ACA HABLA DEL ZAT DE DESTINO, lo mas importante
*******************************************************				

cd "$dir_BDD_2019"

import delimited "ViajesEODH2019.csv", clear

*********************************************************
//drop de variables que no se necesitan
*********************************************************

local dropVars hora_inicio_viaje p31_hora_llegada p33_aplicacion_antes_viaje p33_cual_aplicacion_antes_viaje p34_aplicacion_durante_viaje p34_cual_aplicacion_durante_viaj p35_otro_desplazamiento p36_hora_salida modo_principal modo_principal_desagregado fecha p29_id_municipio

foreach var of local dropVars {
    drop `var'
}

*******************************************************
//renombrar variables para no volverme loca y hacer el casting apropiado de ellas
*******************************************************

label variable id_hogar "id del hogar"

label variable id_persona "id de la persona"

label variable id_viaje "id del viaje"

label define lugar_lbl 1 "Hogar" 2 "Otro"

label values lugar_origen lugar_lbl

label variable lugar_origen "lugar de origen del viaje"

label variable zat_origen "zat origen"

rename p17_id_motivo_viaje motivo_viaje

label variable motivo_viaje "motivo del viaje"

replace motivo_viaje=. if motivo_viaje==99

label define motivo_viaje_lbl 1 "Trabajar" ///
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
                             77 "Otro"

							 
label values motivo_viaje motivo_viaje_lbl

rename p17_otro_motivo otro_motivo_viaje

label variable otro_motivo_viaje "otro movivo en str"

rename p28_lugar_destino lugar_destino

label values lugar_destino lugar_lbl

label variable lugar_destino "lugar de destino del viaje"

label variable zat_destino "zat destino"

rename p30_camino_cuadras camino_cuadras

destring camino_cuadras, replace

recast byte camino_cuadras

label variable camino_cuadras "Cantidad de cuadras caminadas después del medio de transporte"

rename p30_camino_minutos camino_minutos

label variable camino_minutos "Cantidad de minutos caminadas después del medio de transporte"

qui ds p32_*   // Lista todas las variables que empiezan con p32_

qui foreach var of varlist `r(varlist)' {
    local newname = substr("`var'", 5, .)   // Quita los primeros 4 caracteres "p32_"
    rename `var' `newname'
	
	label variable  `newname' "Realiza este viaje los `newname'"
	
	replace `newname' = 0 if missing(`newname')
}

cd "$dir_BDD_clean"

save "viaje_clean.dta", replace







