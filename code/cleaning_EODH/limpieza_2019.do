********************************************************
* version 3:
* data cleaning for the 2019 movility survey
********************************************************

cd "$dir_BDD_2019"


********************************************************
* HOGARES module describes the basic info of a household
*******************************************************


cd "$dir_BDD_2019"

import delimited "HogaresEODH2019.csv", clear


*********************************************************
// will drop all variables that are not of our interest
*********************************************************


drop p2_supervisor p5_fecha p8_hora_inicio_encuesta p6_hogares_vivienda colaboracion p4_nro_manzana

drop p1*


*******************************************************************************************

// rename variables, add their proper label, and cast them into the data type they belong

*******************************************************************************************


*******************************************************************************************
// LOCALIZATION
******************************************************************************************* 


rename p3_nro_mapa nro_mapa

label variable nro_mapa "Número de estado, número de sector, número de seccion, número de manzana"


rename p7_barrio_vivienda nom_barrio_hogar

label variable nom_barrio_hogar "Barrio/vereda"


label variable zat_hogar "Zat de la vivienda"



*******************************************************************************************
// TYPE OF home
******************************************************************************************* 


rename p3_id_tipo_vivienda tipo_vivienda

label variable tipo_vivienda "Tipo de la vivienda (casa, apartamento, cuarto en inquilinato, etc.)."


* to make all surveys as comparable as possible


/*
I combined the categories of 
6. Otro tipo de vivienda
5. Vivienda Indígena

into a single one named 5 "Otro tipo de vivienda"
*/

replace tipo_vivienda=5 if tipo_vivienda==6

label define tipo_vivienda_lbl 1 "Casa" 2 "Apartamento" 3 "Cuarto(s) en inquilinato" 4 "Cuarto(s) en otro tipo de estructura" 5 "Otro tipo de vivienda"

label values tipo_vivienda tipo_vivienda_lbl


*******************************************************************************************
// TYPE OF PROPERTY
******************************************************************************************* 


rename p4_id_vivienda_propia tipo_propiedad_vivienda

destring tipo_propiedad_vivienda, replace

recast byte tipo_propiedad_vivienda


* to make all surveys as comparable as possible


/*
I had to change the numbers used to codify most categories. I left the numbers used in the 2011 survey. 

I combined the categories of 
3. Arriendo
4. Subarriendo
into a single one named 3 "Arriendo o subarriendo"

category  "En usufructo"is now # 4, before it was # 5

category  "Ocupante de hecho" is now # 5, before it was # 6

category 6 does not exist
*/

replace tipo_propiedad_vivienda = 3 if tipo_propiedad_vivienda == 4

replace tipo_propiedad_vivienda = 4 if tipo_propiedad_vivienda == 5

replace tipo_propiedad_vivienda = 5 if tipo_propiedad_vivienda == 6

label variable tipo_propiedad_vivienda "tipo de propiedad vivienda"

label define tipo_propiedad_vivienda_lbl 1 "Propia pagada" 2 "Propia pagando" 3 "Arriendo o subarriendo" 4 "En usufructo" 5 "Ocupante de hecho" 7 "Agregado, cuidandero o mayordomo"

label values tipo_propiedad_vivienda tipo_propiedad_vivienda_lbl


*******************************************************************************************
// ESTRATO
******************************************************************************************* 


rename p5_estrato estrato

replace estrato=. if estrato==0

label variable estrato "Estrato (1, 2, 3, 4, 5, o 6)"



*******************************************************************************************
// number of people who have 5 years or more
******************************************************************************************* 


rename p8_mayores_cinco_anios total_personas_mas_5

label variable total_personas_mas_5 "Número de personas de 5 años y más que viven en el hogar."


*******************************************************************************************
// total number of people in the household
******************************************************************************************* 


rename p7_total_personas total_personas

label variable total_personas "Número total de personas que viven en el hogar."


*******************************************************************************************
// EARNINGS
******************************************************************************************* 


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


*******************************************************************************************
// LOCALIZATION
******************************************************************************************* 


label variable vivienda "Número de vivienda"

label variable municipio "municipio"
rename municipio nom_mun_hogar

label variable localidad "localidad"
rename localidad nom_localidad_hogar

rename manzana id_manzana_hogar

rename utam nom_utam_hogar

cd "$dir_BDD_clean"

save "origen_hogar_clean.dta", replace


********************************************************
// ETAPAS module describes person's trips
********************************************************


cd "$dir_BDD_2019"

import delimited "EtapasEODH2019.csv", clear


