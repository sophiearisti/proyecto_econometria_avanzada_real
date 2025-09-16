********************************************************
//VERSION 1
//LIMPIEZA BDD 2015
********************************************************

cd "$dir_BDD_2015"


********************************************************
//limpieza de csv de datos del hogar
********************************************************

import delimited "ENCUESTAS_ANONIMIZADO.csv", clear

*********************************************************
//drop de variables que no se necesitan
*********************************************************

drop numero_hogares id_beneficiositp fecha_upload duracion encuesta_completa utcdif encuestador_fecha encuestador_hora estrato_energia estrato_acueducto estrato_alcantarillado estrato_recoleccion_basuras estrato_gas_natural id_beneficiositp2 id_beneficiositp3 id_beneficiositp4 persona1hogar persona2hogar persona3hogar persona4hogar persona5hogar persona6hogar persona7hogar persona8hogar persona9hogar supervision hora_fin finalizada srv_energia srv_acueducto srv_alcantarillado srv_recoleccion_basuras srv_gas_natural fecha_proceso_bd completa_telefonicamente vehic_personaidonea ponderador_calibrado factor_ajuste pi_* v59 fe_total dia_semana encuestas_sisben

*******************************************************
//renombrar variables para no volverme loca y hacer el casting apropiado de ellas
*******************************************************

rename barrio barrio_vivienda

label variable barrio_vivienda "Barrio/vereda"

rename id_tipovivienda tipo_vivienda

label variable tipo_vivienda "Tipo de la vivienda (casa, apartamento, cuarto en inquilinato, etc.)."

label define tipo_vivienda_lbl 1 "Casa" 2 "Apartamento" 3 "Cuarto(s) en inquilinato" 4 "Cuarto(s) en otro tipo de estructura" 5 "Otro tipo de vivienda"

replace tipo_vivienda=. if tipo_vivienda== 5739037

label values tipo_vivienda tipo_vivienda_lbl

rename id_viviendapropia tipo_propiedad_vivienda

label variable tipo_propiedad_vivienda "tipo de propiedad vivienda"

label define tipo_propiedad_vivienda_lbl 1 "Propia pagada" 2 "Propia pagando" 3 "Arriendo o subarriendo" 4 "En usufructo" 5 "Ocupante de hecho"

label values tipo_propiedad_vivienda tipo_propiedad_vivienda_lbl

rename numero_personas total_personas

label variable total_personas "Número total de personas que viven en el hogar."

rename id_rangoingresos ingreso

replace ingreso = . if ingreso == 9

label define ingreso_lbl ///
    1 "0 - 644.350" ///
    2 "644.351 - 1.300.000" ///
    3 "1.300.001 - 2.000.000" ///
    4 "2.000.001 - 2.800.000" ///
    5 "2.800.001 - 4.000.000" ///
    6 "4.000.001 - 5.500.000" ///
    7 "5.500.001 - 8.000.000" ///
    8 "Más de 8.000.000"

label values ingreso ingreso_lbl

replace latitud_hogar = ustrregexra(latitud_hogar, "[^0-9\.\-]", "") // deja solo números, punto y signo -

destring latitud_hogar, replace

label variable estrato  "estrato del hogar"

replace estrato=. if estrato== 67.46009063720703

replace clasificacion_sisben=. if clasificacion_sisben ==-1

replace puntaje_sisben=. if puntaje_sisben ==-1

cd "$dir_BDD_clean"

save "nuevo_MOD_Hogar.dta", replace

********************************************************
*Esta es la parte que indica los datos de la persona
*y de su movilizacion/viajes
*******************************************************

cd "$dir_BDD_2015"

import delimited "VIAJES_ANONIMIZADOS.csv", clear

*******************************************************
//haremos drop de variables que no nos importan
*******************************************************
drop ponderador_calibrado_viajes factor_ajuste_transmilenio fe_total pi_k_iii pi_k_ii pi_k_i ponderador_calibrado factor_ajuste imputacion zat_origen id_municipio_origen latitud_origen longitud_origen id_medio_predominante hora_fin hora_inicio dia_habil dia_nohabil pico_habil pico_nohabil valle_nohabil valle_habil diferencia_horas


*******************************************************
//renombrar variables para no volverme loca y hacer el casting apropiado de ellas
*******************************************************

rename id_motivoviaje razon_viaje

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

*dejar en una sola categoria 7 Buscar / Dejar alguien bajo su cuidad 8 Buscar / dejar a alguien que no esta bajo su c

replace razon_viaje=7 if razon_viaje==8

replace razon_viaje=8 if razon_viaje==9

replace razon_viaje=9 if razon_viaje==10

replace razon_viaje=10 if razon_viaje==11

replace razon_viaje=11 if razon_viaje==12

replace razon_viaje=12 if razon_viaje==13

replace razon_viaje=13 if razon_viaje==14

replace razon_viaje=77 if razon_viaje==89

label variable zat_destino "Zona de transporte destino de viaje"

