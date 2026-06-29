--1. List all customers
select distinct id,FirstName+' '+LastName as FullName from Customer;
 

--2. List the first name, last name, and city of all customers
select distinct FirstName, LastName, City  from Customer;


--3. List the customers in Sweden. Remember it is "Sweden" and NOT "sweden" because filtering
select * from Customer c
where Country='Sweden';
 

--4. Create a copy of Supplier table. Update the city to Sydney for supplier starting with letter P.
 
--select * into Supplier_copy  --create a copy of supplier table 
--from Supplier;

update Supplier_copy   -- update the city column
set City ='Sydney'
where CompanyName like 'P%';
 

--5. Create a copy of Products table and Delete all products with unit price higher than $50.

--select * into Product_copy  --create copy of product table
--from Product;

Delete from Product_copy	 -- delete records
where UnitPrice >50;


--6. List the number of customers in each country

select country, count(distinct id) as total_customers from Customer
group by Country;


--7. List the number of customers in each country sorted high to low

select country, count(distinct id) as total_customers from Customer
group by Country
order by total_customers desc;


--8. List the total amount for items ordered by each customer

select  CustomerId,sum(TotalAmount) as total_amount 
from Orders
group by CustomerId;


/*9. List the number of customers in each country. Only include countries with more than 10
customers.*/

select country, count(distinct id) as total_customers from Customer
group by Country
having count(distinct id)>10;


/*10. List the number of customers in each country, except the USA, sorted high to low. Only
include countries with 9 or more customers.*/

select Country, count(distinct id) as total_customers
from Customer
where Country not in ('USA')
group by Country
having count(distinct id)>9
order by total_customers desc;


--11. List all customers whose first name or last name contains "ill".
select distinct id,FirstName+' '+LastName as FullName 
from Customer
where FirstName LIKE '%ill%' OR LastName LIKE '%ill%';


--12. List all customers whose average of their total order amount is between $1000 and
--$1200.Limit your output to 5 results.
select  CustomerId,avg(TotalAmount) as avg_total_amount 
from Orders
group by CustomerId
having avg(TotalAmount) between 1000 and 1200
order by avg_total_amount
offset 0 rows 
fetch next 5 rows only;


--13. List all suppliers in the 'USA', 'Japan', and 'Germany', ordered by country from A-Z, and then
--by company name in reverse order.
select id,CompanyName,ContactName,Country from Supplier
where Country in ('USA', 'Japan', 'Germany')
order by Country, CompanyName Desc;


--14. Show all orders, sorted by total amount (the largest amount first), within each year.
select Id, year(OrderDate) as Year, sum(TotalAmount) as total_amount 
from Orders
group by Id,year(OrderDate)
order by total_amount desc;


 --15. Products with UnitPrice greater than 50 are not selling despite promotions. You are asked to
--discontinue products over $25. Write a query to relfelct this. Do this in the copy of the Product
--table. DO NOT perform the update operation in the Product table.
update Product_copy
set IsDiscontinued = 1
where UnitPrice > 25;


--16. List top 10 most expensive products 
select distinct top 10 id,ProductName,UnitPrice from Product
order by UnitPrice desc;
 

--17. Get all but the 10 most expensive products sorted by price 
(-- means All but the 10 most expensive” : everything else except those top 10.)
select distinct id,ProductName,UnitPrice 
from Product
order by UnitPrice desc
offset 10 rows;


--18. Get the 10th to 15th most expensive products sorted by price

--METHOD 1
select distinct id,ProductName,UnitPrice 
from Product
order by UnitPrice desc
offset 9 rows
Fetch next 6 rows only;

--METHOD 2

select * from (
		select *, Dense_Rank() over(order by UnitPrice desc) as Rank
		from Product ) as x
where RANK Between 10 and 15;

--METHOD 3

with nth_expensive_products
as
	( select *, DENSE_RANK() over(order by UnitPrice desc) as Rank
	  from Product  
	  )
select * from nth_expensive_products
where Rank between 10 and 15;


