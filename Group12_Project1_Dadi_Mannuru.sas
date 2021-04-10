/* Generated Code (IMPORT) */
/* Source File: Train.csv */
/* Source Path: /home/u54014787/Predictive Analytics/Project 1/Final */
/* Code generated on: 3/17/21, 6:35 PM */

%web_drop_table(WORK.IMPORT);


FILENAME REFFILE '/home/u54014787/Predictive Analytics/Project 1/Final/Train.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.IMPORT;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; RUN;


%web_open_table(WORK.IMPORT);

/*Chcekcing Normality*/
PROC UNIVARIATE DATA=import;
VAR Item_Weight;
histogram Item_Weight / Normal;
RUN;

PROC UNIVARIATE DATA=import;
VAR Item_Outlet_Sales;
histogram Item_Outlet_Sales / Normal;
RUN;

/*Check Missing Values*/
proc format;
value $missfmt '' = 'Missing' other = 'Not Missing';
value missfmt . = 'Missing' other = 'Not Missing';
run;

proc freq data=import;
format _CHAR_ $missfmt.;
format _NUMERIC_ missfmt.;
tables _CHAR_ / missing nocum nopercent;
tables _NUMERIC_ / missing nocum nopercent;
run;

/*Cleaning Data*/
data clean_data;
set import;
if Item_Fat_Content = 'LF' then Item_Fat_Content = 'Low Fat';
if Item_Fat_Content = 'reg' then Item_Fat_Content = 'regular';
if Item_Weight = '' then Item_Weight = '12.85'; /*because avg of item weight is 12.85*/
if Outlet_Size = '' then Outlet_Size = 'Medium'; /*because mode of the colum is Medium*/
run;

proc export data=clean_data
	outfile = "/home/u54014787/Predictive Analytics/Project 1/Final/clean_data.XLSX"
	dbms = xlsx replace;
	sheet = "Custom";
run;
	
/*EDA*/
proc SGPLOT data = clean_data;
vbar  Outlet_Type / response= Item_Outlet_Sales group =Outlet_Location_Type stat=mean GROUPDISPLAY = CLUSTER;;
title 'Outlet Sales Bar Graph';
run;
quit;

proc SGPLOT data = clean_data;
vbar  Outlet_Type / response= Item_Outlet_Sales group =Outlet_Size stat=mean GROUPDISPLAY = CLUSTER;;
title 'Outlet Sales Bar Graph';
run;
quit;

proc SGPLOT data = clean_data;
vbar  Outlet_Establishment_Year / response= Item_Outlet_Sales stat=mean;
title 'Outlet Sales Bar Graph';
run;
quit;

proc SGPLOT data = clean_data;
vbar  Item_Fat_Content / response= Item_Outlet_Sales stat=mean;
title 'Outlet Sales Bar Graph';
run;
quit;

proc SGPLOT data = clean_data;
vbar  Item_Type / response= Item_Outlet_Sales;
title 'Outlet Sales Bar Graph';
run;
quit;


PROC CORR DATA=clean_data ;
  VAR  Item_Weight Item_Visibility Item_MRP Item_Outlet_Sales;
RUN ;


/* regression model with quantitative variables */
proc reg data = clean_data PLOTS(MAXPOINTS=none );
model Item_Outlet_Sales = Item_Weight Item_Visibility Item_MRP;
run;

