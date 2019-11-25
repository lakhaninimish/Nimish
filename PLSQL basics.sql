CREATE TABLE CUSTOMER (
CUSTID	NUMBER
, CUSTNAME	VARCHAR2(100)
, SALES_YTD	NUMBER
, STATUS	VARCHAR2(7)
, PRIMARY KEY	(CUSTID) 
);

CREATE TABLE PRODUCT (
PRODID	NUMBER
, PRODNAME	VARCHAR2(100)
, SELLING_PRICE	NUMBER
, SALES_YTD	NUMBER
, PRIMARY KEY	(PRODID)
);

CREATE TABLE SALE (
SALEID	NUMBER
, CUSTID	NUMBER
, PRODID	NUMBER
, QTY	NUMBER
, PRICE	NUMBER
, SALEDATE	DATE
, PRIMARY KEY 	(SALEID)
, FOREIGN KEY 	(CUSTID) REFERENCES CUSTOMER
, FOREIGN KEY 	(PRODID) REFERENCES PRODUCT
);

CREATE TABLE LOCATION (
  LOCID	VARCHAR2(5)
, MINQTY	NUMBER
, MAXQTY	NUMBER
, PRIMARY KEY 	(LOCID)
, CONSTRAINT CHECK_LOCID_LENGTH CHECK (LENGTH(LOCID) = 5)
, CONSTRAINT CHECK_MINQTY_RANGE CHECK (MINQTY BETWEEN 0 AND 999)
, CONSTRAINT CHECK_MAXQTY_RANGE CHECK (MAXQTY BETWEEN 0 AND 999)
, CONSTRAINT CHECK_MAXQTY_GREATER_MIXQTY CHECK (MAXQTY >= MINQTY)
);

CREATE SEQUENCE SALE_SEQ;


--1.1
create or replace procedure ADD_CUST_TO_DB (pcustid number,pcustname varchar2)as
custid_too_high exception;
begin
if(pcustid > 499 or pcustid < 1) then
raise custid_too_high;
else
/*dbms_output.put_line('--------------------------');
dbms_output.put_line('Adding Customer: '||pcustid|| ', ' ||pcustname );*/
insert into customer(custid,custname,sales_ytd,status) values (pcustid,pcustname,0,'OK');
dbms_output.put_line('Customer Added OK');
--commit;
end if;
exception
when DUP_VAL_ON_INDEX then
raise_application_error(-20010,'Duplicate customer ID');
when custid_too_high then
raise_application_error(-20002,'Customer ID out of range');
when others then
raise_application_error(-20001,SQLERRM);
end;
/

create or replace procedure ADD_CUSTOMER_VIASQLDEV(pcustid number,pcustname varchar2)as
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Adding Customer: '||pcustid|| ', ' ||pcustname );
ADD_CUST_TO_DB(pcustid,pcustname);
--dbms_output.put_line('Customer Added OK');
commit;
exception 
when others then
dbms_output.put_line(SQLERRM);
end;    
/

--1.2
create or replace function DELETE_ALL_CUSTOMERS_FROM_DB return 
number as
vcount number;
begin
delete from customer;
vcount := sql%rowcount;
return vcount;
exception 
when others then 
raise_application_error (-20000,SQLERRM);
end;
/

create or replace procedure DELETE_ALL_CUSTOMERS_VIASQLDEV as
vcount number;
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Deleting all Customer rows' );
vcount := DELETE_ALL_CUSTOMERS_FROM_DB();
dbms_output.put_line(vcount|| 'rows deleted');
--commit;
exception 
when others then
dbms_output.put_line(SQLERRM);
end;   
/


