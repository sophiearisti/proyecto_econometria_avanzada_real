
********************************************************
* version 3:
* data cleaning for the 2011 mobility survey
*******************************************************

cd "$dir_BDD_2011"

********************************************************
* PART A e indicates the information for the typical households
*******************************************************

import delimited "MOD_A_ID_HOGAR_Tipico.csv", clear

*******************************************************
// will drop all variables that are not of our interest
*******************************************************

/*
P4_A, number of households that exist in a home, will be dropped

we already use: 

P5_A total number of people who live in the home
P6_A total number of people of 5 year or older who live in the home
*/

drop dia dia_mes mes nveh nvisita c_result tiposup enctador superv digita corte codif tel_3 p4_a verbaveh

drop veh*


*******************************************************************************************

//rename variables, add their proper label, and cast them into the data type they belong

*******************************************************************************************


label variable idm "Número consecutivo de base de predios"


*******************************************************************************************
// ESTRATO
******************************************************************************************* 


destring estrato, replace

recast byte estrato

levelsof estrato //ESTRATO 1 TO 6, 0 DOES NOT EXIST

label variable estrato  "estrato del hogar"

*******************************************************************************************
// TIPO PROPIEDAD DE LA VIVIENDA
******************************************************************************************* 


rename p7_a tipo_propiedad_vivienda

destring tipo_propiedad_vivienda, replace

recast byte tipo_propiedad_vivienda

label variable tipo_propiedad_vivienda "tipo de propiedad vivienda"

label define tipo_propiedad_vivienda_lbl 1 "Propia pagada" 2 "Propia pagando" 3 "Arriendo o subarriendo" 4 "En usufructo" 5 "Ocupante de hecho"

label values tipo_propiedad_vivienda tipo_propiedad_vivienda_lbl


*******************************************************************************************
// TYPE OF PROPERTY
******************************************************************************************* 


rename p3_a tipo_vivienda

destring tipo_vivienda, replace

recast byte tipo_vivienda

label variable tipo_vivienda "Tipo de vivienda donde reside este hogar"

label define tipo_vivienda_lbl 1 "Casa" 2 "Apartamento" 3 "Cuarto(s) en inquilinato" 4 "Cuarto(s) en otro tipo de estructura" 5 "Otro tipo de vivienda"

label values tipo_vivienda tipo_vivienda_lbl

*******************************************************************************************
// LOCALIDAD
******************************************************************************************* 

rename localida id_localidad_hogar
label variable id_localidad_hogar "Localidad donde reside este hogar"

rename upz id_upz_hogar
label variable id_upz_hogar  "upz del hogar"

rename barrio nom_barrio_hogar
label variable nom_barrio_hogar  "barrio del hogar"

rename predio id_predio_hogar
label variable id_predio_hogar  "predio del hogar"

rename mun id_mun_hogar
label variable id_mun_hogar "municipio del hogar"

rename zat zat_hogar

*******************************************************************************************
// MONTHLY EARNINGS IN COP
******************************************************************************************* 


label variable ingreso "Ingreso mensual del hogar en pesos colombianos"

replace ingreso = . if ingreso == 9

label define ingreso_lbl ///
    1 "0 - 535.600" ///
    2 "535.601 – 1.200.000" ///
    3 "1.200.001 – 2.000.000" ///
    4 "2.000.001 – 2.800.000" ///
    5 "2.800.001 – 4.000.000" ///
    6 "4.000.001 – 5.500.000" ///
    7 "5.500.001 – 8.000.000" ///
    8 "Más de 8.000.000"

label values ingreso ingreso_lbl


*******************************************************************************************
// TOTAL NUMBER OF PEOPLE WHO LIVE IN THE HOME
******************************************************************************************* 


rename p5_a total_personas

label variable total_personas "Número total de personas que viven en el hogar."

rename p6_a  total_personas_mas_5

label variable total_personas_mas_5 "Número de personas de 5 años y más que viven en el hogar."


*******************************************************************************************
// RENAME ID
******************************************************************************************* 


rename orden id_hogar

label variable id_hogar "ID del hogar"


*******************************************************************************************
// SAVE THE CLEANED DATA SET 
******************************************************************************************* 


cd "$dir_BDD_clean"

save "nuevo_MOD_Hogar.dta", replace


****************************************************************************************
* This is part B. This one has all data concerned with each person's movility and occupation 
******************************************************************************************

cd "$dir_BDD_2011"

import delimited "MOD_B_PERSONAS_Tipico.csv", clear

*******************************************************
//drop unimportant variables
*******************************************************

