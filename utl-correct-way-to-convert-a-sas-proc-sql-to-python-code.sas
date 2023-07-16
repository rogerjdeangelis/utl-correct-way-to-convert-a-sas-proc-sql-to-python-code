%let pgm=utl-correct-way-to-convert-a-sas-proc-sql-to-python-code;

Converting SAS SQL to Python, WPS, R and Python

https://tinyurl.com/397nred6
https://stackoverflow.com/questions/76585951/correct-way-to-convert-a-sas-proc-sql-merge-to-python-code

Correct way to convert a sas proc sql merge to python code

  1 wps/sas code sql
  2 python sql
  3 R sql


Left join column bmi to class dataset drop Alice row and chage bmi in python wps sas and r

Problem add bmi column to sashelp.class,
Left join of sashelp.class and havBMI datsets

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

options validvarname=upcase;

libname sd1 "d:/sd1";

data sd1.have ;
  set sashelp.class(obs=5);
run;quit;

data sd1.havbmi(keep=name bmi);;
  set sashelp.class(obs=5);
  bmi=703 * WEIGHT / (HEIGHT * HEIGHT);
  if _n_=3 then bmi=.;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* Left join column bmi to have data and drop Alice row and subsitute 100 for missing BMI                                 */
/*                                                                                                                        */
/* SD1.HAVE total obs=5 16MAY2023:12:43:56                                                                                */
/*                                                                                                                        */
/* Obs     NAME      SEX    AGE    HEIGHT    WEIGHT                                                                       */
/*                                                                                                                        */
/*  1     Alfred      M      14     69.0      112.5                                                                       */
/*  2     Alice       F      13     56.5       84.0                                                                       */
/*  3     Barbara     F      13     65.3       98.0                                                                       */
/*  4     Carol       F      14     62.8      102.5                                                                       */
/*  5     Henry       M      14     63.5      102.5                                                                       */
/*                                                                                                                        */
/* SD1.HAVBMI total obs=5 16MAY2023:12:45:07                                                                              */
/*                                                                                                                        */
/* Obs     NAME        BMI                                                                                                */
/*                                                                                                                        */
/*  1     Alfred     16.6115                                                                                              */
/*  2     Alice      18.4986                                                                                              */
/*  3     Barbara      .                                                                                                  */
/*  4     Carol      18.2709                                                                                              */
/*  5     Henry      17.8703                                                                                              */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/

/**************************************************************************************************************************/
/*                                                              |                                                         */
/* WORK.WANT total obs=4 16MAY2023:12:56:22                     | RULES                                                   */
/*                                                              |                                                         */
/* Obs     NAME      SEX    AGE    HEIGHT    WEIGHT      BMI    |                                                         */
/*                                                              |                                                         */
/*  1     Alfred      M      14     69.0      112.5     16.612  | Alice row dropped                                       */
/*  2     Barbara     F      13     65.3       98.0    100.000  | ==> missing bmi changed to 100                          */
/*  3     Carol       F      14     62.8      102.5     18.271  |                                                         */
/*  4     Henry       M      14     63.5      102.5     17.870  |                                                         */
/*                                                              |                                                         */
/**************************************************************************************************************************/

proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

 proc sql;
   create
     table sd1.want as
   select
     l.*
    ,case
       when r.bmi = . then 100
       else bmi
     end as bmi
   from
     sd1.have as l left join sd1.havBMI as r
   on
     l.name = r.name
   where
     l.name ne 'Alice'
;quit;

proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