--19. Write a query to get the number of supplier countries. Do not count duplicate values.
select count(distinct Country) as TotalSupplierCountries from Supplier;


--20. Find the total sales cost in each month of the year 2013.
 select month(OrderDate)as Month,sum(TotalAmount) as TotalSales 
 from Orders
 where year(OrderDate)=2013
 group by month(OrderDate);


--21. List all products with names that start with 'Ca'.
select distinct * from Product
where ProductName like 'Ca%';


--22. List all products that start with 'Cha' or 'Chan' and have one more character.
select distinct * from Product
where ProductName like 'Chan_%' or ProductName like 'Cha_%' ;


/*23. Your manager notices there are some suppliers without fax numbers. He seeks your help to
get a list of suppliers with remark as "No fax number" for suppliers who do not have fax
numbers (fax numbers might be null or blank).Also, Fax number should be displayed for
customer with fax numbers*/

select Id,CompanyName,ContactName,City,Phone,
case 
	 when Fax is Null then 'No fax number'
	 else Fax 
end as Fax
from Supplier;


--24. List all orders, their orderDates with product names, quantities, and prices.
select  o.id,o.OrderDate,p.ProductName,oi.Quantity,p.UnitPrice from Orders o 
inner join OrderItem oi
on o.Id=oi.OrderId
inner join Product p
on oi.ProductId = p.Id;


--25. List all customers who have not placed any Orders.
select c.Id, c.FirstName+' '+c.LastName as FullName,c.City,Phone
from Customer c 
left join Orders o
on c.Id=o.CustomerId
where o.id is null;


/*26. List suppliers that have no customers in their country, and customers that have no suppliers
in their country, and customers and suppliers that are from the same country*/

select c.FirstName+' '+c.LastName as CustomerName, s.City, s.Country, s.CompanyName as SupplierName
from Customer c
right join Supplier s
on c.City=s.City and c.Country=s.Country
where c.FirstName is null
union
select c.FirstName+' '+c.LastName as CustomerName, c.City, c.Country, s.CompanyName as SupplierName
from Customer c
left join Supplier s
on c.City=s.City and c.Country=s.Country
where s.CompanyName is null
union
select c.FirstName+' '+c.LastName as CustomerName, s.City, s.Country, s.CompanyName as SupplierName
from Customer c
inner join Supplier s
on c.City=s.City and c.Country=s.Country ;
   

/*27. Match customers that are from the same city and country. That is you are asked to give a list
of customers that are from same country and city. Display firstname, lastname, city and
coutntry of such customers.*/

select c1.FirstName+' '+c1.LastName as Custome1, 
	   c2.FirstName+' '+c2.LastName as Custome2, 
	   c1.City, 
	   c1.country
from Customer c1
join Customer c2
on c1.City=c2.City and c1.Country=c2.Country and c1.id < c2.id;

 
/*28. List all Suppliers and Customers. Give a Label in a separate column as 'Suppliers' if he is a
supplier and 'Customer' if he is a customer accordingly. Also, do not display firstname and
lastname as twoi fields; Display Full name of customer or supplier. */

--METHOD 1
 SELECT ID ,FirstName+' '+LastName as ContactName,City,Country,'Customer' AS TYPE 
 FROM Customer
 UNION ALL 
 SELECT ID,ContactName,City,Country,'Supplier' AS TYPE 
 FROM Supplier_copy;

 --METHOD 2
SELECT *,
  CASE 
		WHEN ContactName in (select ContactName from Supplier)
		THEN 'Supplier'
		else 'Customer'
  END AS TYPE  
       FROM (
				SELECT  ID ,FirstName+' '+LastName as ContactName,City,Country,Phone 
				FROM Customer
				UNION ALL 
				SELECT ID,ContactName,City,Country,Phone 
				FROM Supplier
				) AS X;


/*29. Create a copy of orders table. In this copy table, now add a column city of type varchar (40).
Update this city column using the city info in customers table*/

select * into Orders_copy  --create copy of Orders table
from Orders;

