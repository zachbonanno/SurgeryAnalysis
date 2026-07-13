/* Age-at-surgery calculation from Final_Bonanno.sas.
   Recomputes AGE for each follow-up surgery from the days elapsed since the
   patient's first (baseline) event, using a RETAIN + FIRST.PT_ID pattern.
   Reads the SURGERIES dataset provided by autoexec.sas. */
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

PROC PRINT DATA=SURGERIES2 (OBS=20);
RUN;
