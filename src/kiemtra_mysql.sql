use sakila;
create table Categories
(
category_id int primary key not null,
category_name varchar(50)
);
insert into Categories(category_id,category_name)
values
(1 , 'candy'),
(2, 'learning tools'),
(3, 'clothes');

create table Product2
(
product_id int primary key not null,
product_name varchar(30),
category_id int ,
price double,
foreign key (category_id) references Categories(category_id)
);
insert into Product2(product_id, product_name, category_id, price)
values
(1, 'cake', 1, 2000),
(2, 'pen', 2, 5000),
(3, 'shirt', 3, 20000),
(4, 'trousers', 3, 25000);

create table Customers
(
customer_id int primary key not null,
customer_name varchar(30),
email varchar(30)
);
insert into Customers(customer_id, customer_name, email)
values
(1, 'Hoang', 'hoang@123'),
(2, 'Thi', 'thi@123'),
(3, 'Phuong', 'phuong@123');

create table Orders
(
order_id int primary key not null,
customer_id int,
order_date date,
foreign key (customer_id) references Customers(customer_id)
);
insert into Orders(order_id, customer_id, order_date)
values
(1, 1, '2023-02-20'),
(2, 1, '2023-07-15'),
(3, 2, '2023-09-27');


create table OrderDetails
(
order_detail_id int primary key not null,
order_id int,
product_id  int,
quantity  int,
foreign key (order_id) references Orders(order_id),
foreign key(product_id) references Product2(product_id)
);

insert into OrderDetails(order_detail_id, order_id, product_id, quantity)
values
(1, 1, 1, 2),
(2, 2, 2, 2),
(3, 1, 3, 1),
(4, 3, 1, 3);

select Product2.* from Product2
left join OrderDetails on Product2.product_id=OrderDetails.product_id
left join Orders on OrderDetails.order_id = Orders.order_id
where Orders.order_id = 1;

-- Tính tổng số tiền trong một đơn đặt hàng cụ thể.
select O.order_id, SUM(P.price * OD.quantity) as TotalPrice
from Orders O
inner join OrderDetails OD on O.order_id = OD.order_id
inner join Product2 P on OD.product_id = P.product_id
where O.order_id = 1;

-- Lấy danh sách các sản phẩm chưa có trong bất kỳ đơn đặt hàng nào.
select P.product_id, P.product_name
from Product2 P
left join OrderDetails OD on P.product_id = OD.product_id
where OD.order_id is null;

-- Đếm số lượng sản phẩm trong mỗi danh mục.
select C.category_id, C.category_name, COUNT(P2.product_id) as total_products
from Categories C
left join Product2 P2 on C.category_id = P2.category_id
group by C.category_id, C.category_name
order by .category_id;

-- Tính tổng số lượng sản phẩm đã đặt bởi mỗi khách hàng
select C.customer_id, C.customer_name, SUM(OD.quantity) as TotalQuantity
from Customers C
left join Orders O on C.customer_id = O.customer_id
left join OrderDetails OD on O.order_id = OD.order_id
group by C.customer_id, C.customer_name
order by C.customer_id;

-- Lấy thông tin danh mục có nhiều sản phẩm nhất
select C.category_id, C.category_name, COUNT(P2.product_id) as TotalProducts
from Categories C
left join Product2 P2 on C.category_id = P2.category_id
group by C.category_id, C.category_name
having TotalProducts = (
    select MAX(ProductCount)
    from (
        select category_id, COUNT(product_id) as ProductCount
        from Product2
       group by category_id
    ) as CountTable
);

-- Tính tổng số sản phẩm đã được đặt cho mỗi danh mục
select C.category_id, C.category_name, SUM(OD.quantity) as TotalQuantity
from Categories C
inner join Product2 P2 on C.category_id = P2.category_id
inner join OrderDetails OD on P2.product_id = OD.product_id
group by C.category_id, C.category_name
order by C.category_id;

-- Lấy thông tin về top 3 khách hàng có số lượng sản phẩm đặt hàng lớn nhất (customer_id, customer_name, total_ordered)
select C.customer_id, C.customer_name, SUM(OD.quantity) as total_ordered
from Customers C
inner join Orders O ON C.customer_id = O.customer_id
inner join OrderDetails OD ON O.order_id = OD.order_id
group by C.customer_id, C.customer_name
order by total_ordered DESC
limit 3;

-- Lấy thông tin về khách hàng đã đặt hàng nhiều hơn một lần trong khoảng thời gian cụ thể từ ngày A -> ngày B (customer_id, customer_name, total_orders)
select C.customer_id, C.customer_name, COUNT(O.order_id) AS total_orders
from Customers C
inner join Orders O on C.customer_id = O.customer_id
where O.order_date between '2023-02-20' and '2023-03-20'
group by C.customer_id, C.customer_name
having total_orders > 1;

-- Lấy thông tin về các sản phẩm đã được đặt hàng nhiều lần nhất và số lượng đơn đặt hàng tương ứng (product_id, product_name, total_ordered)
select P.product_id, P.product_name, COUNT(O.order_id) as total_ordered
from Product2 P
inner join OrderDetails OD on P.product_id = OD.product_id
inner join Orders O on OD.order_id = O.order_id
group by  P.product_id, P.product_name
order by total_ordered desc
limit 1;