alter table Orders_copy   --add column 
add City varchar(40);

update Orders_copy    --add data into that column 
SET City = c.City
from Orders_copy oc
inner join Customer c
on oc.CustomerId = c.Id;

GO

select * from Orders_copy;
 
 *****************************************************************************************************
/*30. Suppose you would like to see the last OrderID and the OrderDate for this last order that
was shipped to 'Paris'. Along with that information, say you would also like to see the
OrderDate for the last order shipped regardless of the Shipping City. In addition to this, you
would also like to calculate the difference in days between these two OrderDates that you get.
Write a single query which performs this.*/
 ****************************************************************************************************--METHOD 1select *, Datediff(day,LastParisOrderDate,LastGlobalOrderDate) as Diff_Btw_Daysfrom (	   select top 1 o.Id, o.orderDate as LastParisOrderDate,(select max(orderdate) from orders) as LastGlobalOrderDate	   from Orders o	   inner join Customer c 	   on o.CustomerId=c.Id 	   where city in (select city from Customer where city='Paris')	   order by LastParisOrderDate desc		)  as x; --METHOD 2 WITH LastParisOrder AS (
    SELECT TOP 1 o.Id AS LastParisOrderID, o.OrderDate AS LastParisOrderDate
    FROM Orders o
    INNER JOIN Customer c ON o.CustomerId = c.Id
    WHERE c.City = 'Paris'
    ORDER BY o.OrderDate DESC
),
LastGlobalOrder AS (
    SELECT TOP 1 o.Id AS GlobalOrderID, o.OrderDate AS GlobalOrderDate
    FROM Orders o
    ORDER BY o.OrderDate DESC
)
SELECT 
    p.LastParisOrderID,
    p.LastParisOrderDate,
    g.GlobalOrderDate,
    DATEDIFF(DAY, p.LastParisOrderDate, g.GlobalOrderDate) AS DaysDifference
FROM LastParisOrder p
CROSS JOIN LastGlobalOrder g;
 /*31. Find those customer countries who do not have suppliers. This might help you provide
	   better delivery time to customers by adding suppliers to these countires. Use SubQueries.*/

--METHOD 1
select distinct Country 
from Customer 
where Country not in (select distinct Country from Supplier);
 
--METHOD 2

SELECT DISTINCT c.Country
FROM Customer c
LEFT JOIN Supplier s 
ON c.Country = s.Country
WHERE s.Country IS NULL;

 
/*32. Suppose a company would like to do some targeted marketing where it would contact
      customers in the country with the fewest number of orders. It is hoped that this targeted
      marketing will increase the overall sales in the targeted country. You are asked to write a query
      to get all details of such customers from top 5 countries with fewest numbers of orders. Use subqueries.*/

select * from Customer
where Country in (
				   select top 5 c.Country from Customer c
				   left join Orders o 
				   on c.Id=o.CustomerId
				   group by c.Country
				   order by count(o.Id) 
				   )  ;


/*33. Lets say you want report of all distinct "OrderIDs" where the customer did not purchase
	  more than 10% of the average quantity sold for a given product. This way you could review
	  these orders, and possibly contact the customers, to help determine if there was a reason for
	  the low quantity order. Write a query to report such orderIDs.*/

--Method 1  only distinct orderid's 
select distinct OI.OrderId 
from (
	 select OrderID, ProductId, Quantity, Avg(Quantity) over ( partition by ProductId) as AvgQty
	 from OrderItem
	 ) as OI 
where Quantity <= 0.1 * AvgQty

--Method 2 with distinct orderid customer and product details  for determining why customer pruchase low quantity 
 select distinct C.Id, C.FirstName+' '+C.LastName as CustName, C.City,C.Country, C.Phone, OI.Quantity,AvgQty, P.ProductName, OI.OrderId 
 from OrderItem OI 
 join (
		select ProductId, avg(Quantity) as AvgQty
		from OrderItem
 		group by ProductId
	   ) as  QtyAvg
 on OI.ProductId =  QtyAvg.ProductId
 join Orders O on O.Id = OI.OrderId
 join Customer C on O.CustomerId = C.Id
 join Product P on OI.ProductId = P.Id
 where OI.Quantity <= 0.1 * AvgQty

 