/*
dropped variables

P13_B ¿Tiene licencia de conducción ? (Pregunte solo a los integrantes del hogar
con 16 años o más)

P14_B El día de ayer realizó desplazamientos de duración mayor a 3 minutos ?

P15_B ¿La persona se encuentra en el hogar al momento de la encuesta ? (campo
de validación)

P16_B ¿Respondió módulos de viaje ?

P17_B ¿Cuántos viajes hizo ?

P5DIA_D Día de realización de la encuesta

P5MES_D Mes de realización de la encuesta

P5ANO_D Año de realización de la encuesta

P6DIR_D ¿Me puede decir la dirección del lugar donde inició su día ? (ni aparece)

P6TDIR_D Tipo de dirección

ZAT Zona de transporte de dónde inició su día

BARRIO_D Nombre del Barrio de dónde inició su día (para saber si trabaja en la casa?)

MUN_D Código del municipio dónde inició su día

P9HI_D ¿A qué hora salió por primera vez en el día? (hora)

P9MI_D ¿A qué hora salió por primera vez en el día? (minutos)

P10_D ¿Ayer utilizó vehículo privado como conductor?

P11_D ¿Por cuál motivo ?

HORARIO Habilita horario mayor a 24 horas

*/

drop p11_b p13_b p14_b p15_b p16_b p17_b p5dia_d p5mes_d p5ano_d p9hi_d p9mi_d p10_d p11_d horario p6tdir_d modifica

drop viaje*

drop *mujer


*******************************************************************************************

//rename variables, add their proper label, and cast them into the data type they belong

*******************************************************************************************
 
 
*******************************************************
// ID
*******************************************************


label variable id_perso "Número de orden de una persona dentro de la composición del hogar"

rename id_perso id_persona

rename orden id_hogar

label variable id_hogar "ID del hogar"


*******************************************************
//PARENTESCO
*******************************************************

rename p3_b parentesco

destring parentesco, replace

recast byte parentesco

label variable parentesco "Parentesco del integrante del hogar con el jefe(a) de este hogar"

label define parentesco_lbl 1 "Jefe" ///
                           2 "Cónyuge ó compañera(o)" ///
                           3 "Hijos" ///
                           4 "Nietos" ///
                           5 "Padres" ///
                           6 "Hermanos" ///
                           7 "Yerno o nuera" ///
                           8 "Abuelos" ///
                           9 "Suegros" ///
                           10 "Tíos" ///
                           11 "Sobrinos" ///
                           12 "Primos" ///
                           13 "Cuñados" ///
                           14 "Otros parientes" ///
                           15 "Servicio doméstico" ///
                           16 "Hijos servicio doméstico" ///
                           17 "No parientes"

label values parentesco parentesco_lbl


*******************************************************
// gender
******************************************************* 

rename p4_b mujer

destring mujer, replace

recast byte mujer

recode mujer (1=0) (2=1)

label variable mujer "=1 si mujer"

label define mujer_lbl 1 "Mujer" 0 "Hombre"

label values mujer mujer_lbl

*******************************************************
// age
*******************************************************

rename p5_b edad

destring edad, replace

recast byte edad

label variable edad "Edad en años cumplidos"


*******************************************************
// education level
*******************************************************

rename p6_b nivel_educativo

destring nivel_educativo, replace

recast byte nivel_educativo

label variable nivel_educativo "Maximo nivel educativo aprobado"

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
					 
replace nivel_educativo = . if nivel_educativo == 99

label values nivel_educativo educ_lbl


*******************************************************
//FIRST occupation
*******************************************************


rename p7_b ocupacion1

destring ocupacion1, replace

recast byte ocupacion1

label variable ocupacion1 "principal ocupación semana anterior"

* to make all surveys as comparable as possible


/*
I combined the categories of 
10: Conductor de bus/buseta/micro
11: Conductor de taxi
12: Mensajero

into a single one named "Conductor/mensajero"
*/


replace ocupacion1=10 if ocupacion1== 11 | ocupacion1== 12

/*
I combined the categories of 
13 "Estudiante en colegio o escuela" 
14 "Estudiante en Universidad - pregrado" 
15 "Estudiante en Universidad - postgrado" 
16 "Estudiante en Instituto técnico/tecnológico" 
17 "Estudiante en Instituto educación no formal"

into a single one named "Estudia"
*/


replace ocupacion1=13 if ocupacion1== 14 | ocupacion1== 15 | ocupacion1== 16 | ocupacion1== 17 | ocupacion1== 22

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


label values ocupacion1 ocupacion_lbl


*******************************************************
//SECOND occupation
*******************************************************


rename p8_b ocupacion2

destring ocupacion2, replace

recast byte ocupacion2

label variable ocupacion2 "segunda ocupación semana anterior"

label define ocupacion1_lbl 0 "No tiene ninguna otra ocupación", add

label values ocupacion2 ocupacion1_lbl

* same changes as before

replace ocupacion2=10 if ocupacion2== 11 | ocupacion2== 12

