**********************************************************
*VERSION 1
*MERGE de los datos de la encuesta de movilidad del 2023
*tambien se limpiara aun mas la bdd, esto con el objetivo de dejar todo listo para crear los buffers
**********************************************************
cd "$dir_BDD_2023"
cd "$dir_BDD_clean"

//los mismo aqui. toca hacer 2 merges

use "nuevo_MOD_persona.dta", clear

merge 1:m cod_per cod_hg using nuevo_MOD_viajes.dta

/*
. merge 1:m cod_per cod_hg using nuevo_MOD_viajes.dta
(label mujer_lbl already defined)

    Result                      Number of obs
    -----------------------------------------
    Not matched                        19,017
        from master                    19,017  (_merge==1)
        from using                          0  (_merge==2)

    Matched                           100,174  (_merge==3)
    -----------------------------------------

. 
end of do-file

esta bien la asociacion

*/

keep if _merge==3
drop _merge


merge m:1 cod_hg using nuevo_MOD_hogar.dta


/*
esta bien hay 1000 hogares que no tienen las otras encuestas

. merge m:1 cod_hg using nuevo_MOD_hogar.dta

    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,247
        from master                         0  (_merge==1)
        from using                      1,247  (_merge==2)

    Matched                           100,174  (_merge==3)
    -----------------------------------------
*/

keep if _merge==3
drop _merge

**************************************************************
*vamos a borrar algunas variables redundantes y otras les cambiaremos el label
**************************************************************

//variables redundantes o innecesarias
drop key_hg key_persona fexp_per5años cod_vj orden_vj zat_ori utam_ori upl_ori nom_mun_ori key_pers key_pers_viaja key_viaje localidad_ori orden cod_viv

//con esto solo nos quedamos con las razones de viaje de:
//A buscar trabajo, A trabajar [estan en str],  A realizar algún trámite personal
//lo otro se dropea
keep if strpos(motivo_viaje, "trabajar") | strpos(motivo_viaje, "buscar trabajo") | strpos(motivo_viaje, "trámite")

//solo dejar los que en ocupacion_principal sean:
//  Buscar trabajo, Empleado de empresa particular, Profesional independiente, Trabajador independiente, Vendedor informal, Patrón/empleador,  Trabajador sin remuneración

keep if strpos(ocupacion_principal, "Buscar trabajo") | ///
        strpos(ocupacion_principal, "Empleado de empresa particular") | ///
        strpos(ocupacion_principal, "Profesional independiente") | ///
        strpos(ocupacion_principal, "Trabajador independiente") | ///
        strpos(ocupacion_principal, "Vendedor informal") | ///
        strpos(ocupacion_principal, "Patrón/empleador") | ///
        strpos(ocupacion_principal, "Trabajador sin remuneración")
		
//quitar las actividades economicas que nada que ver con mi pregunta de investigacion
//Actividades artísticas, Actividades de atención de la salud,  Actividades de organizaciones, Actividades de servicios, Actividades financieras y de seguros, Actividades inmobiliarias, Administración pública y defensa, planes de seguridad social, Agricultura, Construcción, Distribución agua, Educación, Explotación de minas, Información y comunicaciones, Suministro de electricidad, Transporte y almacenamiento, No aplica

drop if strpos(actividad_economica, "Actividades artísticas") | ///
        strpos(actividad_economica, "Actividades de atención de la salud") | ///
        strpos(actividad_economica, "Actividades de organizaciones") | ///
        strpos(actividad_economica, "Actividades de servicios") | ///
        strpos(actividad_economica, "Actividades financieras y de seguros") | ///
        strpos(actividad_economica, "Actividades inmobiliarias") | ///
        strpos(actividad_economica, "Administración pública y defensa") | ///
        strpos(actividad_economica, "Agricultura") | ///
        strpos(actividad_economica, "Construcción") | ///
        strpos(actividad_economica, "Distribución de agua") | ///
        strpos(actividad_economica, "Educación") | ///
        strpos(actividad_economica, "Explotación de minas") | ///
        strpos(actividad_economica, "Información y comunicaciones") | ///
        strpos(actividad_economica, "Suministro de electricidad") | ///
        strpos(actividad_economica, "Transporte y almacenamiento") | ///
        strpos(actividad_economica, "No aplica")


