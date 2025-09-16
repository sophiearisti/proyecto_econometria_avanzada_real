******************************************************
*VERSION 3
*MERGE de los datos de la encuesta de movilidad del 2019
*tambien se limpiara aun mas la bdd, esto con el objetivo de dejar todo listo para crear los buffers
******************************************************

cd "$dir_BDD_2019"
cd "$dir_BDD_clean"

//personas 1 a muchos con viajes, llave foranea doble
//viajes 1 a muchas con etapas, foranea doble (no lo usare al final)
//hogares 1 a muchos con personas

use persona_clean.dta, clear

merge 1:m id_hogar id_persona using viaje_clean.dta

/*
. merge 1:m id_hogar id_persona using viaje_clean.dta
(label lugar_lbl already defined)

    Result                      Number of obs
    -----------------------------------------
    Not matched                        13,339
        from master                    13,339  (_merge==1)
        from using                          0  (_merge==2)

    Matched                           134,497  (_merge==3)
    -----------------------------------------

esta bien, porque hay personas que no estan en el modulo de viajes
*/

keep if _merge==3
drop _merge

merge m:1 id_hogar using origen_hogar_clean.dta

/*
nuevamente esta bien
. merge m:1 id_hogar using origen_hogar_clean.dta

    Result                      Number of obs
    -----------------------------------------
    Not matched                           628
        from master                         0  (_merge==1)
        from using                        628  (_merge==2)

    Matched                           152,310  (_merge==3)
    -----------------------------------------

en hogares no todos tienen info del viaje

*/

keep if _merge==3
drop _merge

**************************************************************
*vamos a borrar algunas variables redundantes y otras les cambiaremos el label
**************************************************************

//variables redundantes
drop nro_mapa utam factor municipio lugar_origen lugar_destino otro_motivo_viaje

//drop variables uqe en otra investigacion pueden servir pero aca no

drop parentesco f_exp id_viaje zat_origen mun_origen mun_destino utam_origen utam_destino estado sector seccion manzana barrio_vivienda latitud longitud zat_hogar vivienda localidad

//con esto solo nos quedamos con las razones de viaje de:
//Trabajar (1) y Buscar trabajo (13)
//lo otro se dropea

keep if inlist(razon_viaje, 1, 13)

/*
la persona pudo haber hecho varios viajes al mismo lugar, por la misma razon entonces esos no nos interesa
*/

duplicates report id_hogar id_persona zat_destino

duplicates drop id_hogar id_persona zat_destino, force   // borrar duplicados que tengan esa combinacion

duplicates report id_hogar id_persona zat_destino   // comprobar que ya no haya duplicados

//no me sirve si el viaje es ocasional
drop if ocasional==1

drop lunes martes miercoles jueves viernes sabado domingo ocasional

label variable id_hogar "ID del hogar"

label variable id_persona "ID de la persona"

label variable actividad_economica1 "actividad economica a la que se dedica"

*******************************************************************************
*GENERAR DUMMIES PARA LAS CATEGORICAS
*******************************************************************************
//actividad_economica1 tipo_vivienda tipo_propiedad_vivienda razon_viaje nivel_educativo ocupacion1 ocupacion2 ocupacion3 ocupacion4

//PARA actividad_economica1 tipo_vivienda tipo_propiedad_vivienda razon_viaje nivel_educativo usar la misma funcion 

//llamar a la funcion general que se creo en el main

makedummies actividad_economica1 tipo_vivienda tipo_propiedad_vivienda razon_viaje nivel_educativo

//para ocupacion1 ocupacion2 ocupacion3 ocupacion4, toca hacerlo CON OTRA FUNCION

makemultidummies ocupacion1 ocupacion2 ocupacion3 ocupacion4, genprefix(ocupacion1)

*******************************************************************************
*GENERAR DUMMIES PARA LA VARIABLE DEPENDIENTE
*******************************************************************************

