******************************************************************
*version 3:
*ACA SE CORREN TODOS LOS OTROS DO FILES.
*esto con el objetivo de correr directamente todo y modularizar responzabilidades
*****************************************************************

*--------------Directorios --------------------------------------------*
global global_dir "/Users/sophiaaristizabal/Desktop/1 economia/7/econometría avanzada/proyecto_econometria_avanzada"

global dir_data "$global_dir/data/EODH"
global dir_dofile "$global_dir/dofiles" //dirección de los dofiles
global dir_dofile_EODH "$dir_dofile/limpieza_EODH"
global dir_BDD_2011 "$dir_data/sample 2011"
global dir_BDD_2019 "$dir_data/sample 2019"
global dir_BDD_2023 "$dir_data/sample 2023"
global dir_BDD_clean "dta_limpios"
global dir_BDD_buffers "$global_dir/data/buffer_data"
global dir_reg_dif_med_results "$global_dir/data/reg_dif_med_results"

*----------------------------------------------------------------------*

clear all
set more off

/*
ESTA FUNCION RECIBE UNA LISTA DE VARIABLES CATEGORICAS Y CREA SUS RESPECTIVAS DUMMIES
*/
capture program drop makedummies
program define makedummies
    syntax varlist
    foreach v of varlist `varlist' {
        quietly levelsof `v', local(cats)
        foreach c of local cats {
            gen byte `v'_d`c' = (`v' == `c')
        }
    }
end


/*
ESTA FUNCION RECIBE UNA LISTA DE VARIABLES CATEGORICAS QUE REPRESENTAN LO MISMO (IMPLICAN QUE UNA PERSONA PUEDE SER VARIAS CATEGORIAS). CONVIERTE CADA CATEGORIA EN UNA DUMMY Y PONE EN 1 SI EN ALGUNA DE LAS VARIABLES LA PERSONA TIENE ESA CATEGORIA (ES UN OR)
*/
capture program drop makemultidummies
program define makemultidummies
    syntax varlist, genprefix(string)

    * Tomamos solo la primera variable para extraer categorías
    local first : word 1 of `varlist'
    quietly levelsof `first', local(cats)

    * Creamos dummies para cada categoría
    foreach c of local cats {
        gen `genprefix'_d`c' = 0
        foreach v of varlist `varlist' {
            replace `genprefix'_d`c' = 1 if `v' == `c'
        }
    }
end



*2011
do "$dir_dofile_EODH/limpieza_2011.do"

do "$dir_dofile_EODH/merge_2011.do"

*2019
do "$dir_dofile_EODH/limpieza_2019.do"

do "$dir_dofile_EODH/merge_2019.do"

*2023
do "$dir_dofile_EODH/limpieza_2023.do"

do "$dir_dofile_EODH/merge_2023.do"

*dif medias entre cohortes para ver homogeneidad cortes transversales
*aca tambien se crean los buffers iniciales 
do "$dir_dofile_EODH/dif_medias_entre_anos.do"