//no me sirve si el viaje es ocasional o esporadico
//etiquetas: Esporádicamente en el año, En algunas ocasiones al mes, Nunca lo realizo
drop if strpos(frecuencia_viaje, "Esporádicamente en el año") | ///
        strpos(frecuencia_viaje, "En algunas ocasiones al mes") | ///
        strpos(frecuencia_viaje, "No aplica")

//generar dos variables multicolineales

gen formal = .
gen informal = .

label variable formal "ocupacion formal"

label variable informal "ocupacion informal"

* Formales
replace formal = 1 if strpos(ocupacion_principal, "Empleado de empresa particular") | ///
                     strpos(ocupacion_principal, "Patrón/empleador") | ///
                     strpos(ocupacion_principal, "Profesional independiente")

replace formal = 0 if ocupacion_principal != "Buscar trabajo" & missing(formal)

* Informales
replace informal = 1 if strpos(ocupacion_principal, "Trabajador independiente") | ///
                        strpos(ocupacion_principal, "Vendedor informal") | ///
                        strpos(ocupacion_principal, "Trabajador sin remuneración")

replace informal = 0 if ocupacion_principal != "Buscar trabajo" & missing(informal)


save "merge_2023.dta", replace


***************************************************************
*con esto haremos el collapse segun el ZAT
***************************************************************

//este se guardara en el data de los buffers porque con eso se crea el panel georeferenciado

//en este no vamos a tener en cuenta las siguientes vars  (las otras no las tendremos en cuenta y se desaparecen):
//mean mujer, mean edad, mean educacion, count formal, count informal

//me debe quedar un dato por zat 

preserve

gen max_nivel_edu_num = .

replace max_nivel_edu_num = 1 if max_nivel_edu == "Ninguno"
replace max_nivel_edu_num = 2 if max_nivel_edu == "Preescolar"
replace max_nivel_edu_num = 3 if max_nivel_edu == "Primaria incompleta"
replace max_nivel_edu_num = 4 if max_nivel_edu == "Primaria completa"
replace max_nivel_edu_num = 5 if max_nivel_edu == "Secundaria incompleta"
replace max_nivel_edu_num = 6 if max_nivel_edu == "Secundaria completa"
replace max_nivel_edu_num = 7 if max_nivel_edu == "Media incompleta (10° y 11°)"
replace max_nivel_edu_num = 8 if max_nivel_edu == "Media completa (10° y 11°)"
replace max_nivel_edu_num = 9 if max_nivel_edu == "Técnico/Tecnológico incompleta"
replace max_nivel_edu_num = 10 if max_nivel_edu == "Técnico/Tecnológico completa"
replace max_nivel_edu_num = 11 if max_nivel_edu == "Universitario incompleto"
replace max_nivel_edu_num = 12 if max_nivel_edu == "Universitario completo"
replace max_nivel_edu_num = 13 if max_nivel_edu == "Posgrado incompleto"
replace max_nivel_edu_num = 14 if max_nivel_edu == "Posgrado completo"

label define maxedu_lbl ///
    1 "Ninguno" ///
    2 "Preescolar" ///
    3 "Primaria incompleta" ///
    4 "Primaria completa" ///
    5 "Secundaria incompleta" ///
    6 "Secundaria completa" ///
    7 "Media incompleta (10° y 11°)" ///
    8 "Media completa (10° y 11°)" ///
    9 "Técnico/Tecnológico incompleta" ///
    10 "Técnico/Tecnológico completa" ///
    11 "Universitario incompleto" ///
    12 "Universitario completo" ///
    13 "Posgrado incompleto" ///
    14 "Posgrado completo"

label values max_nivel_edu_num maxedu_lbl
label variable max_nivel_edu_num "Máximo nivel educativo (ordenado)"


* colapsamos al nivel ZAT destino
collapse (mean) Mujer edad max_nivel_edu_num ///
         (sum) formal informal, by(zat_des)

cd "$dir_BDD_buffers"

save collapsed_2023.dta, replace

restore 

clear

		