//en formal pero no independiente
//(27) "Empleado público", (28) "Empleado de empresa particular" (7) "Patrón o empleador" 
gen formal_no_indep = .
replace formal_no_indep = 1 if inlist(ocupacion1,27,28,7) | inlist(ocupacion2,27,28,7) | inlist(ocupacion3,27,28,7) | inlist(ocupacion4,27,28,7)
replace formal_no_indep = 0 if !inlist(ocupacion1,27,28,7) & !inlist(ocupacion2,27,28,7) & !inlist(ocupacion3,27,28,7) & !inlist(ocupacion4,27,28,7)
label variable formal_no_indep "ocupacion Empleado público, Empleado de empresa particular, Patrón o empleador"

gen vendedor_informal = .
replace vendedor_informal = 1 if ocupacion2==26 | ocupacion1==26 | ocupacion3==26 |ocupacion4==26
replace vendedor_informal = 0 if ocupacion2!=26 & ocupacion1!=26 & ocupacion3!=26 & ocupacion4!=26
label variable vendedor_informal "ocupacion vendedor informal"

// (5) "Trabajador independiente"  (6) "Profesional independiente" 

* Dummy independientes
gen independiente_total = .
replace independiente_total = 1 if inlist(ocupacion1,5,6) | inlist(ocupacion2,5,6) | inlist(ocupacion3,5,6) | inlist(ocupacion4,5,6)
replace independiente_total = 0 if !inlist(ocupacion1,5,6) & !inlist(ocupacion2,5,6) & !inlist(ocupacion3,5,6) & !inlist(ocupacion4,5,6)
label variable independiente_total "ocupacion trabajador independiente"

gen independiente_trabajando = .
replace independiente_trabajando = 1 if (inlist(ocupacion1,5,6) | inlist(ocupacion2,5,6) | inlist(ocupacion3,5,6) | inlist(ocupacion4,5,6)) & razon_viaje==1
replace independiente_trabajando = 0 if !inlist(ocupacion1,5,6) & !inlist(ocupacion2,5,6) & !inlist(ocupacion3,5,6) & !inlist(ocupacion4,5,6)
label variable independiente_trabajando "trabajador independiente yendo a trabajar"

gen independiente_buscando = .
replace independiente_buscando = 1 if (inlist(ocupacion1,5,6) | inlist(ocupacion2,5,6) | inlist(ocupacion3,5,6) | inlist(ocupacion4,5,6)) & razon_viaje==13
replace independiente_buscando = 0 if !inlist(ocupacion1,5,6) & !inlist(ocupacion2,5,6) & !inlist(ocupacion3,5,6) & !inlist(ocupacion4,5,6)
label variable independiente_buscando "trabajador independiente yendo a buscar trabajo"	


//toca usar mejor motivo del viajes
//hay personas que tienen una ocupacion pero estan buscando trabajo
gen buscar_trabajo=.
replace buscar_trabajo = 1 if inlist(razon_viaje,13)
replace buscar_trabajo = 0 if !inlist(razon_viaje,13)
label variable buscar_trabajo "la persona busca trabajo"


gen desempleado=.
replace desempleado = 1 if inlist(ocupacion1,20) | inlist(ocupacion2,20) | inlist(ocupacion3,20) | inlist(ocupacion4,20)
replace desempleado = 0 if !inlist(ocupacion1,20) & !inlist(ocupacion2,20) & !inlist(ocupacion3,20) & !inlist(ocupacion4,20)
label variable desempleado "desempleado que dice que ocupacion es buscar trabajo"

//toca usar mejor motivo del viajes
//hay personas que no tienen una ocupacion pero estan  trabajando
gen con_trabajo=.
replace con_trabajo = 1 if !inlist(ocupacion1,13)
replace con_trabajo = 0 if inlist(ocupacion1,13)
label variable con_trabajo "empleado"

gen tot=1


gen a2019=1

label variable a2019 "=1 si ano 2019"

save "merge_2019.dta", replace