--1.3
create or replace procedure ADD_PROD_TO_DB (pprodid number,pprodname varchar2,pprice number)as
pprodid_too_high exception;
pprice_too_high exception;
begin
if(pprodid <1000 or pprodid > 2500) then
raise pprodid_too_high;
end if;
if (pprice <0 or pprice >999.99) then
raise pprice_too_high;
else
/*dbms_output.put_line('--------------------------');
dbms_output.put_line('Adding Customer: '||pcustid|| ', ' ||pcustname );*/
insert into product(prodid,prodname,selling_price,sales_ytd) values (pprodid,pprodname,pprice,0);
dbms_output.put_line('Product Added OK');
commit;
end if;
exception
when DUP_VAL_ON_INDEX then
raise_application_error(-20010,'Duplicate Product ID');
when pprodid_too_high then
raise_application_error(-20012,'Product ID out of range');
when pprice_too_high then
raise_application_error(-20013,'Price out of range');
when others then
--dbms_output.put_line(SQLCODE);
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure ADD_PRODUCT_VIASQLDEV(pprodid number,pprodname varchar2,pprice number) as
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Adding Product: '||pprodid|| ', ' ||pprodname|| ', '||pprice );
ADD_PROD_TO_DB(pprodid,pprodname,pprice);
--dbms_output.put_line('Customer Added OK');
commit;
exception 
when others then
dbms_output.put_line(SQLERRM);
end;    
/


create or replace function DELETE_ALL_PRODUCTS_FROM_DB return 
number as
vcount number;
begin
delete from product;
vcount := sql%rowcount;
return vcount;
exception 
when others then 
raise_application_error (-20000,SQLERRM);
end;
/

create or replace procedure DELETE_ALL_PRODUCTS_VIASQLDEV as
vcount number;
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Deleting all Product rows' );
vcount := DELETE_ALL_PRODUCTS_FROM_DB();
dbms_output.put_line('rows deleted: '||vcount);
commit;
exception
when others then
dbms_output.put_line(SQLERRM);
end; 
/

--1.4
create or replace function GET_CUST_STRING_FROM_DB (pcustid number) return varchar2
as vdata varchar2(100) ;
vcustid customer.custid%type;
vcustname customer.custname%type;
vstatus customer.status%type;
vsales_ytd customer.sales_ytd%type;
custid_null exception;
begin
begin
select custid,custname,status,sales_ytd
into vcustid,vcustname,vstatus,vsales_ytd
from customer
where custid = pcustid;
exception
when no_data_found then
raise custid_null;
end;
vdata := 'Custid: '||vcustid || ' Name: '||vcustname || ' Status '||vstatus || ' SalesYTD '||vsales_ytd;
--vdata := dbms_output.put_line('Custid: '||vcustid || 'Name: '||vcustname || 'Status '||vstatus || 'SalesYTD '||vsales_ytd);
return vdata;
exception
when custid_null then
raise_application_error(-20021,'Customer ID not found');
when OTHERS then
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure GET_CUST_STRING_VIASQLDEV (pcustid number) as
vdata varchar2(100);
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Getting details for custid: '||pcustid);
vdata := GET_CUST_STRING_FROM_DB(pcustid);
dbms_output.put_line(vdata);
--commit;
exception 
when others then
dbms_output.put_line (SQLERRM);
end; 
/
/*set serveroutput on;
begin
GET_CUST_STRING_VIASQLDEV(1);
GET_CUST_STRING_VIASQLDEV(1);
GET_CUST_STRING_VIASQLDEV(2);
end;*/

/*set serveroutput on;
begin
GET_CUST_STRING_VIASQLDEV(22);
end;*/ 

create or replace procedure UPD_CUST_SALESYTD_IN_DB (pcustid number, pamt number) as
pcustid_too_high exception;
pamt_too_high exception;
vcustid customer.custid%type;
begin
if (pamt <-999.99 or pamt>999.99) then
raise pamt_too_high;
end if;
begin
select custid
into vcustid
from customer
where custid = pcustid;
exception
when no_data_found then
raise pcustid_too_high;
end;
update customer
set sales_ytd = sales_ytd + pamt
where custid = pcustid;
dbms_output.put_line('Update OK');
commit;
exception
when pcustid_too_high then
raise_application_error (-20021,'Customer ID not found');
when pamt_too_high then
raise_application_error(-20032, 'Amount out of range');
when OTHERS then
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure UPD_CUST_SALESYTD_VIASQLDEV (pcustid number, pamt number) as
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Updating SalesYTD. Customer ID: '||pcustid|| ' Amount: '||pamt);
UPD_CUST_SALESYTD_IN_DB(pcustid,pamt) ;
--dbms_output.put_line(vdata);
--commit;
exception
WHEN OTHERS then
dbms_output.put_line(SQLERRM);
end; 
/
/*set serveroutput on;
begin
UPD_CUST_SALESYTD_VIASQLDEV(1,2000);
UPD_CUST_SALESYTD_VIASQLDEV(20,500);
end; 

select * from customer;*/


