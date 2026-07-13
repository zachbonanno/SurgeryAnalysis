/* Mortality summary from Final_Bonanno.sas.
   Subsets patients whose OUTCOME=1 (deaths), reports deaths by race, then
   summarizes age at death by race and smoking history with PROC MEANS and
   compares mean age at death between smoking groups with PROC TTEST.
   Reads SURGERIES + SMOKING provided by autoexec.sas.
   (The upstream ODS RTF FILE= destination and the graphical PROC SGPLOT box
   plot are omitted so the numeric results render to the standard listing; the
   MEANS/TTEST/FREQ requests themselves are unchanged.) */
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

DATA DEATHS;
	SET COMPLETE;
	WHERE OUTCOME=1;
RUN;

PROC FORMAT;
	VALUE RACE_FRM 1='Native American' 2='Native American' 3='Afr Amer (non-Hisp)'
		4='Hispanic' 8='Asian' 9='White(non-Hisp)';
	VALUE YESNOFRM 0='No' 1='Yes';
RUN;

PROC FREQ DATA=DEATHS;
	TABLES RACE / NOCUM NOPERCENT;
RUN;

PROC MEANS DATA=DEATHS N MEAN MEDIAN MIN MAX MAXDEC=2;
	CLASS RACE HOSMKG;
	VAR AGE;
	FORMAT RACE RACE_FRM. HOSMKG YESNOFRM.;
RUN;

PROC TTEST DATA=DEATHS;
	CLASS HOSMKG;
	VAR AGE;
RUN;
