**********************************************************
*VERSION 1
*MERGE de los datos de la encuesta de movilidad del 2015
*tambien se limpiara aun mas la bdd, esto con el objetivo de dejar todo listo para crear los buffers
**********************************************************

cd "$dir_BDD_2015"
cd "$dir_BDD_clean"

use nuevo_MOD_viajeTipico.dta, clear

//id_encuesta es el id del hogar

merge m:1 id_encuesta numero_persona using nuevo_MOD_persona.dta

/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                        22,515
        from master                         0  (_m
> erge==1)
        from using                     22,515  (_m
> erge==2)

    Matched                           147,251  (_m
> erge==3)
    -----------------------------------------

esta bien, hay 22000 de los datos de las personas que no hacen match con la encuesta que verdaderamente nos importa; es decir, la que nos importa y nos indica el zat de destino es la que si se pudo llenar en su totalidad. 


*/

keep if _merge==3
drop _merge

//hacer merge con el data set de caracteristicas del hogar, este nos cuenta las caracteristicas del hogar
//este es un merge de 1 a 1 y se hace con orden

merge m:1 id_encuesta using nuevo_MOD_Hogar.dta

/*
. merge m:1 id_encuesta using nuevo_MOD_Hogar.dta

    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                           147,251  (_merge==3)
    -----------------------------------------
todo matched

*/

//en este caso lo que sucede es que ahi esta la info de cuadras y minutos caminados, por eso hacemos el merge con etapas

keep if _merge==3
drop _merge

/*merge 1:m numero_viaje numero_persona id_encuesta using nuevo_MOD_etapas.dta

keep if _merge==3
drop _merge*/

   
**************************************************************
*vamos a borrar algunas variables redundantes y otras les cambiaremos el label
**************************************************************


//con esto solo nos quedamos con las razones de viaje de:
//Trabajar (1) y Buscar trabajo (13)
//lo otro se dropea

keep if inlist(razon_viaje, 1, 13)

rename id_encuesta id_hogar


label variable id_hogar "ID del hogar"

/*
Como una persona puede hacer varios viajes el dia anterior y puede que al mismo destino, hay valores repetidos que no nos interesa
*/

duplicates report id_hogar numero_persona zat_destino

duplicates drop id_hogar numero_persona zat_destino, force   // borrar duplicados que tengan esa combinacion

duplicates report id_hogar numero_persona zat_destino   // comprobar que ya no haya duplicados

//variables que no usare
drop zat_hogar trabajo_casa realizo_desplazamiento  puntaje_sisben parentesco numero_viaje numero_persona longitud_hogar longitud_destino latitud_hogar latitud_destino id_municipio_destino id_municipio id_manzana id_hogar id clasificacion_sisben barrio_vivienda

//drop numero_etapa id_municipio_descenso

//NOTA LO QUE PASA ES QUE TRABAJR EN CASE ES IMPORTANTE, PERO EN OTRAS ENCUENTAS NO SE UTILIZA MUCHO, POR LO QUE NO SE SI VALE LA PENA TENERLO EN CUENTA
//SI SE QUIERE TENER EN CUENTA, SE DEBE DEJAR LOS QUE NO SALEN DE LA CASA Y TRABAJAN EN CASA PORQUE ESO TAMBIEN CUENTA

*******************************************************************************
*GENERAR DUMMIES PARA LAS CATEGORICAS
*******************************************************************************

makedummies nivel_educativo tipo_vivienda tipo_propiedad_vivienda razon_viaje ocupacion1 actividad_economica1

*******************************************************************************
*GENERAR DUMMIES PARA LA VARIABLE DEPENDIENTE
*******************************************************************************

//en formal pero no independiente
//(27) "Empleado público", (28) "Empleado de empresa particular" (7) "Patrón o empleador" 
gen formal_no_indep = .
replace formal_no_indep = 1 if inlist(ocupacion1,27,28,7)
replace formal_no_indep = 0 if !inlist(ocupacion1,27,28,7)

label variable formal_no_indep "ocupacion Empleado público, Empleado de empresa particular, Patrón o empleador"

// (5) "Trabajador independiente"  (6) "Profesional independiente" 

* Dummy independientes
gen independiente_total = .
replace independiente_total = 1 if inlist(ocupacion1,5,6)
replace independiente_total = 0 if !inlist(ocupacion1,5,6)

label variable independiente_total "ocupacion trabajador independiente"

gen independiente_trabajando = .
replace independiente_trabajando = 1 if inlist(ocupacion1,5,6) & razon_viaje==1
replace independiente_trabajando = 0 if !inlist(ocupacion1,5,6)
label variable independiente_trabajando "trabajador independiente yendo a trabajar"

gen independiente_buscando = .
replace independiente_buscando = 1 if inlist(ocupacion1,5,6) & razon_viaje==13
replace independiente_buscando = 0 if !inlist(ocupacion1,5,6)
label variable independiente_buscando "trabajador independiente yendo a buscar trabajo"	


//toca usar mejor motivo del viajes
//hay personas que tienen una ocupacion pero estan buscando trabajo
gen buscar_trabajo=.
replace buscar_trabajo = 1 if inlist(razon_viaje,13)
replace buscar_trabajo = 0 if !inlist(razon_viaje,13)
label variable buscar_trabajo "la persona busca trabajo"


gen desempleado=.
replace desempleado = 1 if inlist(ocupacion1,20)

replace desempleado = 0 if !inlist(ocupacion1,20)
label variable desempleado "desempleado que dice que ocupacion es buscar trabajo"

//toca usar mejor motivo del viajes
//hay personas que no tienen una ocupacion pero estan  trabajando
gen con_trabajo=.
replace con_trabajo = 1 if !inlist(razon_viaje,13)
replace con_trabajo = 0 if inlist(razon_viaje,13)
label variable con_trabajo "empleado"

gen tot=1


gen a2015=1

label variable a2015 "=1 si ano 2015"

save "merge_2015.dta", replace
