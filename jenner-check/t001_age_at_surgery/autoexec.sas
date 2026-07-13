/* cap input rows for the captured run */
options obs=100;

/* Sample SURGERIES dataset standing in for LIBNAME PROJECT.SURGERIES.
   Column names, types, and the coded RACE/OUTCOME/CONDX domains match what
   the original Final_Bonanno.sas reads. Multiple surgery rows per patient. */
data SURGERIES;
  infile datalines dsd;
  input PT_ID EVENT_DATE :mmddyy10. AGE SEX $ RACE OUTCOME CONDX;
  format EVENT_DATE mmddyy10.;
datalines;
101,01/15/2018,54,M,9,0,201
101,06/20/2019,54,M,9,0,204
101,06/20/2019,54,M,9,0,207
102,03/02/2017,3,F,3,0,110
102,09/12/2017,3,F,3,0,110
103,11/05/2016,67,M,4,1,305
104,07/19/2018,42,F,9,0,201
104,07/19/2018,42,F,9,0,202
105,02/28/2015,78,F,8,1,410
106,05/14/2019,29,M,3,0,150
106,08/01/2020,29,M,3,0,152
107,10/10/2016,61,F,9,0,201
107,10/10/2016,61,F,9,0,205
108,04/22/2017,0,M,4,1,110
109,12/30/2018,50,F,2,0,305
109,01/15/2020,50,F,2,0,201
110,08/08/2019,73,M,9,1,410
111,06/11/2016,16,F,3,0,110
112,09/09/2018,35,M,9,0,201
112,09/09/2018,35,M,9,0,204
;
run;