*********************************************************
// will drop all variables that are not of our interest
*********************************************************


drop p18_id_medio_transporte p18_medio_transporte_cual p20_estacion_abordo_vehic p21_tiempo_arrancar_vehic p22_cuanto_pago p23_modalidad_pago p24_medio_pago p26a_propiedad_vehiculo p26c_pago_estacionamiento p26d_modalidad_pago p26e_medio_pago_util p27_experiencia_medio_transporte p26b_estacion_vehiculo


*******************************************************************************************

// rename variables, add their proper label, and cast them into the data type they belong

*******************************************************************************************


*******************************************************
// blocks walked
*******************************************************


rename p19_camino_cuadras camino_cuadras

destring camino_cuadras, replace

recast byte camino_cuadras

label variable camino_cuadras "Cantidad de cuadras caminadas después del medio de transporte"

*******************************************************
// minutes walked
*******************************************************


rename p19_camino_minutos camino_minutos

label variable camino_minutos "Cantidad de minutos caminadas después del medio de transporte"


*******************************************************
// place where the person got off the vehicle
*******************************************************


rename p25_lugar_descenso lugar_descenso

label variable lugar_descenso "Lugar de descenso del vehículo"



cd "$dir_BDD_clean"

save "etapas_clean.dta", replace


***************************************************************************
* PERSONAS MODULE indicates de socioeconomic caracteristics of each person
***************************************************************************


cd "$dir_BDD_2019"

import delimited "PersonasEODH2019.csv", clear


*********************************************************
// will drop all variables that are not of our interest
*********************************************************

* I first rename this variable, because then I will delete all variables that start with p8

rename p8me_poblacion_pertenece_6 limitaciones_fisicas

label variable limitaciones_fisicas "=1 posee limitaciones fisicas"


drop p15* p16* p17* p14* p13* p12* p8* p10* p8* p9* p11* p7m* v*


*******************************************************************************************

// rename variables, add their proper label, and cast them into the data type they belong

*******************************************************************************************


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


*******************************************************************************************
// AGE
*******************************************************************************************


rename p4_edad edad

label variable edad "Edad en años cumplidos."

rename p5_id_nivel_educativo nivel_educativo

label variable nivel_educativo "Máximo nivel educativo alcanzado."


**********************************************************************************
*EDUCATION LEVEL  (needs to have the same codification as 2011)
**********************************************************************************

replace nivel_educativo = . if nivel_educativo == 99

/*
I combined the categories of 
04. Secundaria incompleta
05. Secundaria completa
06. Media incompleta (100 y 110)
into a single one named 4 "Secundaria básica y media incompleta"
(I made the best effort I could with this part because "Secundaria básica y media incompleta" implies many possible situations)

*/
replace nivel_educativo = 4 if nivel_educativo == 4 | nivel_educativo == 6 | nivel_educativo == 5

//changed "Secundaria básica y media completa"  from 7 to 5
replace nivel_educativo = 5 if nivel_educativo == 7 

//changed "Técnico tecnológico incompleto"  from 8 to 6
replace nivel_educativo = 6 if nivel_educativo == 8

//changed "Técnico tecnológico completo"  from 9 to 7
replace nivel_educativo = 7 if nivel_educativo == 9

//changed "Universitario incompleto" from 10 to 8
replace nivel_educativo = 8 if nivel_educativo == 10

//changed "Universitario completo" from 11 to 9
replace nivel_educativo = 9 if nivel_educativo == 11

//changed "Postgrado incompleto" from 12 to 10
replace nivel_educativo = 10 if nivel_educativo == 12

//changed "Postgrado completo" from 13 to 11
replace nivel_educativo = 11 if nivel_educativo == 13

//changed "Ninguno" from 14 to 12
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


**********************************************************************************
* MAIN OCCUPATION
**********************************************************************************


/*
I changed:
1.  "Obrero" from 11 to 1
2.  "Empleado de nómina" from  ?  to 2   (not recoded here; already consistent)
3.  "Contratista (prestación servicios)" from ? to 3 (not recoded here; already consistent)
4.  "Empleado doméstico" from 13 to 4
5.  "Trabajador independiente" from 19 to 5
6.  "Profesional independiente" from 18 to 6
7.  "Patrón o empleador" from 20 to 7
8.  "Trabajo familiar (sin remuneración)" from 15 to 8
9.  "Trabajo desde la casa" unchanged (no original category mapped)
10. "Conductor/mensajero" from 14 to 10
11. "Estudia" from 1, 2, 3, 4, 5, and 35 to 13
12. "Dedicado al hogar" from 31 to 18
13. "Jubilado" from 32 to 19
14. "Buscar trabajo" from 33 to 20
15. "Incapacitado permanente" from 34 to 21
16. "Rentista" from 36 to 23
17. "Otra actividad" from 38 to 24
18. "No ocupado" from 37 to 25
19. "Vendedor informal" from 21 to 26
20. "Empleado público" from 17 to 27
21. "Empleado de empresa particular" from 16 to 28
22. "Jornalero/agricultor" from 12 to 29
*/


