********************************************************
*version 1:
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

local dropVars fecha tipo_enc pers5años_hg pers18años_hg cómo_enteró cant_hg_viv

foreach var of local dropVars {
    drop `var'
}

*******************************************************
//renombrar variables para no volverme loca y hacer el casting apropiedo de ellas
*******************************************************

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

label variable cod_dane_manzana_hg "codigo manzana del hogar"

label variable tipo_zona_hg "urbano o centro poblado"

label variable cod_barrio_vereda_hg "codigo barrio o vereda del hogar"

label variable nom_barrio_vereda_hg "nombre barrio o vereda del hogar"

label variable nom_barrio_vereda_hg "nombre barrio o vereda del hogar"

label variable tipo_viv "tipo de vivienda"

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
    10 ">9000000" ///

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

gen discapacidad = cond(condicion_discapacidad == "Ninguna", 0, 1)

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
replace nivel_educativo = 4  if inlist(max_nivel_edu, "Secundaria incompleta", "Media incompleta (10° y 11°)")
replace nivel_educativo = 5  if inlist(max_nivel_edu, "Secundaria completa", "Media completa (10° y 11°)")
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
replace ocupacion1 = 1 if strpos(ocupacion_principal, "Colegio o escuela")
replace ocupacion1 = 2 if strpos(ocupacion_principal, "Universidad") & strpos(ocupacion_principal, "Pregrado")
replace ocupacion1 = 3 if strpos(ocupacion_principal, "Universidad") & strpos(ocupacion_principal, "Posgrado")
replace ocupacion1 = 4 if strpos(ocupacion_principal, "Inst Técnico") | strpos(ocupacion_principal, "Inst Técnico / Tecnológico")
replace ocupacion1 = 5 if strpos(ocupacion_principal, "Inst educación no formal")

* Trabajadores
replace ocupacion1 = 11 if strpos(ocupacion_principal, "Obrero")
replace ocupacion1 = 12 if strpos(ocupacion_principal, "Jornalero") | strpos(ocupacion_principal, "agricultor")
replace ocupacion1 = 13 if strpos(ocupacion_principal, "Empleado doméstico")
replace ocupacion1 = 14 if strpos(ocupacion_principal, "Conductor") | strpos(ocupacion_principal, "mensajero")
replace ocupacion1 = 15 if strpos(ocupacion_principal, "Trabajador sin remuneración")
replace ocupacion1 = 16 if strpos(ocupacion_principal, "Empleado de empresa particular")
replace ocupacion1 = 17 if strpos(ocupacion_principal, "Empleado público")
replace ocupacion1 = 18 if strpos(ocupacion_principal, "Profesional independiente")
replace ocupacion1 = 19 if strpos(ocupacion_principal, "Trabajador independiente")
replace ocupacion1 = 20 if strpos(ocupacion_principal, "Patrón") | strpos(ocupacion_principal, "empleador")
replace ocupacion1 = 21 if strpos(ocupacion_principal, "Vendedor informal")

* Condiciones de inactividad
replace ocupacion1 = 31 if strpos(ocupacion_principal, "Dedicado al hogar")
replace ocupacion1 = 32 if strpos(ocupacion_principal, "Jubilado") | strpos(ocupacion_principal, "pensionado")
replace ocupacion1 = 33 if strpos(ocupacion_principal, "Buscar trabajo")
replace ocupacion1 = 34 if strpos(ocupacion_principal, "Incapacitado permanente")
replace ocupacion1 = 35 if strpos(ocupacion_principal, "Va a jardín")
replace ocupacion1 = 36 if strpos(ocupacion_principal, "Rentista")
replace ocupacion1 = 37 if strpos(ocupacion_principal, "No ocupado")
replace ocupacion1 = 38 if strpos(ocupacion_principal, "Otra actividad")


* Definir etiquetas
label define ocupacion_lbl 1  "Colegio o escuela" ///
                            2  "Universidad - Pregrado" ///
                            3  "Universidad - Posgrado" ///
                            4  "Inst. Técnico / Tecnológico" ///
                            5  "Inst. educación no formal" ///
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

label values ocupacion1 ocupacion_lbl

label variable ocupacion1 "ocupacion principal"

drop ocupacion_principal

gen actividad = .

replace actividad = 1  if actividad_economica == "Agricultura, ganadería, caza, silvic.."
replace actividad = 2  if actividad_economica == "Explotación de minas y canteras"
replace actividad = 3  if actividad_economica == "Industrias manufactureras"
replace actividad = 4  if actividad_economica == "Suministro de electricidad, gas, vap.."
replace actividad = 5  if actividad_economica == "Distribución agua, evacuación tratam.."
replace actividad = 6  if actividad_economica == "Construcción"
replace actividad = 7  if actividad_economica == "Comercio al por mayor y al por menor.."
replace actividad = 8  if actividad_economica == "Transporte y almacenamiento"
replace actividad = 9  if actividad_economica == "Alojamiento y servicios de comida"
replace actividad = 10 if actividad_economica == "Información y comunicaciones"
replace actividad = 11 if actividad_economica == "Actividades financieras y de seguros"
replace actividad = 12 if actividad_economica == "Actividades inmobiliarias"
replace actividad = 13 if actividad_economica == "Actividades profesionales, científic.."
replace actividad = 14 if actividad_economica == "Actividades de servicios administrat.."
replace actividad = 15 if actividad_economica == "Administración pública y defensa; pl.."
replace actividad = 16 if actividad_economica == "Educación"
replace actividad = 17 if actividad_economica == "Actividades de atención de la salud .."
replace actividad = 18 if actividad_economica == "Actividades artísticas, de entreteni.."
replace actividad = 19 if actividad_economica == "Otras actividades de servicios"
replace actividad = 20 if actividad_economica == "Actividades hogares individuales cal.."
replace actividad = 21 if actividad_economica == "Actividades de organizaciones y enti.."

* "No aplica" → missing
replace actividad = . if actividad_economica == "No aplica"

* Definir etiquetas
label define actividad_lbl 1  "Agricultura, ganadería, caza y silvicultura" ///
                           2  "Explotación de minas y canteras" ///
                           3  "Industrias manufactureras" ///
                           4  "Suministro de electricidad, gas, vapor y aire acondicionado" ///
                           5  "Distribución de agua; evacuación y tratamiento de aguas residuales, gestión de desechos y actividades de saneamiento ambiental" ///
                           6  "Construcción" ///
                           7  "Comercio al por mayor y al por menor; reparación de vehículos automotores y motocicletas" ///
                           8  "Transporte y almacenamiento" ///
                           9  "Alojamiento y servicios de comida" ///
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
                           21 "Actividades de organizaciones y entidades extraterritoriales" ///
                           99 "Sin información"

label values actividad actividad_lbl


label variable actividad "actividad economica"

drop actividad_economica

rename actividad actividad_economica

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

local dropVars hora_ini hora_fin duracion_min t_acceso_min t_espera_min t_egreso_min modo_principal_agrupado modo_principal_desagrupado etapas app_antes_vj app_durante_vj genero orien_sexual identidad_etnica madre_cab_familia

foreach var of local dropVars {
    drop `var'
}

*******************************************************
//renombrar variables para no volverme loca y hacer el casting apropiedo de ellas
*******************************************************

label variable cod_hg "codigo del hogar"

replace estra_hg = "0" if estra_hg=="No aplica"

destring estra_hg, replace

recast byte estra_hg

label variable estra_hg "estrato del hogar"

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
label variable zat_des "ZAT de destino"
label variable utam_des "UTAM de destino"
label variable upl_des "UPL de destino"
label variable localidad_des "Localidad de destino"
label variable nom_mun_des "Nombre municipio de destino"

* Motivo y frecuencia del viaje
label variable motivo_viaje "Motivo principal del viaje"
label variable motivo_viaje_cuidado "Motivo relacionado con cuidado"
label variable frecuencia_viaje "Frecuencia del viaje"

* Datos personales
label variable edad "Edad de la persona"
label variable max_nivel_edu "Máximo nivel educativo alcanzado"
label variable ocupacion_principal "Ocupación principal"

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