/*Dummy encoding categorical variables*/
data import1;
set clean_data;
if Outlet_Location_Type = "Tier 1" then Tier_1 = 1;
else if Outlet_Location_Type ~= "Tier 1" then Tier_1 = 0;
if Outlet_Location_Type = "Tier 2" then Tier_2 = 1;
else if Outlet_Location_Type ~= "Tier 2" then Tier_2 = 0;
if Outlet_Location_Type = "Tier 3" then Tier_3 = 1;
else if Outlet_Location_Type ~= "Tier 3" then Tier_3 = 0;
if Outlet_Size = "High" then High_Size = 1;
else if Outlet_Size ~= "High" then High_Size = 0;
if Outlet_Size = "Medium" then Medium_Size = 1;
else if Outlet_Size ~= "Medium" then Medium_Size = 0;
if Outlet_Size = "Small" then Small_Size = 1;
else if Outlet_Size ~= "Small" then Small_Size = 0;
if Outlet_Type = "Grocery Store" then Grocery_Store = 1;
else if Outlet_Type ~= "Grocery Store" then Grocery_Store = 0;
if Outlet_Type = "Supermarket Type1" then Supermarket_Type1 = 1;
else if Outlet_Type ~= "Supermarket Type1" then Supermarket_Type1 = 0;
if Outlet_Type = "Supermarket Type2" then Supermarket_Type2 = 1;
else if Outlet_Type ~= "Supermarket Type2" then Supermarket_Type2 = 0;
if Outlet_Type = "Supermarket Type3" then Supermarket_Type3 = 1;
else if Outlet_Type ~= "Supermarket Type3" then Supermarket_Type3 = 0;
if Item_Fat_Content = "Low Fat" then Low_Fat = 1;
else if Item_Fat_Content ~= "Low Fat" then Low_Fat = 0;
if Item_Fat_Content = "Regular" then Regular = 1;
else if Item_Fat_Content ~= "Regular" then Regular = 0;
run;

/* Regression model with dummmy variables */

proc reg data = import1 PLOTS(MAXPOINTS=none );
model Item_Outlet_Sales = Item_Weight Item_Visibility Item_MRP Tier_1 Tier_2 Tier_3 High_Size Medium_Size Small_Size 
Grocery_Store Supermarket_Type1 Supermarket_Type2 Supermarket_Type3 Low_Fat Regular  ;
run;

/* stepwise regression */

proc reg data=import1 PLOTS(MAXPOINTS=none ) ;
model Item_Outlet_Sales = Item_Weight item_Visibility Item_MRP 
Tier_1 Tier_2 Tier_3 High_Size Medium_Size Small_Size Grocery_Store Supermarket_Type1 Supermarket_Type2 Supermarket_Type3 
Low_Fat Regular / selection = stepwise slentry=0.1 slstay=0.1;
run;

/* regression model with only stepwise variables */

proc reg data=import1 PLOTS(MAXPOINTS=none ) ;
model Item_Outlet_Sales = Item_MRP Grocery_Store Supermarket_Type3 Supermarket_Type2 Low_Fat;
run;

/* residual analysis */
proc reg data=import1 PLOTS(MAXPOINTS=none ) ;
model Item_Outlet_Sales = Item_MRP Grocery_Store Supermarket_Type3 Supermarket_Type2 Low_Fat;
output out = result residual=residuals;
run;
proc print data = result;
run;

proc univariate data = result;
var residuals;
run;

/* transformation */

data import2;
set import1;
log_Item_Outlet_Sales = log(Item_Outlet_Sales);
run;
proc print data = import2;
run;

proc reg data = import2 PLOTS(MAXPOINTS=none );
model log_Item_Outlet_Sales = Item_MRP Tier_3 Grocery_Store Supermarket_Type1 Supermarket_Type3;
/*output out = result1 residual=residual; */
run;




/*Extra*/

/*Log transforming Item_Outlet_Sales*/
data import2;
set import1;
LNSALES=LOG(Item_Outlet_Sales);
run;

PROC UNIVARIATE DATA=import2;
VAR LNSALES;
histogram LNSALES / Normal;
RUN;

/*Log transforming Item_Weight*/
data import3;
set import2;
LNWEIGHT=LOG(Item_Weight);
run;

PROC UNIVARIATE DATA=import3;
VAR LNWEIGHT;
histogram LNWEIGHT / Normal;
RUN;

/*2nd Trial keeping all the categorical variables*/
proc reg data=import3;
model Item_Outlet_Sales = Item_Weight Item_Visibility Item_MRP High_Size Medium_Size Small_Size Tier_1 Tier_2 Tier_3 Grocery_store Supermarket_Type1 Supermarket_Type2 Supermarket_Type3;
run;

/*3nd Trial keeping all the categorical variables and log transformed variables*/
proc reg data=import3;
model LNSALES = LNWEIGHT Item_Visibility Item_MRP High_Size Medium_Size Small_Size Tier_1 Tier_2 Tier_3 Grocery_store Supermarket_Type1 Supermarket_Type2 Supermarket_Type3;
run;













