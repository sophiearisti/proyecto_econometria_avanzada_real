**********************************************************
*VERSION 2
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
drop key_hg key_persona fexp_per5años cod_vj orden_vj zat_ori utam_ori upl_ori nom_mun_ori key_pers key_pers_viaja key_viaje localidad_ori orden cod_viv fexp_vj fexp_hg realiza_desplazamientos

//variables que para otra investigacion pueden servir, pero aca no 

drop nom_barrio_vereda_hg cod_barrio_vereda_hg tipo_zona_hg cod_dane_manzana_hg nom_loc_hg cod_loc_hg nom_mpio_hg cod_mpio_hg nom_upl_hg nom_utam_hg motivo_viaje_cuidado nom_mun_des localidad_des upl_des utam_des otro_vj zat_hg cod_utam_hg cod_upl_hg nom_mun_hg

//con esto solo nos quedamos con las razones de viaje de:
//A buscar trabajo, A trabajar [estan en str],  A realizar algún trámite personal
//lo otro se dropea
keep if inlist(razon_viaje, 1, 13)

/*
la persona pudo haber hecho varios viajes al mismo lugar, por la misma razon entonces esos no nos interesa
*/

duplicates report cod_per cod_hg zat_destino

duplicates drop cod_per cod_hg zat_destino, force   // borrar duplicados que tengan esa combinacion

duplicates report cod_per cod_hg zat_destino  // comprobar que ya no haya duplicados


//no me sirve si el viaje es ocasional o esporadico
//etiquetas: Esporádicamente en el año, En algunas ocasiones al mes, Nunca lo realizo

drop if strpos(frecuencia_viaje, "Esporádicamente en el año") | ///
        strpos(frecuencia_viaje, "Nunca") | ///
        strpos(frecuencia_viaje, "No aplica")
		
		
*******************************************************************************
*GENERAR DUMMIES PARA LAS CATEGORICAS
*******************************************************************************

makedummies actividad_economica1 ocupacion1 nivel_educativo razon_viaje tipo_vivienda

*******************************************************************************
*GENERAR DUMMIES PARA LA VARIABLE DEPENDIENTE
*******************************************************************************

gen formal_no_indep = .
replace formal_no_indep = 1 if inlist(ocupacion1,27,28,7)
replace formal_no_indep = 0 if !inlist(ocupacion1,27,28,7)
label variable formal_no_indep "ocupacion Empleado público, Empleado de empresa particular, Patrón o empleador"

gen vendedor_informal = .
replace vendedor_informal = 1 if ocupacion1==26 
replace vendedor_informal = 0 if ocupacion1!=26
label variable vendedor_informal "ocupacion vendedor informal"

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
replace con_trabajo = 1 if !inlist(ocupacion1,13)
replace con_trabajo = 0 if inlist(ocupacion1,13)
label variable con_trabajo "empleado"	

//para hacer el collapse y saber cant de personas en el zat
gen tot=1

gen a2023=1

label variable a2023 "=1 si ano 2023"

save "merge_2023.dta", replace	