rename tiempo_camino camino_minutos
label variable camino_minutos "Tiempo caminado"

cd "$dir_BDD_clean"

save "nuevo_MOD_viajeTipico.dta", replace


********************************************************
*Esta es la parte que indica los datos de la persona
*******************************************************
cd "$dir_BDD_2015"

import delimited "PERSONAS_ANONIMIZADO.csv", clear

*******************************************************
//haremos drop de variables que no nos importan
*******************************************************
drop id_cultura asiste_institucioneducativa id_mediotransporte3 id_mediotransporte2 id_mediotransporte id_cursolicencia4 id_cursolicencia3 id_cursolicencia2 id_cursolicencia uso_vehiculoprivado id_motivonovehiculo moviliza_bicicleta id_nobicicleta* reaccion_autoridad id_tipoagresion* id_agresionfisica* id_lugaragresion id_licenciaconduccion* victima_agresion fecha_proceso_bd reg_antiguo ponderador_calibrado factor_ajuste pi_k_i pi_k_ii pi_k_iii fe_total id_limitacionfisica* id_agresionsexual* numero_empleos

*******************************************************
//renombrar variables para no volverme loca y hacer el casting apropiado de ellas
*******************************************************

rename id_parentesco parentesco

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
                           15 "No parientes"

label values parentesco parentesco_lbl

rename id_sexo mujer

recode mujer (1=0) (2=1)

label variable mujer "=1 si mujer"

label define mujer_lbl 1 "Mujer" 0 "Hombre"

label values mujer mujer_lbl

label variable edad "Edad en años cumplidos"

rename id_niveleducativo nivel_educativo

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
					 
label values nivel_educativo educ_lbl

*LA VARIABLE OCUPACION TOCA TRATARLA DE OTRA FORMA PORQUE ESTA DIVIDIDA EN 2 SECCIONES
gen ocupacion1=.

//es obrero
replace ocupacion1=1 if id_trabajoactividad==1
//es empleado domestico
replace ocupacion1=4 if id_trabajoactividad==3
//es Trabajador independiente o por cuenta propia 
replace ocupacion1=5 if id_trabajoactividad==5
//es 04. Profesional independiente 
replace ocupacion1=6 if id_trabajoactividad==4
//es Patrón o empleador 
replace ocupacion1=7 if id_trabajoactividad==6
//es 08. Trabajador sin remuneración  09. Trabajador familiar sin remuneración (hijo o familiar de empleado doméstico, mayordomo, jornalero, etc.) 
replace ocupacion1=8 if id_trabajoactividad==8 | id_trabajoactividad==9
//es trabaja desde la casa
replace ocupacion1=9 if trabajo_casa==3
//es estudiante
replace ocupacion1=13 if id_actividad==3
//es dedicado al hogar
replace ocupacion1=18 if id_actividad==5
//es jubilado
replace ocupacion1=19 if id_actividad==7
//es jubilado
replace ocupacion1=20 if id_actividad==2
//es jubilado
replace ocupacion1=21 if id_actividad==6
//otra actividad
replace ocupacion1=24 if id_actividad==89
//empleado publico
replace ocupacion1=27 if id_trabajoactividad==2
//empresa particular
replace ocupacion1=28 if id_trabajoactividad==1
//empresa particular
replace ocupacion1=29 if id_trabajoactividad==10 | id_trabajoactividad==7

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

label variable ocupacion1 "principal ocupación semana anterior"

drop id_trabajoactividad id_actividad

recode trabajo_casa (-1=0) (3=1)

recode limitacion_fisica (1=1) (2=0)

rename limitacion_fisica limitaciones_fisicas

rename id_actividadeconomica actividad_economica1 

label variable actividad_economica1 "actividad económica ocupacion 1"

replace actividad_economica1=. if actividad_economica1==-1

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
    19 "Actividades profesionales, científicas y técnicas" ///
	89 "Otra actividad"

label values actividad_economica1 actividad1_lbl

cd "$dir_BDD_clean"

save "nuevo_MOD_persona.dta", replace

********************************************************
*Esta es la parte que indica los datos de las etapas de viajes
*******************************************************
cd "$dir_BDD_2015"

import delimited "ETAPAS.csv", clear

*******************************************************
//haremos drop de variables que no nos importan
*******************************************************
drop id_mediotrasporte id_minucipio minuto_espera costo_pasaje paradero ruta vehiculo_hogar estacion_vehiculo cuantia_pago modalidad_pago descenso imputacion ponderador_calibrado factor_ajuste pi_k_i pi_k_ii pi_k_iii fe_total factor_ajuste_transmilenio ponderador_calibrado_viajes idet etapas

rename cuadras camino_cuadras
label variable camino_cuadras "Cuadras caminadas"

rename minutos camino_minutos
label variable camino_minutos "Tiempo caminado"

cd "$dir_BDD_clean"

save "nuevo_MOD_etapas.dta", replace