--1.5
create or replace function GET_PROD_STRING_FROM_DB (pprodid number) return varchar2
as vdata varchar2(100) ;
vpprodid product.prodid%type;
vpname product.prodname%type;
vprice product.selling_price%type;
vsales_ytd product.sales_ytd%type;
prodid_null exception;
begin
begin
select prodid,prodname,selling_price, sales_ytd
into vpprodid,vpname,vprice,vsales_ytd
from product
where prodid = pprodid;
exception 
when no_data_found  then
raise prodid_null;
end;
vdata := 'Prodid: '||vpprodid || ' Name: '||vpname || ' Price '||vprice || ' SalesYTD '||vsales_ytd;
--vdata := dbms_output.put_line('Custid: '||vcustid || 'Name: '||vcustname || 'Status '||vstatus || 'SalesYTD '||vsales_ytd);
return vdata;
exception
when prodid_null then
raise_application_error (-20041,'Product ID not found');
when OTHERS then
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure GET_PROD_STRING_VIASQLDEV (pprodid number) as
vdata varchar2(100);
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Getting details for prodid: '||pprodid);
vdata := GET_PROD_STRING_FROM_DB(pprodid);
dbms_output.put_line(vdata);
--commit;
exception
when others then
dbms_output.put_line(SQLERRM);
end; 
/
/*set serveroutput on;
begin
GET_PROD_STRING_VIASQLDEV(1001);
end; */


create or replace procedure UPD_PROD_SALESYTD_IN_DB (pprodid number, pamt number) as
pprodid_too_high exception;
pamt_too_high exception;
vprodid product.prodid%type;
begin
if (pamt <-999.99 or pamt>999.99) then
raise pamt_too_high;
end if;
begin
select prodid
into vprodid 
from product
where prodid = pprodid;
exception
when no_data_found then
raise pprodid_too_high;
end;
update product
set sales_ytd = sales_ytd+pamt
where prodid = pprodid;
commit;
dbms_output.put_line('Update OK');
exception
when pprodid_too_high then
raise_application_error (-20041, 'Product ID not found');
when pamt_too_high then
raise_application_error(-20052,'Amount out of range');
when OTHERS then
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure UPD_PROD_SALESYTD_VIASQLDEV (pprodid number, pamt number) as
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Updating SalesYTD. Product ID: '||pprodid|| ' Amount: '||pamt);
UPD_PROD_SALESYTD_IN_DB(pprodid,pamt);
--dbms_output.put_line(vdata);
--commit;
exception
WHEN OTHERS then
dbms_output.put_line(SQLERRM);
end; 
/

--1.6
create or replace procedure UPD_CUST_STATUS_IN_DB (pcustid number, pstatus varchar2) as
custid_not_found exception;
status_not_found exception;
vcount number;
begin

if(upper(pstatus) = 'OK' or upper(pstatus) = 'SUSPEND') then
update customer
set status = pstatus
where custid = pcustid;
vcount := sql%rowcount;
else
raise status_not_found;
end if;
if(vcount = 0) then
raise custid_not_found;
else
dbms_output.put_line('Update OK');
end if;
--dbms_output.put_line('Update OK');
exception
when custid_not_found then
raise_application_error(-20061,'Customer ID not found');
when status_not_found then
raise_application_error(-20062, 'Invalid Status value');
when OTHERS then
raise_application_error (-20000,SQLERRM);
end;
/

create or replace procedure UPD_CUST_STATUS_VIASQLDEV (pcustid number, pstatus varchar2)
as
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Updating Status. ID: '||pcustid|| ' New Status: '||pstatus);
UPD_CUST_STATUS_IN_DB(pcustid,pstatus) ;
commit;
exception
when others then
dbms_output.put_line(SQLERRM);
end;
/

