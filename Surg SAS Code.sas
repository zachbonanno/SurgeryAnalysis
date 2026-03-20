*-----------------------------------------------------------------------*
* SAS Final Project Template for PHST620: Introduction to Statisitcal Computing
 







							*-----------------------------------------------------------------------*;
*-----------------------------------------------------------------------*
* Program name: Final_Bonanno.sas 
* Student name: 
* Type in your lastname in the file name above 	

* PHST620 
* Department of Bioinformatics and Biostatistics/UofL	

*-----------------------------------------------------------------------*

							*-----------------------------------------------------------------------*;
*Submit all four files (program, Log, Output, and PDF format of program file ) 
 on Blackboard by due date. ;
********************************
* Clear Output and Log Windows *
********************************;
*DM EDITOR 'nums' continue;
DM OUTPUT 'clear' continue;
DM LOG 'clear' continue;
title1;
title2;
OPTIONS NOCENTER NODATE NONUMBER LS=120 PS=54;
FOOTNOTE;
*------------------------------------------------------------------------*

********************************
* Clear Output and Log Windows *
********************************;
*DM EDITOR 'nums' continue;
DM OUTPUT 'clear' continue;
DM LOG 'clear' continue;
title1;
title2;
OPTIONS NOCENTER NODATE NONUMBER LS=120 PS=54;
FOOTNOTE;
*------------------------------------------------------------------------*






			LIBNAME PROJECT "/home/u64129608/HW2_PHST625/Final_Project";
TITLE1 'PHST 620 Final Project Bonanno';

PROC CONTENTS DATA=PROJECT.SURGERIES;
RUN;

PROC CONTENTS DATA=PROJECT.SMOKING;
RUN;

*------------------------------------------------------------------------*
Cleaning the Data






						*------------------------------------------------------------------------*;

PROC SORT DATA=PROJECT.SURGERIES;
	BY PT_ID EVENT_DATE;
RUN;

DATA SURGERIES2;
	SET PROJECT.SURGERIES;
	BY PT_ID EVENT_DATE;
	RETAIN BASE_AGE BASE_DATE;

	IF FIRST.PT_ID THEN
		DO;
			BASE_AGE=AGE;
			BASE_DATE=EVENT_DATE;
		END;
	AGE=BASE_AGE +((EVENT_DATE-BASE_DATE)/365.25);
RUN;

DATA PROJECT.SURGERIES2;
	SET SURGERIES2;
RUN;

PROC PRINT DATA=PROJECT.SURGERIES2 (OBS=20);
RUN;

*------------------------------------------------------------------------*
Merging the Data





						*------------------------------------------------------------------------*;

PROC SORT DATA=PROJECT.SURGERIES2;
	BY PT_ID;
RUN;

PROC SORT DATA=PROJECT.SMOKING;
	BY PT_ID;
RUN;

DATA PROJECT.COMPLETE;
	MERGE PROJECT.SURGERIES2 (IN=A) PROJECT.SMOKING (IN=B);
	BY PT_ID;

	IF A AND B;
	KEEP PT_ID EVENT_DATE SEX AGE RACE OUTCOME CONDX HOSMKG;
RUN;

PROC CONTENTS DATA=PROJECT.COMPLETE;
RUN;

PROC PRINT DATA=PROJECT.COMPLETE (OBS=15);
RUN;

*------------------------------------------------------------------------*
Questions





						*------------------------------------------------------------------------*;
* #1;

PROC SORT DATA=PROJECT.COMPLETE OUT=FIRST_DATE;
	BY EVENT_DATE;
RUN;

PROC PRINT DATA=FIRST_DATE (OBS=10);
	VAR EVENT_DATE;
	FORMAT EVENT_DATE MMDDYY10.;
RUN;

* #2;

PROC SORT DATA=PROJECT.COMPLETE OUT=LAST_DATE;
	BY Descending EVENT_DATE;
RUN;

PROC PRINT DATA=LAST_DATE (OBS=100);
	VAR EVENT_DATE;
	FORMAT EVENT_DATE MMDDYY10.;
RUN;

* #3;

PROC FREQ DATA=PROJECT.SURGERIES;
	TABLES AGE /MISSING;
RUN;

* #4;

PROC SORT DATA=PROJECT.COMPLETE;
	BY PT_ID EVENT_DATE;
RUN;

* #5;

DATA EVENT1;
	SET PROJECT.COMPLETE;
	BY PT_ID;

	IF FIRST.PT_ID;
RUN;

PROC FREQ DATA=EVENT1;
	TABLES RACE /NOPERCENT NOCUM;