replace ocupacion2=13 if ocupacion2== 14 | ocupacion2== 15 | ocupacion2== 16 | ocupacion2== 17 | ocupacion2== 22


*******************************************************
//FIRST economic activity
*******************************************************


rename p9_b actividad_economica1 

destring actividad_economica1, replace

recast byte actividad_economica1

label variable actividad_economica1 "actividad económica ocupacion 1"

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

label values actividad_economica1 actividad1_lbl


*******************************************************
//SECOND economic activity
*******************************************************


rename p10_b actividad_economica2

destring actividad_economica2, replace

recast byte actividad_economica2

label variable actividad_economica2 "actividad económica ocupacion 2"

label values actividad_economica2 actividad1_lbl

replace actividad_economica2=. if actividad_economica1==99


*******************************************************
//ZAT origin
*******************************************************

rename zat zat_origen

label variable zat_origen "Zona de transporte de dónde inició su día"


*******************************************************
//neighbourhood origin
*******************************************************


rename barrio_d barrio_origen

label variable barrio_origen "Nombre del Barrio de dónde inició su día"

rename mun_d mun_origen

label variable mun_origen "Código del municipio dónde inició su día"

gen limitaciones_fisicas = cond(missing(p12_b), 0, 1)

label variable limitaciones_fisicas "=1 si tiene limitaciones fisicas"

drop p12_b


*******************************************************************************************
// SAVE THE CLEANED DATA SET 
******************************************************************************************* 


cd "$dir_BDD_clean"

save "nuevo_MOD_persona.dta", replace


********************************************************
* PART C is unimportant as it only talks about vehicles
*******************************************************


**************************************************************************************************************************************
*PART D describes the typical trips that each person does (if they told they have done any displacement during the past three days)
**************************************************************************************************************************************

cd "$dir_BDD_2011"

import delimited "MOD_D_VIAJES_Tipico.csv", clear

*******************************************************
//Drop of unimportant variables
*******************************************************

/*
P16_D Código municipio destino del viaje (origen del siguiente viaje)

E1_P1_D ¿Qué medio de transporte utilizó? (Etapa_1)

P19HI_D ¿A qué hora salió de…? hora militar

P19MI_D ¿A qué hora salió de ….?_minutos

P18HF_D ¿A qué hora llegó a…? hora militar

P18MF_D ¿A qué hora llegó a ….? minutos

P15TD_D Tipo de dirección

p14_d ¿Qué medios de transporte utilizó para ir a …? (pregunta de múltiple respuesta)

*/

drop p16_d p14_d p18hf_d p18mf_d p19hi_d p19mi_d p15td_d

drop e*

********************************************************************************************
// rename variables, add their proper label, and cast them into the data type they belong
********************************************************************************************


*******************************************************
//blocks walked
*******************************************************

rename p17c_d camino_cuadras
label variable camino_cuadras "Cuadras caminadas"


*******************************************************
//minutes walked
*******************************************************


rename p17m_d camino_minutos
label variable camino_minutos "Tiempo caminado"

*******************************************************
//person's id
*******************************************************

label variable id_perso "Número de orden de una persona dentro de la composición del hogar"


*******************************************************
//trip ID
*******************************************************


rename p12_d numero_viaje

destring numero_viaje, replace

recast byte numero_viaje

label variable numero_viaje "Número de viaje"


*******************************************************
//reason of the trip
*******************************************************

rename p13_d razon_viaje

destring razon_viaje, replace

recast byte razon_viaje

label variable razon_viaje "¿Qué fue a hacer?"

label define motivo_lbl 1 "Trabajar" ///
                        2 "Asuntos de trabajo" ///
                        3 "Estudiar" ///
                        4 "Recibir atención en salud" ///
                        5 "Ver a alguien" ///
                        6 "Volver a casa" ///
                        7 "Buscar/dejar a alguien" ///
                        8 "Buscar/dejar algo" ///
                        9 "Comer/tomar algo" ///
                        10 "Compras" ///
                        11 "Trámites" ///
                        12 "Recreación" ///
                        13 "Buscar trabajo" ///
                        77 "Otra cosa"

label values razon_viaje motivo_lbl



************************************************************************************************
//ZAT destiny
//this is the most relevent variable, as it will allow us to construct the dependent variable
************************************************************************************************


rename zat zat_destino

label variable zat_destino "Zona de transporte destino de viaje"


*******************************************************
//RENAME ID
*******************************************************


rename orden id_hogar

label variable id_hogar "ID del hogar"

rename id_perso id_persona


*******************************************************************************************
// SAVE THE CLEANED DATA SET 
******************************************************************************************* 


cd "$dir_BDD_clean"

save "nuevo_MOD_viajeTipico.dta", replace