%utl_submit_wps64('
 libname sd1 "d:/sd1";
 options validvarname=any;
 proc sql;
   create
     table sd1.want as
   select
     l.*
    ,case
       when r.bmi = . then 100
       else bmi
     end as bmi
   from
     sd1.have as l left join sd1.havBMI as r
   on
     l.name = r.name
   where
     l.name ne "Alice"
;quit;
 proc print data=sd1.want;
 run;quit;;
');

/**************************************************************************************************************************/
/*                                                                                                                        */
/* The WPS System                                                                                                         */
/*                                                                                                                        */
/* Obs     NAME      SEX    AGE    HEIGHT    WEIGHT      bmi                                                              */
/*                                                                                                                        */
/*  1     Alfred      M      14     69.0      112.5     16.612                                                            */
/*  2     Barbara     F      13     65.3       98.0    100.000                                                            */
/*  3     Carol       F      14     62.8      102.5     18.271                                                            */
/*  4     Henry       M      14     63.5      102.5     17.870                                                            */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*----  NOT PYTHON PADS SAS STRINGS TO THE SAS LENGTH                   ----*/
/*----  IMPORTS & SQLITE STATEMENTS ARE NEEED FOR FUNCTIONS LIKE LOG    ----*/
/*----  NICE PROPERTIES OF PYTHON SQL                                   ----*/
/*----       1. OUTPUTS PANDA DATAFRAME                                 ----*/
/*----       2. HAS JUST ON TYPE OF MISSING (NOT 4 - BIG DEAL?)         ----*/
/*----       3. UNIVERAL LANGUAGE                                       ----*/

proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

 %utl_submit_wps64x('
   libname sd1 `d:\sd1`;
   proc python;

     export data=sd1.have python=have;
     export data=sd1.havbmi python=havbmi;

     submit;
     from os import path;
     import pandas as pd;
     import numpy as np;
     from pandasql import sqldf;
     mysql = lambda q: sqldf(q, globals());
     from pandasql import PandaSQL;
     pdsql = PandaSQL(persist=True);
     sqlite3conn = next(pdsql.conn.gen).connection.connection;
     sqlite3conn.enable_load_extension(True);
     sqlite3conn.load_extension(`c:/temp/libsqlitefunctions.dll`);
     mysql = lambda q: sqldf(q, globals());
     have["NAME"] = have["NAME"].astype("string");
     have["NAME"] = have["NAME"].str.strip();
     havbmi["NAME"] = havbmi["NAME"].astype("string");
     havbmi["NAME"] = havbmi["NAME"].str.strip();
     want = pdsql("""
       select
         l.*
        ,case
           when r.bmi not NULL then bmi
           else 100
         end as bmi
       from
         have as l left join havbmi as r
       on
         l.name = r.name
       where
         l.name <> \"Alice\"
       """);
         print(want);
endsubmit;
import data=sd1.want python=want;
run;quit;
proc print data=sd1.want;
run;quit;
');

/**************************************************************************************************************************/
/*                                                                                                                        */
/*                                                                                                                        */
/*                                                                                                                        */
/* Obs     NAME      SEX    AGE    HEIGHT    WEIGHT      BMI                                                              */
/*                                                                                                                        */
/*  1     Alfred      M      14     69.0      112.5     16.612                                                            */
/*  2     Barbara     F      13     65.3       98.0    100.000                                                            */
/*  3     Carol       F      14     62.8      102.5     18.271                                                            */
/*  4     Henry       M      14     63.5      102.5     17.870                                                            */
/*                                                                                                                        */
/**************************************************************************************************************************/

proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

%utl_submit_wps64('

   libname sd1 "d:\sd1";

   proc r;

     export data=sd1.have   r=have;
     export data=sd1.havbmi r=havbmi;

     submit;
     library(sqldf);
     want <- sqldf("
       select
         l.*
        ,case
           when r.bmi not NULL then bmi
           else 100
         end as bmi
       from
         have as l left join havbmi as r
       on
         l.name = r.name
       where
         l.name <> \"Alice\"
       ");
       want;

endsubmit;
import data=sd1.want r=want;
run;quit;
proc print data=sd1.want;
run;quit;
');

/**************************************************************************************************************************/
/*                                                                                                                        */
/* The WPS System                                                                                                         */
/*                                                                                                                        */
/*      NAME SEX AGE HEIGHT WEIGHT       bmi                                                                              */
/*                                                                                                                        */
/* 1  Alfred   M  14   69.0  112.5  16.61153                                                                              */
/* 2 Barbara   F  13   65.3   98.0 100.00000                                                                              */
/* 3   Carol   F  14   62.8  102.5  18.27090                                                                              */
/* 4   Henry   M  14   63.5  102.5  17.87030                                                                              */
/*                                                                                                                        */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/

/*        _       _           _               _   _                                            _ _             _
 _ __ ___| | __ _| |_ ___  __| |  _ __  _   _| |_| |__   ___  _ __    _ __ ___ _ __   ___  ___(_) |_ ___  _ __(_) ___  ___
| `__/ _ \ |/ _` | __/ _ \/ _` | | `_ \| | | | __| `_ \ / _ \| `_ \  | `__/ _ \ `_ \ / _ \/ __| | __/ _ \| `__| |/ _ \/ __|
| | |  __/ | (_| | ||  __/ (_| | | |_) | |_| | |_| | | | (_) | | | | | | |  __/ |_) | (_) \__ \ | || (_) | |  | |  __/\__ \
|_|  \___|_|\__,_|\__\___|\__,_| | .__/ \__, |\__|_| |_|\___/|_| |_| |_|  \___| .__/ \___/|___/_|\__\___/|_|  |_|\___||___/
                                 |_|    |___/                                 |_|

*/



https://github.com/rogerjdeangelis/utl-many-interfaces-to-python-open-code-and-within-datastep-fcmp-wps


https://github.com/rogerjdeangelis/utl-classic-transpose-by-index-variableid-and-value-in-sas-r-and-python
https://github.com/rogerjdeangelis/python_importing_sas_dataset_with_505_columns_and_100_thousand_rows
https://github.com/rogerjdeangelis/utl-AI-compute-the-distance-between-objects-in-an-image-python
https://github.com/rogerjdeangelis/utl-AI-remove-noise-from-an-image-python-opencv
https://github.com/rogerjdeangelis/utl-Python-import-standalone-sas-format-catalogs-and-export-to-R-dataframes
https://github.com/rogerjdeangelis/utl-a-sas-view-of-my-issues-with-python-and-r
https://github.com/rogerjdeangelis/utl-adding-text-to-an-existing-png-graphic-python-AI
https://github.com/rogerjdeangelis/utl-an-alternative-to-saspy-returning-filter-from-python-to-use-in-sas
https://github.com/rogerjdeangelis/utl-analyzing-mean-and-median-by-groups-in-sas-wps-r-python
https://github.com/rogerjdeangelis/utl-benchmarks-for-python-pyreadstat-vs-pandas-read_sas-for-inporting-sas7bdats
https://github.com/rogerjdeangelis/utl-bigint-longint-in-sas-r-and-python
https://github.com/rogerjdeangelis/utl-calculating-the-cube-root-of-minus-one-with-drop-down-to-python-symbolic-math-sympy
https://github.com/rogerjdeangelis/utl-comparison-between-python-and-sql-programming
https://github.com/rogerjdeangelis/utl-convert-excel-to-csv-by-dropping-down-to-r-or-python
https://github.com/rogerjdeangelis/utl-converting-sas-proc-rank-to-wps-python-r-sql
https://github.com/rogerjdeangelis/utl-converting-sas-proc-sql-code-to-r-and-python
https://github.com/rogerjdeangelis/utl-create-a-simple-n-percent-clinical-table-in-r-sas-wps-python-output-pdf-rtf-xlsx-html-list
https://github.com/rogerjdeangelis/utl-create-python-panda-dataframe-fow-a-154mb-csv-file-with-60-000-records-an-200-numeric-variables
https://github.com/rogerjdeangelis/utl-create-tables-from-xml-files-using-sas-wps-r-and-python
https://github.com/rogerjdeangelis/utl-creating-spss-tables-from-a-sas-datasets-using-sas-r-and-python
https://github.com/rogerjdeangelis/utl-dealing-with-missing-values-consitently-within-and-between-multiple-languages-sas-R-and-python
https://github.com/rogerjdeangelis/utl-drop-down-to-python-for-a-regression-sas-python-interface
https://github.com/rogerjdeangelis/utl-drop-down-using-dosubl-from-sas-datastep-to-wps-r-perl-powershell-python-msr-vb
https://github.com/rogerjdeangelis/utl-dropdown-from-SAS-and-run-proc-sql-like-code-in-R-and-Python
https://github.com/rogerjdeangelis/utl-evaluate-recursive-ackermann-function-in-SAS-and-Python
https://github.com/rogerjdeangelis/utl-excel-report-with-two-side-by-side-graphs-below_python
https://github.com/rogerjdeangelis/utl-exporting-python-panda-dataframes-to-wps-r-using-a-shared-sqllite-database
https://github.com/rogerjdeangelis/utl-extracting-hyperlinks-from-an-excel-sheet-python
https://github.com/rogerjdeangelis/utl-find-the-position-of-all-substrings-with-a-string-wps-sas-python-r
https://github.com/rogerjdeangelis/utl-first-and-last-row-by-group-in-sas-python-and-r
https://github.com/rogerjdeangelis/utl-forget-about-SAS-Viya-Python-can-read-sas7bdats-and-sas7bcats-directly
https://github.com/rogerjdeangelis/utl-four-ways-to-drop-down-from-sas-to-python-and-r
https://github.com/rogerjdeangelis/utl-how-to-find-longest-repetitive-sequence-in-a-string-in-sas-python
https://github.com/rogerjdeangelis/utl-importing-sas-tables-sas7bdats-and-sas7bcats-into-python-and-r-with-associared-format-catalogs
https://github.com/rogerjdeangelis/utl-intergrating-interactive-python-popup-checkboxes-with-sas-using-pyqt4-and-tkinter
https://github.com/rogerjdeangelis/utl-last-value-carried-backwards-using-mutate-dow-sql-in-wps-sas-r-python
https://github.com/rogerjdeangelis/utl-left-join-two-datasets-to-a-master-dataset-native-and-sql-using-wps-sas-r-and-python
https://github.com/rogerjdeangelis/utl-linear-regression-in-python-R-and-sas
https://github.com/rogerjdeangelis/utl-loading-a-small_50gb-sas-dataset-into-python-in-under-three-minutes
https://github.com/rogerjdeangelis/utl-merging-two-tables-without-any-common-column-data-in-r-python-and-sas
https://github.com/rogerjdeangelis/utl-minimmum-code-to-transpose-and-summarize-a-skinny-to-fat-with-sas-wps-r-and-python
https://github.com/rogerjdeangelis/utl-monty-hall-problem-r-sas-python
https://github.com/rogerjdeangelis/utl-mysql-queries-without-sas-using-r-python-and-wps
https://github.com/rogerjdeangelis/utl-ods-excel-update-excel-sheet-in-place-python
https://github.com/rogerjdeangelis/utl-optical-character-recognition-of-fuzzy-text-images-python-tesseract
https://github.com/rogerjdeangelis/utl-possible-issues-when-creating-sas-xport-files-from-python
https://github.com/rogerjdeangelis/utl-proc-summary-in-sas-R-and-python-sql
https://github.com/rogerjdeangelis/utl-programatically-execute-excel-vba-macro-using-sas-python
https://github.com/rogerjdeangelis/utl-python-AI-color-frequencies-in-an-image
https://github.com/rogerjdeangelis/utl-python-applying-sas-formats-located-in-external-sas-catalogs-to-imported-sas-tables
https://github.com/rogerjdeangelis/utl-python-base64-encode-and-decode-a-binary-execl-workbook-or-binary-file
https://github.com/rogerjdeangelis/utl-python-import-sas-catalogs-and-export-to-R-dataframe
https://github.com/rogerjdeangelis/utl-python-import-sas-sas7bdat-export-stata-file
https://github.com/rogerjdeangelis/utl-python-panda-dataframe-to-sas-dataset
https://github.com/rogerjdeangelis/utl-python-panda-dataframes-to-R-dataframes-and-SAS-V5-xport-files
https://github.com/rogerjdeangelis/utl-python-r-and-sas-sql-solutions-to-add-missing-rows-to-a-data-table
https://github.com/rogerjdeangelis/utl-python-r-import-a-subset-of-SAS-columns-from-sas7bdat-and-v5-export-files
https://github.com/rogerjdeangelis/utl-r-and-python-overlook-simple-elegant-sql-solutions
https://github.com/rogerjdeangelis/utl-reading-sas7bdats-and-wrting-SAS-V5-export-files-in-python
https://github.com/rogerjdeangelis/utl-runing-a-python-function-inside-your-drop-down-to-r
https://github.com/rogerjdeangelis/utl-running-a-python-or-R-function-within-a-datastep
https://github.com/rogerjdeangelis/utl-running-a-wep-app-on-a-local-web-server-using-python-flask
https://github.com/rogerjdeangelis/utl-sas-fcmp-hash-stored-programs-python-r-functions-to-find-common-words
https://github.com/rogerjdeangelis/utl-sas-integration-of-ceasar-and-vigenere-ciphers-in-python
https://github.com/rogerjdeangelis/utl-sas-macro-utl-submit-py64-310-drop-down-to-python
https://github.com/rogerjdeangelis/utl-sas-proc-transpose-in-sas-r-wps-python-native-and-sql-code
https://github.com/rogerjdeangelis/utl-sas-proc-transpose-wide-to-long-in-sas-wps-r-python-native-and-sql
https://github.com/rogerjdeangelis/utl-scraping-a-single-indirect-html-reference-using-python-beautiful-soup-and-request-packages
https://github.com/rogerjdeangelis/utl-solving-a-simple-and-complex-non-linear-equation-using-python-and-r
https://github.com/rogerjdeangelis/utl-sqlite-processing-in-python-with-added-math-and-stat-functions
https://github.com/rogerjdeangelis/utl-strong-reversible-encryption-with-secret-key-python
https://github.com/rogerjdeangelis/utl-summarizing-data-in-SAS-WPS-Python-R-using-native-code-and-sql
https://github.com/rogerjdeangelis/utl-transpose-fat-to-skinny-pivot-longer-in-sas-wps-r-pythonv
https://github.com/rogerjdeangelis/utl-universal-language-translator-using-python-package-googletrans
https://github.com/rogerjdeangelis/utl-update-an-existing-excel-named-range-R-python-sas
https://github.com/rogerjdeangelis/utl-using-cross-platform-R-or-python-to-zip-and-unzip-folders
https://github.com/rogerjdeangelis/utl-validate-email-address-and-domain-python
https://github.com/rogerjdeangelis/utl-very-simple-sql-join-and-summary-in-python-r-wps-and-sas
https://github.com/rogerjdeangelis/utl-zip-and-unzip-a-folder-of-files-in-R-and-Python
https://github.com/rogerjdeangelis/utl_3D_scatter_plots_in_SAS_Python_and_R
https://github.com/rogerjdeangelis/utl_SAS_dataset_to_json_using_SAS_R_Python_and_WPS
https://github.com/rogerjdeangelis/utl_WPS_SAS_python_to_simplify_algebraic_equations
https://github.com/rogerjdeangelis/utl_adding_math_formulas_using_latex_in_r_and_python
https://github.com/rogerjdeangelis/utl_benchmarks_for_loops_in_sas_wps_python_perl_r
https://github.com/rogerjdeangelis/utl_cropping_images_SAS_and_Python
https://github.com/rogerjdeangelis/utl_fun_with_python_and_the_game_of_life_intro_to_animation
https://github.com/rogerjdeangelis/utl_github_interface_for_traffic_analysis_using_Python_and_SAS
https://github.com/rogerjdeangelis/utl_how_to_draw_a_sierpinski_carpet_in_python_using_turtle
https://github.com/rogerjdeangelis/utl_interactive_checkbox_input_using_python_tkinter_to_subset_sas_dataset
https://github.com/rogerjdeangelis/utl_interface_Per_Python_R32_R64_MS_r64_WPS
https://github.com/rogerjdeangelis/utl_interface_python_and-sas
https://github.com/rogerjdeangelis/utl_partition_a_list_of_numbers_into_3_groups_that_have_the_similar_sums_python
https://github.com/rogerjdeangelis/utl_pass_data_to_from_perl_R_python
https://github.com/rogerjdeangelis/utl_programatically_execute_excel_macro_using_wps_proc_python
https://github.com/rogerjdeangelis/utl_python_safe_encrypting_and_decrypting_PII_in_SAS_WPS_tables
https://github.com/rogerjdeangelis/utl_sas_python_interactive_checkbox_input_to_sas
https://github.com/rogerjdeangelis/utl_symbolic_differential_integral_and_algebraic_mathematics_in_R_and_Python
https://github.com/rogerjdeangelis/utl_wps_python_read_write_sas_tables
