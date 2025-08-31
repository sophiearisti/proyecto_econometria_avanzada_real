**********************************************************
*VERSION 1
*MERGE de los datos de la encuesta de movilidad del 2011
*tambien se limpiara aun mas la bdd, esto con el objetivo de dejar todo listo para crear los buffers
**********************************************************


cd "$dir_BDD_2011"
cd "$dir_BDD_clean"

use nuevo_MOD_D.dta, clear

merge m:1 orden id_perso using nuevo_MOD_B.dta

/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                        20,831
        from master                         0  (_m
> erge==1)
        from using                     20,831  (_m
> erge==2)

    Matched                           100,846  (_m
> erge==3)
    -----------------------------------------

esta bien, hay 20000 de los datos de las personas que no hacen match con la encuesta que verdaderamente nos importa; es decir, la que nos importa y nos indica el zat de destino es la que si se pudo llenar en su totalidad. 

*/

keep if _merge==3
drop _merge

//hacer merge con el ultimo data set, este nos cuenta las caracteristicas del hogar
//este es un merge de 1 a 1 y se hace con orden

merge m:1 orden using nuevo_MOD_A.dta

//hay hogares que no estan en el dataset que nos importa, entonces no hay problema, por lo menos en el otro si se asocio todo
keep if _merge==3
drop _merge

**************************************************************
*vamos a borrar algunas variables redundantes y otras les cambiaremos el label
**************************************************************

//con esto solo nos quedamos con las razones de viaje de:
//Trabajar (1), Asuntos de trabajo (2), Trámites (11) y Buscar trabajo (13)
//lo otro se dropea

keep if inlist(razon_viaje, 1, 2, 11, 13)

rename orden id_hogar

//variables redundantes
drop zat mun 

//solo dejar los que en ocupacion 1 o en ocupacion 2 sean:
//  Empleado de nómina (1), Trabajador independiente (5), Profesional independiente (6), Patrón o empleador (7),  Buscar trabajo (20)

keep if inlist(ocupacion1, 1, 5, 6, 7, 20) | inlist(ocupacion2, 1, 5, 6, 7, 20)

//quitar las actividades economicas que nada que ver con mi pregunta de investigacion
drop if inlist(actividad_economica1, 1,2,3,5,6,8,9,10,11,12,13,14,16,17,99) & inlist(actividad_economica2, 1,2,3,5,6,8,9,10,11,12,13,14,16,17,99)

label variable id_hogar "ID del hogar"

label variable mujer "mujer=1"

//generar dos variables multicolineales

* Dummy formal
gen formal = .
replace formal = 1 if inlist(ocupacion1,1,7) | inlist(ocupacion2,1,7)
replace formal = 0 if inlist(ocupacion1,5,6) | inlist(ocupacion2,5,6)

label variable formal "ocupacion formal"

* Dummy informal
gen informal = .
replace informal = 1 if inlist(ocupacion1,5,6) | inlist(ocupacion2,5,6)
replace informal = 0 if inlist(ocupacion1,1,7) | inlist(ocupacion2,1,7)

label variable informal "ocupacion informal"

save "merge_2011.dta", replace

***************************************************************
*con esto haremos el collapse segun el ZAT
***************************************************************

//este se guardara en el data de los buffers porque con eso se crea el panel georeferenciado

//en este no vamos a tener en cuenta las siguientes vars  (las otras no las tendremos en cuenta y se desaparecen):
//mean mujer, mean edad, mean educacion, count formal, count informal

//me debe quedar un dato por zat 

preserve

* colapsamos al nivel ZAT destino
collapse (mean) mujer edad educacion ///
         (sum) formal informal, by(zat_destino)

cd "$dir_BDD_buffers"

save collapsed_2011.dta, replace

restore 

clear