/*34. Find Customers whose total orderitem amount is greater than 7500$ for the year 2013. The
	  total order item amount for 1 order for a customer is calculated using the formula UnitPrice *
	  Quantity * (1 - Discount). DO NOT consider the total amount column from 'Order' table to
	  calculate the total orderItem for a customer.*/

--METHOD 1

select CustomerId,Sum(TotalAmount) as TotalAmount
from (
		select o.CustomerId, oi.Id, (oi.Quantity*oi.UnitPrice*(1-oi.Discount )) as TotalAmount
		from OrderItem oi
		inner join Orders o
		on oi.OrderId=o.Id
		where year(OrderDate) = 2013 
) as x
group by CustomerId
having Sum(TotalAmount)>7500;

--MEHTOD 2               

select o.CustomerId, sum(oi.Quantity*oi.UnitPrice*(1-oi.Discount)) as TotalAmount
from OrderItem oi
inner join Orders o 
on o.Id=oi.OrderId
where year(OrderDate)=2013
group by o.CustomerId 
having sum(oi.Quantity*oi.UnitPrice*(1-oi.Discount))>7500;


 /*35. Display the top two customers, based on the total dollar amount associated with their
       orders, per country. The dollar amount is calculated as OI.unitprice * OI.Quantity * (1 -
       OI.Discount). You might want to perform a query like this so you can reward these customers,
       since they buy the most per country.
       Please note: if you receive the error message for this question "This type of correlated subquery
       pattern is not supported yet", that is totally fine.*/select *from (		select *, Dense_Rank() over (partition by Country order by TotalAmount desc) as Ranks		from ( 			  select c.Id, c.FIRSTNAME+' '+c.LastName AS CUST_NAME, c.Country,c.Phone,sum(OI.unitprice * OI.Quantity * (1 -OI.Discount)) AS TotalAmount			  from OrderItem oi			  inner join Orders o			  on oi.OrderId=o.Id			  inner join Customer c			  on o.CustomerId=c.Id			  group by  c.Id, c.FIRSTNAME+' '+c.LastName, c.Country, c.Phone			  ) as x	)as ywhere Ranks <= 2;--36. Create a View of Products whose unit price is above average Price.

CREATE VIEW price_above_average AS
select id, ProductName from Product
where UnitPrice > (select avg(UnitPrice) from Product);
 
GO

select * from price_above_average;

--Note: To Compare each product’s unit price against the average selling price of that product across orders  
create view PriceAboveAvg as 

select P.Id,P.ProductName,P.UnitPrice,OI.AvgPrice from Product P
join (select ProductId,avg(UnitPrice) as AvgPrice from OrderItem group by ProductId) as OI
on P.Id = OI.ProductId
where UnitPrice >AvgPrice;
go

select * from PriceAboveAvg
order by Id

/*37. Write a store procedure that performs the following action:
	  Check if Product_copy table (this is a copy of Product table) is present. If table exists, the
	  procedure should drop this table first and recreated.
	  Add a column Supplier_name in this copy table. Update this column with that of
	  'CompanyName' column from Supplier tab*/
  
CREATE PROCEDURE CHECK_AND_ADD
AS 
BEGIN 
    IF EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_NAME = 'Product_copy'
    )
    BEGIN 
        DROP TABLE Product_copy;
    END;

    SELECT * INTO Product_copy FROM Product;

    ALTER TABLE Product_copy
    ADD SupplierName NVARCHAR(48);

    UPDATE Product_copy
    SET SupplierName = s.ContactName
    FROM Product_copy pc
    INNER JOIN Supplier s 
	ON pc.SupplierId = s.Id;
END;
GO-- Important: Ends the procedure definition

EXEC CHECK_AND_ADD;  --To Execute the stored procedure in separate batch

Go
SELECT TOP 10 * FROM Product_copy;  
  