--1.7
create or replace procedure ADD_SIMPLE_SALE_TO_DB (pcustid number, pprodid number, pqty number)
as 
vstatus customer.status%type;
invalid_status exception;
invalid_qty exception;
custid_null exception;
prodid_null exception;
vcustid customer.custid%type;
vprodid product.prodid%type;
vprice sale.price%type;
pamt number;
begin
begin
select custid 
into vcustid
from customer
where custid = pcustid;
exception
 when no_data_found then
 raise custid_null;
end;


begin
select prodid
into vprodid
from product
where prodid = pprodid;
exception 
when no_data_found then
raise prodid_null;
end;


select status 
into vstatus
from customer
where custid = pcustid; 

if(upper(vstatus) <> 'OK')then
raise invalid_status;
end if;
if (pqty <1 or pqty >999) then
raise invalid_qty;
end if;

select selling_price 
into vprice
from product
where prodid = pprodid;

pamt := pqty * vprice;

UPD_CUST_SALESYTD_IN_DB(pcustid,pamt);
UPD_PROD_SALESYTD_IN_DB(pprodid,pamt);

dbms_output.put_line('Added Simple Sale OK');

exception
when invalid_qty then
raise_application_error(-20071, 'Sale Quantity outside valid range');
when invalid_status then
raise_application_error(-20072, 'Customer status is not OK');
when custid_null then
raise_application_error (-20073, 'Customer ID not found');
when prodid_null then
raise_application_error(-20076,'Product ID not found');
when OTHERS then
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure ADD_SIMPLE_SALE_VIASQLDEV(pcustid number, pprodid number, pqty number) as
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Adding Simple Sale. CustID: '||pcustid|| ' ProdID: '||pprodid|| ' Qty: '||pqty);
ADD_SIMPLE_SALE_TO_DB(pcustid,pprodid,pqty);
commit;
end;
/

--1.8
create or replace function SUM_CUST_SALESYTD return number
as
vsum number;
begin
select sum(sales_ytd)
into vsum
from customer;
return vsum;
exception
when OTHERS then
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure SUM_CUST_SALES_VIASQLDEV as
vsum number;
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Summing Customer SalesYTD');
vsum := SUM_CUST_SALESYTD;
dbms_output.put_line('All Customer Total: '||vsum);
exception
when OTHERS then
dbms_output.put_line (SQLERRM);
end;
/


create or replace function SUM_PROD_SALESYTD_FROM_DB return number
as
vsum number;
begin
select sum(sales_ytd)
into vsum
from product;
return vsum;
exception
when OTHERS then
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure SUM_PROD_SALES_VIASQLDEV as
vsum number;
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Summing Product SalesYTD');
vsum := SUM_PROD_SALESYTD_FROM_DB;
dbms_output.put_line('All Product Total: '||vsum);
exception
when OTHERS then
dbms_output.put_line (SQLERRM);
end;
/


--2.1
create or replace function GET_ALLCUST return sys_refcursor as
cust_cur sys_refcursor;
begin
open cust_cur for 
select * from customer;
return cust_cur;
exception 
when others  then
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure GET_ALLCUST_VIASQLDEV as
cust_cur sys_refcursor;
custrec customer%rowtype;
vcount number := 0;
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Listing all customer details');
cust_cur := GET_ALLCUST;
LOOP
FETCH cust_cur into custrec;
exit when cust_cur%notfound;
dbms_output.put_line('Custid:' ||custrec.custid || ' Name:' ||custrec.custname|| ' status:' ||custrec.status||' SalesYTD:' ||custrec.sales_ytd);
vcount := vcount + 1;
END LOOP;
if (vcount = 0) then
dbms_output.put_line('No rows found');
end if;
exception 
when others then
dbms_output.put_line(SQLERRM);
end;
/

