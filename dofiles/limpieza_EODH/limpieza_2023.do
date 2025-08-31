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

replace estrato_hg = "0" if estrato_hg=="No aplica"

destring estrato_hg, replace

recast byte estrato_hg

label variable estrato_hg "estrato del hogar"

label variable cod_dane_manzana_hg "codigo manzana del hogar"

label variable tipo_zona_hg "urbano o centro poblado"

label variable cod_barrio_vereda_hg "codigo barrio o vereda del hogar"

label variable nom_barrio_vereda_hg "nombre barrio o vereda del hogar"

label variable nom_barrio_vereda_hg "nombre barrio o vereda del hogar"

label variable tipo_viv "tipo de vivienda"

label variable perstotal_hg "personas totales en el hogar"

label variable ingre_mes_hg "ingresos mensuales del hogar"

rename cod_hog cod_hg

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

local dropVars orien_sexual identidad_etnica madre_cab_familia quien_llevarecoge_establecimient cuidado_despues_regresar condicion_discapacidad dific_princ_medios_transp_discap licencia_cond_vigente posee_celular modo_principal_prepandemia modo_principal_pandemia razón_cambio_pandemia cambio_frecuencia_postpandemia cambio_modo_pico_placa cambio_modo_grandes_obra cambio_modo_seguridad acto_violencia_sexual lugar_violencia_sexual a_quien_acudio genero cuidado_entre_semana_discap rlcpd permanencia_entre_semana

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

gen Mujer=.

replace Mujer = 1 if sexo == "Mujer"
replace Mujer = 0 if sexo == "Hombre"

drop sexo

label define mujer_lbl 0 "Hombre" 1 "Mujer"
label values Mujer mujer_lbl

label variable Mujer "1 si es mujer"

label variable cod_per "codigo de la persona"

label variable cod_hg "codigo del hogar"

label variable nom_mun_hg "nombre municipio del hogar"

label variable cod_utam_hg "codigo UTAM del hogar"

label variable cod_upl_hg "codigo UPL del hogar"

label variable zat_hg "ZAT del hogar"

label variable edad "edad de la persona"

label variable max_nivel_edu "maximo nivel educativo"

label variable ocupacion_principal "ocupacion principal"

label variable actividad_economica "actividad economica"

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

gen Mujer=.

replace Mujer = 1 if sexo == "Mujer"
replace Mujer = 0 if sexo == "Hombre"

drop sexo

label define mujer_lbl 0 "Hombre" 1 "Mujer"
label values Mujer mujer_lbl

label variable Mujer "1 si es mujer"

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