RUN;

PROC FREQ DATA=EVENT1;
	TABLES RACE*SEX /NOPERCENT NOROW NOCOL;
RUN;

PROC FREQ DATA=EVENT1;
	TABLES RACE*HOSMKG /NOPERCENT NOROW NOCOL;
RUN;

* #6;

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
	VALUE YESNOFRM 0='No' 1='Yes';
RUN;

ODS RTF FILE='/home/u64129608/HW2_PHST625/Final_Project/Q6_Table.RTF';

PROC TABULATE DATA=EVENT1_2;
	CLASS RACE AGECAT;
	TABLE RACE ALL, AGECAT='Age at first surgery'*N;
	FORMAT RACE RACE_FRM. AGECAT AGE_FRM.;
RUN;

ODS RTF CLOSE;
* #7;

PROC FREQ DATA=EVENT1_2;
	TABLES AGECAT /NOPERCENT NOCUM;
	TABLES AGECAT*SEX/NOPERCENT NOCUM;
	TABLES AGECAT*HOSMKG/NOPERCENT NOCUM;
RUN;

* #8;
ODS RTF FILE='/home/u64129608/HW2_PHST625/Final_Project/Q8_Table.RTF';

PROC SORT DATA=PROJECT.COMPLETE;
	BY PT_ID EVENT_DATE;
RUN;

DATA SURGPER_DAY;
	SET PROJECT.COMPLETE;
	BY PT_ID EVENT_DATE;
	RETAIN SURG_CNT;

	IF FIRST.EVENT_DATE THEN
		SURG_CNT=0;
	SURG_CNT +1;

	IF LAST.EVENT_DATE THEN
		OUTPUT;
	KEEP PT_ID EVENT_DATE SURG_CNT;
RUN;

PROC FREQ DATA=SURGPER_DAY;
	TABLES SURG_CNT /NOCUM NOPERCENT;
	TITLE "Frequency of Surgeries/Day per Patient";
RUN;

ODS RTF CLOSE;
* #9;
ODS RTF FILE='/home/u64129608/HW2_PHST625/Final_Project/Q9_SurgCombos.RTF';

PROC SORT DATA=PROJECT.SURGERIES2;
	BY PT_ID EVENT_DATE;
RUN;

DATA SURG_COMBO;
	SET PROJECT.SURGERIES2;
	BY PT_ID EVENT_DATE;
	RETAIN FIRST_SURG;

	IF FIRST.EVENT_DATE THEN
		FIRST_SURG=CONDX;
	ELSE
		CONDX2=CONDX;

	IF LAST.EVENT_DATE THEN
		DO;
			CONDX=FIRST_SURG;
			OUTPUT;
		END;
	KEEP PT_ID EVENT_DATE CONDX CONDX2;
RUN;

PROC FREQ DATA=SURG_COMBO;
	TABLES CONDX*CONDX2 / NOPERCENT NOCUM MISSING;
	TITLE "Freq Table of Surgical Procedure Combos";
RUN;

ODS RTF CLOSE;
* #10;

DATA DEATHS;
	SET PROJECT.COMPLETE;
	WHERE OUTCOME=1;
RUN;

PROC FREQ DATA=DEATHS;
	TABLES RACE / NOCUM NOPERCENT;
RUN;

ODS RTF FILE='/home/u64129608/HW2_PHST625/Final_Project/Q10_AgeAtDeath.RTF';

PROC MEANS DATA=DEATHS N MEAN MEDIAN MIN MAX MAXDEC=2;
	CLASS RACE HOSMKG;
	VAR AGE;
	FORMAT RACE RACE_FRM. HOSMKG YESNOFRM.;
RUN;

ODS RTF CLOSE;
* Checking Number of Deaths per race;

PROC FREQ DATA=PROJECT.COMPLETE;
	TABLES RACE;
	WHERE OUTCOME=1;
	FORMAT RACE RACE_FRM.;
RUN;

* #11;
ODS RTF FILE='/home/u64129608/HW2_PHST625/Final_Project/Q11_Boxplot_TTest.RTF';
TITLE "Age at Death - Smoking History";

PROC SGPLOT DATA=DEATHS;
	VBOX AGE / CATEGORY=HOSMKG;
	XAXIS LABEL="Smoking History (0=No, 1=Yes)";
	YAXIS LABEL="Age at Death";
RUN;

PROC TTEST DATA=DEATHS;
	CLASS HOSMKG;
	VAR AGE;
RUN;

ODS RTF CLOSE;