recode p6_id_ocupacion ///
    (11 = 1) (13 = 4) (19 = 5) (18 = 6) (20 = 7) (15 = 8) (14 = 10) ///
    (1 = 13) (2 = 13) (3 = 13) (4 = 13) (5 = 13) (31 = 18) (32 = 19) ///
    (33 = 20) (34 = 21) (35 = 13) (36 = 23) (38 = 24) (37 = 25) ///
    (21 = 26) (17 = 27) (16 = 28) (12 = 29), gen(ocupacion_new1)

drop p6_id_ocupacion

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
    13 "Estudia" ///
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
											

label variable ocupacion1 "Ocupación principal en la semana anterior"

label values ocupacion1 ocupacion_lbl


**********************************************************************************
* OTHER OCCUPATION
**********************************************************************************
 
recode p6_id_ocupacion_o1 ///
    (11 = 1) (13 = 4) (19 = 5) (18 = 6) (20 = 7) (15 = 8) (14 = 10) ///
    (1 = 13) (2 = 13) (3 = 13) (4 = 13) (5 = 13) (31 = 18) (32 = 19) ///
    (33 = 20) (34 = 21) (35 = 13) (36 = 23) (38 = 24) (37 = 25) ///
    (21 = 26) (17 = 27) (16 = 28) (12 = 29), gen(ocupacion_new2)

drop p6_id_ocupacion_o1

rename ocupacion_new2 ocupacion2

label variable ocupacion2 "Otra ocupación"

label values ocupacion2 ocupacion_lbl


**********************************************************************************
* OTHER OCCUPATION
**********************************************************************************


recode p6_id_ocupacion_o2 ///
    (11 = 1) (13 = 4) (19 = 5) (18 = 6) (20 = 7) (15 = 8) (14 = 10) ///
    (1 = 13) (2 = 13) (3 = 13) (4 = 13) (5 = 13) (31 = 18) (32 = 19) ///
    (33 = 20) (34 = 21) (35 = 13) (36 = 23) (38 = 24) (37 = 25) ///
    (21 = 26) (17 = 27) (16 = 28) (12 = 29), gen(ocupacion_new3)

drop p6_id_ocupacion_o2

rename ocupacion_new3 ocupacion3

label variable ocupacion3 "Otra ocupación"

label values ocupacion3 ocupacion_lbl


**********************************************************************************
* OTHER OCCUPATION
**********************************************************************************


recode p6_id_ocupacion_o3 ///
    (11 = 1) (13 = 4) (19 = 5) (18 = 6) (20 = 7) (15 = 8) (14 = 10) ///
    (1 = 13) (2 = 13) (3 = 13) (4 = 13) (5 = 13) (31 = 18) (32 = 19) ///
    (33 = 20) (34 = 21) (35 = 13) (36 = 23) (38 = 24) (37 = 25) ///
    (21 = 26) (17 = 27) (16 = 28) (12 = 29), gen(ocupacion_new4)

drop p6_id_ocupacion_o3

rename ocupacion_new4 ocupacion4

label variable ocupacion4 "Otra ocupación"

label values ocupacion4 ocupacion_lbl


**********************************************************************************
* GENDER
**********************************************************************************


gen mujer=.

replace mujer = 1 if sexo == "Mujer"
replace mujer = 0 if sexo == "Hombre"

drop sexo

label define mujer_lbl 0 "Hombre" 1 "Mujer"
label values mujer mujer_lbl

label variable mujer "1 si es mujer"


**********************************************************************************
* ECONOMIC ACTIVITY
**********************************************************************************


rename p7_id_actividad_economica actividad_economica1

