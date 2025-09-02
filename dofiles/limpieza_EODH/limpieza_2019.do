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

local dropVars p2_supervisor p5_fecha p8_hora_inicio_encuesta p8_mayores_cinco_anios p6_hogares_vivienda colaboracion p4_nro_manzana

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

label define tipo_propiedad_vivienda_lbl 1 "Propia pagada" 2 "Propia pagando" 3 "Arriendo o subarriendo" 4 "En usufructo" 5 "Ocupante de hecho"

label values tipo_propiedad_vivienda tipo_propiedad_vivienda_lbl

rename p5_estrato estrato

label variable estrato "Estrato (1, 2, 3, 4, 5, o 6), 0: Sin estratificar"

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
                         8 "Más de $9.000.000" ///
                         9 "NS/NR" ///
                         10 "Sin información"

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
replace nivel_educativo = 4 if nivel_educativo == 4 | nivel_educativo == 6 
replace nivel_educativo = 5 if nivel_educativo == 5 | nivel_educativo == 7 
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

label define ocupacion_lbl 1 "Colegio o escuela" ///
                            2 "Universidad - Pregrado" ///
                            3 "Universidad - Posgrado" ///
                            4 "Inst. Técnico / Tecnológico" ///
                            5 "Inst. educación no formal" ///
                            11 "Obrero" ///
                            12 "Jornalero/agricultor" ///
                            13 "Empleado doméstico" ///
                            14 "Conductor/mensajero" ///
                            15 "Trabajador sin remuneración" ///
                            16 "Empleado de empresa particular" ///
                            17 "Empleado público" ///
                            18 "Profesional independiente" ///
                            19 "Trabajador independiente" ///
                            20 "Patrón/empleador" ///
                            21 "Vendedor informal" ///
                            31 "Dedicado al hogar" ///
                            32 "Jubilado/pensionado" ///
                            33 "Buscar trabajo" ///
                            34 "Incapacitado permanente" ///
                            35 "Va a jardín" ///
                            36 "Rentista" ///
                            37 "No ocupado" ///
                            38 "Otra actividad"
							
							
rename p6_id_ocupacion ocupacion1

label variable ocupacion1 "Ocupación principal en la semana anterior"

label values ocupacion1 ocupacion_lbl
 
rename p6_id_ocupacion_o1 ocupacion2

label variable ocupacion2 "Otra ocupación"

label values ocupacion2 ocupacion_lbl

rename p6_id_ocupacion_o2 ocupacion3

label variable ocupacion3 "Otra ocupación"

label values ocupacion3 ocupacion_lbl

rename p6_id_ocupacion_o3 ocupacion4

label variable ocupacion4 "Otra ocupación"

label values ocupacion4 ocupacion_lbl


gen mujer=.

replace mujer = 1 if sexo == "Mujer"
replace mujer = 0 if sexo == "Hombre"

drop sexo

label define mujer_lbl 0 "Hombre" 1 "Mujer"
label values mujer mujer_lbl

label variable mujer "1 si es mujer"

rename p7_id_actividad_economica actividad_economica1

replace actividad_economica1=. if actividad_economica1==99

label define actividad_lbl 1 "Agricultura, ganadería, caza y silvicultura" ///
                           2 "Explotación de minas y canteras" ///
                           3 "Industrias manufactureras" ///
                           4 "Suministro de electricidad, gas, vapor y aire acondicionado" ///
                           5 "Distribución de agua; evacuación y tratamiento de aguas residuales, gestión de desechos y actividades de saneamiento ambiental" ///
                           6 "Construcción" ///
                           7 "Comercio al por mayor y al por menor; reparación de vehículos automotores y motocicletas" ///
                           8 "Transporte y almacenamiento" ///
                           9 "Alojamiento y servicios de comida" ///
                           10 "Información y comunicaciones" ///
                           11 "Actividades financieras y de seguros" ///
                           12 "Actividades inmobiliarias" ///
                           13 "Actividades profesionales, científicas y técnicas" ///
                           14 "Actividades de servicios administrativos y de apoyo" ///
                           15 "Administración pública y defensa; planes de seguridad social de afiliación obligatoria" ///
                           16 "Educación" ///
                           17 "Actividades de atención de la salud humana y de asistencia social" ///
                           18 "Actividades artísticas, de entretenimiento y recreación" ///
                           19 "Otras actividades de servicios" ///
                           20 "Actividades de los hogares individuales en calidad de empleadores; actividades no diferenciadas de los hogares individuales como productores de bienes y servicios para uso propio" ///
                           21 "Actividades de organizaciones y entidades extraterritoriales" 

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







