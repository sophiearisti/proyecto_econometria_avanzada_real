******************************************************************
*version 1: PENDIENTE
*ACA SE CORREN TODOS LOS OTROS DO FILES.
*esto con el objetivo de correr directamente todo 
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


*----------------------------------------------------------------------*

clear all
set more off

*2011
do "$dir_dofile_EODH/limpieza_2011.do"

do "$dir_dofile_EODH/merge_2011.do"

*2019
do "$dir_dofile_EODH/limpieza_2019.do"

do "$dir_dofile_EODH/merge_2019.do"

*2023
do "$dir_dofile_EODH/limpieza_2023.do"

do "$dir_dofile_EODH/merge_2023.do"