create or replace function GET_ALLPROD_FROM_DB return sys_refcursor as
prod_cur sys_refcursor;
begin
open prod_cur for 
select * from product;
return prod_cur;
exception 
when others then
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure GET_ALLPROD_VIASQLDEV as
prod_cur sys_refcursor;
prodrec product%rowtype;
vcount number := 0;
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Listing all Product details');
prod_cur := GET_ALLPROD_FROM_DB;
LOOP
FETCH prod_cur into prodrec;
exit when prod_cur%notfound;
dbms_output.put_line('Prodid:' ||prodrec.prodid || ' Name:' ||prodrec.prodname|| ' status:' ||prodrec.selling_price||' SalesYTD:' ||prodrec.sales_ytd);
vcount := vcount + 1;
END LOOP;
if (vcount = 0) then
dbms_output.put_line('No rows found');
end if;
exception
when others then
dbms_output.put_line(SQLERRM);
end;
/


--3.1
create or replace procedure ADD_LOCATION_TO_DB(ploccode varchar2, pminqty number, pmaxqty number) as
loccode_too_high exception;
pminqty_too_high exception;
pmaxqty_too_high exception;
pmin_gre_pmax exception;
begin
if(length(ploccode)<>5) then
raise loccode_too_high;
end if;
if(pminqty < 0 or pminqty>999) then
raise pminqty_too_high;
end if;
if(pmaxqty <0 or pmaxqty >999) then
raise pmaxqty_too_high;
end if;
if (pminqty > pmaxqty) then
raise pmin_gre_pmax;
end if;
insert into location(locid,minqty,maxqty) values (ploccode,pminqty,pmaxqty);
dbms_output.put_line('Location Added OK');
exception
when DUP_VAL_ON_INDEX then
raise_application_error(-20081,'Duplicate location ID');
when loccode_too_high then
raise_application_error(-20082, 'Location Code length invalid');
when pminqty_too_high then
raise_application_error(-20083, 'Minimum Qty out of range');
when pmaxqty_too_high then
raise_application_error(-20084, 'Maximum Qty out of range');
when pmin_gre_pmax then
raise_application_error(-20086,'Minimum Qty larger than Maximum Qty');
when OTHERS then
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure ADD_LOCATION_VIASQLDEV(ploccode varchar2, pminqty number, pmaxqty number)
as
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Adding Location Loccode: '||ploccode|| ' MinQty' ||pminqty ||' Maxqty' ||pmaxqty);
ADD_LOCATION_TO_DB(ploccode,pminqty,pmaxqty);
exception 
when others then
dbms_output.put_line(SQLERRM);
end;
/

--4.1
create or replace procedure ADD_COMPLEX_SALE_TO_DB(pcustid number, pprodid number, pqty number, pdate varchar2)
as
invalid_status exception;
vstatus customer.status%type;
invalid_quantity exception;
custid_null exception;
prodid_null exception;
invalid_date exception;
vcustid number;
vprodid number;
pdate1 date;
pamt number;
vcheck1 number;
vcheck2 number;
punit_price number := 20;
begin

begin
select custid 
into vcustid
from customer
where custid = pcustid;
exception
 when no_data_found then
 raise custid_null;
end;

begin
select prodid
into vprodid
from product
where prodid = pprodid;
exception 
when no_data_found then
raise prodid_null;
end;

select status
into vstatus 
from customer
where custid = pcustid;

if(upper(vstatus) <> 'OK' or vstatus is null) then
raise invalid_status;
end if;

if (pqty <1 or pqty >999) then
raise invalid_quantity;
end if;

select selling_price
into punit_price
from product
where prodid = pprodid;

if (length(pdate) >8 or length(pdate) <8) then
    raise invalid_date;    
else 
dbms_output.put_line('----' ||pdate);
vcheck1 := substr(pdate,5,2);
if(vcheck1 < 1 or vcheck1 >12) then
raise invalid_date;
end if;
vcheck2 := substr(pdate,7,2);
if(vcheck2 <1 or vcheck2 >31) then
raise invalid_date;
end if; 
pdate1 := to_date(pdate,'YYYYMMDD');
end if;

pamt := pqty * punit_price;

