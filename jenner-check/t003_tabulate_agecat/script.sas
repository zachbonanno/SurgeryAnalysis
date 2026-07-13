/* Age-category banding + PROC TABULATE from Final_Bonanno.sas.
   Builds one record per patient (EVENT1_2), bands age at first surgery into the
   eight AGECAT groups, defines the RACE/AGE value formats, and cross-tabulates
   RACE by age category with PROC TABULATE.
   Reads SURGERIES + SMOKING provided by autoexec.sas.
   (The upstream ODS RTF FILE= destination is omitted so the table renders to the
   standard listing; the TABULATE request itself is unchanged.) */
TITLE1 'PHST 620 Final Project Bonanno';

PROC SORT DATA=SURGERIES;
	BY PT_ID EVENT_DATE;
RUN;

DATA SURGERIES2;
	SET SURGERIES;
	BY PT_ID EVENT_DATE;
	RETAIN BASE_AGE BASE_DATE;

	IF FIRST.PT_ID THEN
		DO;
			BASE_AGE=AGE;
			BASE_DATE=EVENT_DATE;
		END;
	AGE=BASE_AGE +((EVENT_DATE-BASE_DATE)/365.25);
RUN;

PROC SORT DATA=SURGERIES2;
	BY PT_ID;
RUN;

PROC SORT DATA=SMOKING;
	BY PT_ID;
RUN;

DATA COMPLETE;
	MERGE SURGERIES2 (IN=A) SMOKING (IN=B);
	BY PT_ID;

	IF A AND B;
	KEEP PT_ID EVENT_DATE SEX AGE RACE OUTCOME CONDX HOSMKG;
RUN;

DATA EVENT1;
	SET COMPLETE;
	BY PT_ID;

	IF FIRST.PT_ID;
RUN;

DATA EVENT1_2;
	SET EVENT1;
	BY PT_ID;

	IF FIRST.PT_ID;

	IF AGE < 1 THEN
		AGECAT=1;
	ELSE IF AGE>=1 AND AGE <5 THEN
		AGECAT=2;
	ELSE IF AGE>=5 AND AGE <18 THEN
		AGECAT=3;
	ELSE IF AGE>=18 AND AGE <30 THEN
		AGECAT=4;
	ELSE IF AGE>=30 AND AGE <50 THEN
		AGECAT=5;
	ELSE IF AGE>=50 AND AGE <65 THEN
		AGECAT=6;
	ELSE IF AGE>=65 AND AGE<75 THEN
		AGECAT=7;
	ELSE IF AGE>=75 THEN
		AGECAT=8;
RUN;

PROC FORMAT;
	VALUE RACE_FRM 1='Native American' 2='Native American' 3='Afr Amer (non-Hisp)'
		4='Hispanic' 8='Asian' 9='White(non-Hisp)';
	VALUE AGE_FRM 1='under 1' 2='1 -under 5' 3='5 -under 18' 4='18 -under 30'
		5='30 -under 50' 6='50 -under 65' 7='65 -under 75' 8='75 and older';
RUN;

PROC TABULATE DATA=EVENT1_2;
	CLASS RACE AGECAT;
	TABLE RACE ALL, AGECAT='Age at first surgery'*N;
	FORMAT RACE RACE_FRM. AGECAT AGE_FRM.;
RUN;