/*
I changed:
1.  "Agricultura, ganadería, caza y silvicultura" from 1 to 1
2.  "Pesca" from 2 to 3
3.  "Explotación de minas y canteras" from 3 to 4
4.  "Industrias manufactureras" from 4 to 5
5.  "Suministro de electricidad, gas y agua" from 5 to 18
6.  "Construcción" from 6 to 6
7.  "Comercio al por mayor y al por menor de vehículos automotores, motocicletas, efectos personales y enseres domésticos" from 7 to 7
8.  "Hoteles y restaurantes" from 9 to 8
9.  "Transporte, almacenamiento y comunicaciones" from 8 and 10 to 9
10. "Intermediación financiera" from 11 to 10
11. "Actividades inmobiliarias, empresariales y de alquiler" from 12 to 11
12. "Administración pública y defensa, seguridad social de afiliación obligatoria" from 15 to 12
13. "Educación" from 16 to 13
14. "Servicios sociales y de salud" from 17 to 14
15. "Otras actividades de servicios comunitarios, sociales y personales" from 14, 18, and 19 to 15
16. "Hogares privados con servicio doméstico" from 20 to 16
17. "Organizaciones y órganos extraterritoriales" from 21 to 17
18. "Distribución de agua; evacuación y tratamiento de aguas residuales, gestión de desechos y actividades de saneamiento ambiental" from 5 to 18
19. "Actividades profesionales, científicas y técnicas" from 13 to 19
*/

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

**********************************************************************************************
* most labels here had to be searched over the booklets of questions attached. 
* The data dictionary was no well documented and did not show any info about these categories
**********************************************************************************************


**********************************************************************************
* PLACE OF ORIGIN
**********************************************************************************


rename p7v_lugar_inicio_dia lugar_origen

label define lugar_lbl 1 "Hogar" 2 "Otro"

label values lugar_origen lugar_lbl




cd "$dir_BDD_clean"

save "persona_clean.dta", replace

	
*******************************************************************************
* VIAJES MODULE describes the trips that each peson did around the city
******************************************************************************				


cd "$dir_BDD_2019"

import delimited "ViajesEODH2019.csv", clear


*********************************************************
// will drop all variables that are not of our interest
*********************************************************


drop hora_inicio_viaje p31_hora_llegada p33_aplicacion_antes_viaje p33_cual_aplicacion_antes_viaje p34_aplicacion_durante_viaje p34_cual_aplicacion_durante_viaj p35_otro_desplazamiento p36_hora_salida modo_principal modo_principal_desagregado fecha p29_id_municipio


*******************************************************************************************

// rename variables, add their proper label, and cast them into the data type they belong

*******************************************************************************************

*********************************************************
// IDs
*********************************************************

label variable id_hogar "id del hogar"

label variable id_persona "id de la persona"

label variable id_viaje "id del viaje"

*********************************************************
// PLACE OF ORIGIN
*********************************************************

label define lugar_lbl 1 "Hogar" 2 "Otro"

label values lugar_origen lugar_lbl

label variable lugar_origen "lugar de origen del viaje"

*********************************************************
// ZAT OF ORIGIN
*********************************************************

label variable zat_origen "zat origen"

*********************************************************
// REASON OF THE TRIP
*********************************************************

rename p17_id_motivo_viaje razon_viaje

label variable razon_viaje "motivo del viaje"

replace razon_viaje=. if razon_viaje==99

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
                             77 "Otro"

							 
label values razon_viaje razon_viaje_lbl

*********************************************************
// OTHER REASON
*********************************************************

rename p17_otro_motivo otro_motivo_viaje

label variable otro_motivo_viaje "otro movivo en str"

*********************************************************
// PLACE OF DESTINY
*********************************************************

rename p28_lugar_destino lugar_destino

label values lugar_destino lugar_lbl

label variable lugar_destino "lugar de destino del viaje"

*********************************************************
// ZAT OF DESTINY
*********************************************************

label variable zat_destino "zat destino"

*********************************************************
// BLOCKS WALKED
*********************************************************

rename p30_camino_cuadras camino_cuadras

destring camino_cuadras, replace

recast byte camino_cuadras

label variable camino_cuadras "Cantidad de cuadras caminadas después del medio de transporte"

*********************************************************
// MINUTES WALKED
*********************************************************

rename p30_camino_minutos camino_minutos

label variable camino_minutos "Cantidad de minutos caminadas después del medio de transporte"

*********************************************************
// THIS TRIP IS NORMALLY MADE THE DAYS:
*********************************************************

qui ds p32_*   // Lista todas las variables que empiezan con p32_

qui foreach var of varlist `r(varlist)' {
    local newname = substr("`var'", 5, .)   // Quita los primeros 4 caracteres "p32_"
    rename `var' `newname'
	
	label variable  `newname' "Realiza este viaje los `newname'"
	
	replace `newname' = 0 if missing(`newname')
}

cd "$dir_BDD_clean"

save "viaje_clean.dta", replace







