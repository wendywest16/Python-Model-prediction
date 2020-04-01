create database turtles;
use turtles;

drop table turtle_data;

create table turtle_data (
set_id varchar(20),
fleet varchar(2),
year int,
month int,
day int,
lat decimal(5,2),
lon decimal(5,2),
hooks int,
sst decimal(5,2),
buoys int,
lightsticks int,
green int,
hawksbill int,
oliveridley int,
leatherback int,
loggerhead int,
turtle int,
total int
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/SA1 SAold2 combined before cleaning.csv' 
INTO TABLE turtle_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#=============================================================================================================
#Check nr sets, nr sets with turtles, total number of turtles caught
select count(set_id)
from turtle_data;

select count(total)
from turtle_data
where total > 0;

select sum(total) 
from turtle_data;

#=============================================================================================================
##DATA CLEANING##

#Check fleet unique values
select fleet
from turtle_data
group by fleet;

#Check year unique values
select year, count(year)
from turtle_data
group by year
order by year asc;

select * 
from turtle_data
where year = 0 or year = 208 or year = 209 or year = 330 or year = 710 or year = 1958;
#Searched for these set_id in the raw data to check whether the year can be fixed.

#Removed records with year 0. 3 records
delete from turtle_data
where year = 0;

#Updated 208-> 2008, 209-> 2009, 330-> 2010, 710-> 2010, 1958-> 2010
update turtle_data
set year = 2008
where year = 208;

update turtle_data
set year = 2009
where year = 209;

update turtle_data
set year = 2010
where year = 330 or year = 710 or year = 1958;

#Check month unique values
select month
from turtle_data
group by month
order by month asc;

#Check day unique values
select day
from turtle_data
group by day
order by day asc;

#Check Lat zero values
select * 
from turtle_data
where lat = 0;

#Removed records with lat 0. 1 records
delete from turtle_data
where lat = 0;

#Check Long zero values
select * 
from turtle_data
where lon = 0;

#Removed records with lon 0. 1 records
delete from turtle_data
where lon = 0;

#Check SST dbn of records
select 
count(case when sst<=0 then 1 else null end) as 'SST <=0C',
count(case when sst>0 and sst<=5 then 1 else null end) as 'SST 1-5C',
count(case when sst>5 and sst<=10 then 1 else null end) as 'SST 5-10C',
count(case when sst>10 and sst<=30 then 1 else null end) as 'SST 10-30C',
count(case when sst>30 and sst<=40 then 1 else null end) as 'SST 30-40C',
count(case when sst>40 and sst<=50 then 1 else null end) as 'SST 40-50C',
count(case when sst>50 and sst<=90 then 1 else null end) as 'SST 50-90C',
count(case when sst>90 then 1 else null end) as 'SST >90C'
from turtle_data;

#Remove <=0C records, 383 records.
#Uncertainty whether 1-5C is a capturing error or not so removed, 909 records
#Removed >90C records, 2 records.
delete from turtle_data
where sst <= 5 or sst > 90;

#Records between 50-90C were converted from celsius to fahrenheit, 293 records
update turtle_data
set sst = (sst-32)*(5/9)
where sst > 50 and sst < 90;

#Check hooks for zeroes and outliers
select count(hooks) 
from turtle_data
where hooks = 0;

#14 records with 0 hooks removed
delete from turtle_data
where hooks=0;

#Check dbn of hook values
select 
count(case when hooks<=500 then 1 else null end) as '<=500',
count(case when hooks>500 and hooks<=1000 then 1 else null end) as '500-1000',
count(case when hooks>1000 and hooks<=2000 then 1 else null end) as '1000-2000',
count(case when hooks>2000 and hooks<=3000 then 1 else null end) as '2000-3000',
count(case when hooks>3000 and hooks<=4000 then 1 else null end) as '3000-4000',
count(case when hooks>4000 then 1 else null end) as '4000C'
from turtle_data;

#Removed records where hooks > 4000. 5 records
select *
from turtle_data
where hooks > 4000;

delete from turtle_data
where hooks > 4000;

#Check lightsticks for zeroes and outliers
select count(lightsticks) 
from turtle_data
where lightsticks = 0;

#Too many zero records, 8711, so removed lightsticks column
alter table turtle_data drop column lightsticks;

#Check buoys for zeroes and outliers
select count(buoys) 
from turtle_data
where buoys = 0;

#10 zero values. May need to remove this variablem it'll have multicollinearity with hook numbers
delete from turtle_data
where buoys = 0;

#Phase 1 complete
#=============================================================================================================
#Plotted data in python to check for outlier lat/long set locations
delete from turtle_data
where set_id = '8742_3'  or set_id = '11904_53' or set_id = '6861_36' or set_id = '6902_8' or set_id = '11904_13' 
or set_id = '11701_1' or set_id = '9012_3' or set_id = '11701_9' or set_id = '4493_2' or set_id = '12840_3'
or set_id = '8871_2' or set_id = '10480_68' or set_id = '11046_35' or set_id = '11046_25' or set_id = '12772_36'
or set_id = '12127_41' or set_id = '8536_16' or set_id = '10476_23' or set_id = '12130_14' or set_id = '12773_43'
 or set_id = '6907_26' or set_id = '6695_10' or set_id = '8339_65' or set_id = '9193_2' or set_id = '8702_19'
 or set_id = '8702_25' or set_id = '10478_21' or set_id = '7299_9' or set_id = '11554_19';

#Add in total turtle CPUE (number of turtles per 1000 hooks)
select *, (total/hooks)*1000 as turtle_CPUE
from turtle_data;

#Phase 2 complete - this is the final cleaned data
#=============================================================================================================
#Only sets with catches for plotting in python. Pivot table to have a species column 
create table turtle_catch
select * 
from turtle_data
where total > 0;

select set_id, lat, lon, sst, month, green as no_catch, 'green' species
from turtle_catch
where green > 0
union all
select set_id, lat, lon, sst, month, oliveridley as no_catch, 'oliveridley' species
from turtle_catch
where oliveridley > 0
union all
select set_id, lat, lon, sst, month, hawksbill as no_catch, 'hawksbill' species
from turtle_catch
where hawksbill > 0
union all
select set_id, lat, lon, sst, month, leatherback as no_catch, 'leatherback' species
from turtle_catch
where leatherback > 0
union all
select set_id, lat, lon, sst, month, loggerhead as no_catch, 'loggerhead' species
from turtle_catch
where loggerhead > 0
union all
select set_id, lat, lon, sst, month, turtle as no_catch, 'turtle unid' species
from turtle_catch
where turtle > 0;

#Phase 3 complete

select month, green as no_catch, 'green' species
from turtle_catch
where green > 0
union all
select  month, oliveridley as no_catch, 'oliveridley' species
from turtle_catch
where oliveridley > 0
union all
select  month, hawksbill as no_catch, 'hawksbill' species
from turtle_catch
where hawksbill > 0
union all
select  month, leatherback as no_catch, 'leatherback' species
from turtle_catch
where leatherback > 0
union all
select  month, loggerhead as no_catch, 'loggerhead' species
from turtle_catch
where loggerhead > 0
union all
select  month, turtle as no_catch, 'turtle unid' species
from turtle_catch
where turtle > 0;

#Phase 3_1 complete
#=============================================================================================================
#Check nr sets, nr sets with turtles, total number of turtles caught
select count(set_id)
from turtle_data;

select count(total)
from turtle_data
where total > 0;

select sum(total) 
from turtle_data;


