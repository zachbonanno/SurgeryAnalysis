/* Surgical procedure combinations from Final_Bonanno.sas.
   For each patient/event date, captures the first procedure (FIRST_SURG) and a
   subsequent procedure on the same date (CONDX2) using a RETAIN + FIRST./LAST.
   pattern, then cross-tabulates the CONDX by CONDX2 procedure pairs.
   Reads the SURGERIES dataset provided by autoexec.sas.
   (The upstream ODS RTF FILE= destination is omitted so the table renders to the
   standard listing; the analysis logic is unchanged.) */
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
	BY PT_ID EVENT_DATE;
RUN;

DATA SURG_COMBO;
	SET SURGERIES2;
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
