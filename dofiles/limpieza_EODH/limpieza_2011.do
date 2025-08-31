********************************************************
*version 1:
*limpieza datos de la encuesta de movilidad del 2011
*******************************************************

cd "$dir_BDD_2011"

********************************************************
*Esta es la parte A e indica literalmente los datos basicos del hogar tipico
*******************************************************

import delimited "MOD_A_ID_HOGAR_Tipico.csv", clear

*******************************************************
//haremos drop de variables que no nos importan
*******************************************************

local dropVars dia dia_mes mes nveh nvisita c_result tiposup enctador superv digita corte codif tel_3 p4_a p5_a p6_a p7_a verbaveh

foreach var of local dropVars {
    drop `var'
}

drop veh*

*******************************************************
//renombrar variables para no volverme loca y hacer el casting apropiedo de ellas
*******************************************************

label variable idm "Número consecutivo de base de predios"

destring estrato, replace

recast byte estrato

rename p3_a tipo_vivienda

destring tipo_vivienda, replace

recast byte tipo_vivienda

label variable tipo_vivienda "Tipo de vivienda donde reside este hogar"

label define tipo_vivienda_lbl 1 "Casa" 2 "Apartamento" 3 "Cuarto(s) en inquilinato" 4 "Cuarto(s) en otro tipo de estructura" 5 "Otro tipo de vivienda"

label values tipo_vivienda tipo_vivienda_lbl

rename localida localidad

label variable localidad "Localidad donde reside este hogar"

label variable ingreso "Ingreso mensual del hogar en pesos colombianos"

cd "$dir_BDD_clean"

save "nuevo_MOD_A.dta", replace

********************************************************
*Esta es la parte B e indica literalmente los datos de movilidad y la ocupacion
*******************************************************

cd "$dir_BDD_2011"

import delimited "MOD_B_PERSONAS_Tipico.csv", clear

*******************************************************
//haremos drop de variables que no nos importan
*******************************************************

local dropVars p11_b p12_b p13_b p14_b p15_b p16_b p17_b p5dia_d p5mes_d p5ano_d p9hi_d p9mi_d p10_d p11_d horario p6tdir_d modifica

foreach var of local dropVars {
    drop `var'
}

drop viaje*

drop *mujer

*******************************************************
//renombrar variables para no volverme loca y hacer el casting apropiado de ellas
*******************************************************

label variable id_perso "Número de orden de una persona dentro de la composición del hogar"

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

rename p4_b mujer

destring mujer, replace

recast byte mujer

recode mujer (1=0) (2=1)

label variable mujer "sexo"

label define mujer_lbl 1 "Mujer" 0 "Hombre"

label values mujer mujer_lbl

rename p5_b edad

destring edad, replace

recast byte edad

label variable edad "Edad en años cumplidos"

rename p6_b educacion

destring educacion, replace

recast byte educacion

label variable educacion "Maximo nivel educativo aprobado"

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
                     12 "Ninguno" ///
                     99 "No responde"

label values educacion educ_lbl


rename p7_b ocupacion1

destring ocupacion1, replace

recast byte ocupacion1

label variable ocupacion1 "principal ocupación semana anterior"

label define ocupacion_lbl 1 "Obrero" ///
                          2 "Empleado de nómina" ///
                          3 "Contratista (prestación servicios)" ///
                          4 "Empleado doméstico" ///
                          5 "Trabajador independiente" ///
                          6 "Profesional independiente" ///
                          7 "Patrón o empleador" ///
                          8 "Trabajo familiar (sin remuneración)" ///
                          9 "Trabajo desde la casa" ///
                          10 "Conductor de bus/buseta/micro" ///
                          11 "Conductor de taxi" ///
                          12 "Mensajero" ///
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
                          24 "Otra actividad"

label values ocupacion1 ocupacion_lbl

rename p8_b ocupacion2

destring ocupacion2, replace

recast byte ocupacion2

label variable ocupacion2 "segunda ocupación semana anterior"

label define ocupacion2_lbl 0 "No tiene ninguna otra ocupación" ///
                           1 "Obrero" ///
                           2 "Empleado de nómina" ///
                           3 "Contratista (prest servicios)" ///
                           4 "Empleado doméstico" ///
                           5 "Trabajador independiente" ///
                           6 "Profesional independiente" ///
                           7 "Patrón o empleador" ///
                           8 "Trabajo familiar (sin remuneración)" ///
                           9 "Trabajo desde la casa" ///
                           10 "Conductor de bus/buseta/micro" ///
                           11 "Conductor de taxi" ///
                           12 "Mensajero" ///
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
                           24 "Otra actividad"

label values ocupacion2 ocupacion2_lbl


rename p9_b actividad_economica1 

destring actividad_economica1, replace

recast byte actividad_economica1

label variable actividad_economica1 "actividad económica ocupacion 1"

label define actividad1_lbl 1 "Agricultura, ganadería, caza y silvicultura" ///
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
                           99 "No responde"

label values actividad_economica1 actividad1_lbl

rename p10_b actividad_economica2

destring actividad_economica2, replace

recast byte actividad_economica2

label variable actividad_economica2 "actividad económica ocupacion 2"

label values actividad_economica2 actividad1_lbl

rename zat zat_origen

label variable zat_origen "Zona de transporte de dónde inició su día"

rename barrio_d barrio_origen

label variable barrio_origen "Nombre del Barrio de dónde inició su día"

rename mun_d mun_origen

label variable mun_origen "Código del municipio dónde inició su día"

cd "$dir_BDD_clean"

save "nuevo_MOD_B.dta", replace

********************************************************La parte C no nos interesa porque literal es de vehiculos
*******************************************************

********************************************************Esta es la parte D e indica literalmente los datos basicos del hogar tipico
*******************************************************

cd "$dir_BDD_2011"

import delimited "MOD_D_VIAJES_Tipico.csv", clear

*******************************************************
//haremos drop de variables que no nos importan
*******************************************************

local dropVars p16_d p17c_d p14_d p17m_d p18hf_d p18mf_d p19hi_d p19mi_d p15td_d

foreach var of local dropVars {
    drop `var'
} 

drop e*

*******************************************************
//renombrar variables para no volverme loca y hacer el casting apropiado de ellas
*******************************************************

label variable id_perso "Número de orden de una persona dentro de la composición del hogar"

rename p12_d numero_viaje

destring numero_viaje, replace

recast byte numero_viaje

label variable numero_viaje "Número de viaje"

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

rename zat zat_destino

label variable zat_destino "Zona de transporte destino de viaje"

cd "$dir_BDD_clean"

save "nuevo_MOD_D.dta", replace