dbms_output.put_line('Insert 1');
insert into sale(saleid,custid,prodid,qty,price,saledate) values (sale_seq.nextval,pcustid,pprodid,pqty,punit_price,pdate1);
dbms_output.put_line ('Added Complex Sale OK');

UPD_CUST_SALESYTD_IN_DB(pcustid,pamt);
UPD_PROD_SALESYTD_IN_DB(pprodid,pamt);

exception
when invalid_status then
raise_application_error(-20092, 'Customer status is not OK');
when invalid_quantity then
raise_application_error(-20091, 'Sale Quantity outside valid range');
when custid_null then
raise_application_error (-20094, 'Customer ID not found');
when prodid_null then
raise_application_error (-20095,'Product ID not found');
when invalid_date then
raise_application_error(-20093,'Date not valid');
when OTHERS then
raise_application_error (-20000,SQLERRM);
end;
/

create or replace procedure ADD_COMPLEX_SALE_VIASQLDEV(pcustid number, pprodid number, pqty number, pdate varchar2)
as
vprice number;
vamt number;
begin
dbms_output.put_line('--------------------------');
select selling_price
into vprice
from product
where prodid = pprodid;
vamt := pqty * vprice;
dbms_output.put_line('Adding Complex Sale. CustID: '||pcustid|| ' ProdID: '||pprodid|| 'date: '||pdate || ' Amt '||vamt);
ADD_COMPLEX_SALE_TO_DB(pcustid,pprodid,pqty,pdate);
exception 
when others then
dbms_output.put_line(SQLERRM);
end;
/


create or replace function COUNT_PRODUCT_SALES_FROM_DB(pdays number) return number
as
vcount number;
begin
select count(qty)
into vcount
from sale
where trunc(saledate) between trunc(sysdate - pdays) and trunc(sysdate);
return vcount;
exception 
when OTHERS then
raise_application_error(-20000,SQLERRM);
end;
/
    

create or replace procedure COUNT_PRODUCT_SALES_VIASQLDEV (pdays number)
as
vcount number;
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Counting Sales within ' ||pdays|| ' days');
vcount := COUNT_PRODUCT_SALES_FROM_DB(pdays);
dbms_output.put_line('Total number of sales: '||vcount);
exception 
when others then
dbms_output.put_line(SQLERRM);
end;
/


create or replace function GET_ALLSALES_FROM_DB return sys_refcursor as
sale_cur sys_refcursor;
begin
open sale_cur for 
select * from sale;
return sale_cur;
exception
when others then
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure GET_ALLSALES_VIASQLDEV as
sale_cur sys_refcursor;
salerec sale%rowtype;
vcount number := 0;
vprice number;
vamt number;
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Listing all Complex sale details');
sale_cur := GET_ALLSALES_FROM_DB;
LOOP
FETCH sale_cur into salerec;
exit when sale_cur%notfound;
select selling_price
into vprice
from product
where prodid = salerec.prodid;
vamt := salerec.qty * vprice; 
dbms_output.put_line('Saleid:' ||salerec.saleid || ' Custid:' ||salerec.custid|| ' Prodid:' ||salerec.prodid||' Date:' ||salerec.saledate || 'Amount: '||vamt);
vcount := vcount + 1; 
END LOOP;
if (vcount = 0) then
dbms_output.put_line('No rows found');
end if;
exception 
when others then
dbms_output.put_line(SQLERRM);
end;
/

--5.1
create or replace function DELETE_SALE_FROM_DB return number
as
VSALE_ID sale.saleid%type;
saleid_null exception;
vprice sale.price%type;
vqty sale.qty%type;
vamt number;
vcustid sale.custid%type;
vprodid sale.prodid%type;
begin

select min(saleid) 
into VSALE_ID
from sale;
 
if (VSALE_ID is null) then
raise saleid_null;
end if;

select price,qty,custid,prodid
into vprice, vqty, vcustid, vprodid
from sale
where saleid = VSALE_ID;

vamt := vprice * vqty;

UPD_CUST_SALESYTD_IN_DB(vcustid,-vamt);
UPD_PROD_SALESYTD_IN_DB(vprodid,-vamt);

delete from sale
where saleid = VSALE_ID;

return VSALE_ID;
exception
when saleid_null then
raise_application_error(-20101,'No Sale Rows found');
when others then
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure DELETE_SALE_VIASQLDEV
as
vsale_id number;
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Deleting sale with smallest Saleid value');
vsale_id := DELETE_SALE_FROM_DB();
dbms_output.put_line('Deleted Sale OK.SaleID:'||vsale_id);
exception 
when others then
dbms_output.put_line(SQLERRM);
end;
/


create or replace procedure DELETE_ALL_SALES_FROM_DB
as
cust_rec customer%rowtype; 
prod_rec product%rowtype;
cursor cust_cur is 
select *
from customer;
cursor prod_cur is
select *
from product;
begin

delete from sale;

open cust_cur;
loop
  fetch cust_cur into cust_rec;
  exit when cust_cur%notfound;
  dbms_output.put_line('Cust ID:'||cust_rec.custid);
  update customer
  set sales_ytd = 0
  where custid = cust_rec.custid;
end loop;

open prod_cur;
loop
  fetch prod_cur into prod_rec;
  exit when prod_cur%notfound;
  dbms_output.put_line('Prod ID:'||prod_rec.prodid);
  update product
  set sales_ytd = 0
  where prodid = prod_rec.prodid;
end loop;
dbms_output.put_line('Deletion Ok');
commit;
exception
when others then
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure DELETE_ALL_SALES_VIASQLDEV as
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Deleting all sales data in Sale,Customer and Product tables');
DELETE_ALL_SALES_FROM_DB;
exception 
when others then
dbms_output.put_line(SQLERRM);
end;
/



--6.1
create or replace procedure DELETE_CUSTOMER (pcustid number) as
vcustid customer.custid%type;
v1custid customer.custid%type;
child_present exception;
custid_not_found exception;
cust_rec sale%rowtype;
cursor cust_cur is
select *
from sale;
begin
begin
select custid 
into vcustid 
from customer
where custid = pcustid;
exception 
when no_data_found then
raise custid_not_found;
end;
begin
open cust_cur;
loop
fetch cust_cur into cust_rec;
exit when cust_cur%notfound;
if(cust_rec.custid = pcustid) then
raise child_present;
end if;
end loop;
delete from customer
where    custid = pcustid;
dbms_output.put_line('Deleted Customer OK.');
end;
exception 
when custid_not_found then
raise_application_error(-20201, 'Customer ID not found');
when child_present then
raise_application_error (-20202, 'Customer cannot be deleted as sales exist');
when others then
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure DELETE_CUSTOMER_VIASQLDEV (pcustid number) as 
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Deleting Customer.Cust ID: '||pcustid);
DELETE_CUSTOMER(pcustid);
exception 
when others then
dbms_output.put_line(SQLERRM);
end;
/


create or replace procedure DELETE_PROD_FROM_DB (pprodid number) as
vprodid product.prodid%type;
v1prodid product.prodid%type;
child_present exception;
prodid_not_found exception;
prorec sale%rowtype;
cursor pro_cur is
select *
from sale;
begin
begin
select prodid 
into vprodid 
from product
where prodid = pprodid;
exception 
when no_data_found then
raise prodid_not_found;
end;

begin
open pro_cur;
loop
fetch pro_cur into prorec;
exit when pro_cur%notfound;
if(prorec.prodid=pprodid) then
raise child_present; 
end if;
end loop;
delete from product
where prodid = pprodid;
dbms_output.put_line('Deleted Product OK.');
end;
exception 
when prodid_not_found then
raise_application_error(-20301, 'Product ID not found');
when child_present then
raise_application_error (-20302, 'Product cannot be deleted as sales exist');
when others then
raise_application_error(-20000,SQLERRM);
end;
/

create or replace procedure DELETE_PROD_VIASQLDEV (pprodid number) as 
begin
dbms_output.put_line('--------------------------');
dbms_output.put_line('Deleting Product.Prod ID: '||pprodid);
DELETE_PROD_FROM_DB(pprodid);
exception
when others then
dbms_output.put_line(SQLERRM);
end;
/

