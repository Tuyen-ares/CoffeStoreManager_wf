CREATE DATABASE QuanLyQuanCF
Go
USE QuanLyQuanCF
GO

--------------- CREATE TABLE-------------
------ FOOD
CREATE TABLE FOOD(
	idFood INT IDENTITY PRIMARY KEY,
	NameFOOD NVARCHAR(100) NOT NULL DEFAULT N'Na/n name',
	idCategory INT NOT NULL,
	price FLOAT NOT NULL DEFAULT 0,
)
GO
------ TABLE
CREATE TABLE TableFood
(
	idTable INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Trống',
	status NVARCHAR(100) NOT NULL  DEFAULT N'Trống' -- TRONG HOAC CO NGUOI
)
GO
------ FoodCategory
CREATE TABLE(
	idCategory INT IDENTITY PRIMARY KEY,
	nameCategory NVARCHAR(100) NOT NULL DEFAULT N'Na/n name',

)
GO
------ ACCOUNT
CREATE TABLE ACCOUNT(
	DisPlayName NVARCHAR(100) NOT NULL DEFAULT N'Tuyen',
	Username NVARCHAR(100)  PRIMARY KEY ,
	PASSWORD NVARCHAR(1000)  NOT NULL DEFAULT 0,
	Type INT  NOT NULL DEFAULT 0, -- 1: admin && 0 : staff
)
GO
------ BILL
CREATE TABLE BILL(
	idBILL INT IDENTITY PRIMARY KEY,
	DateCheckIn DATE NOT NULL,
	DateCheckOut DATE ,
	idTable INT NOT NULL,
	status INT NOT NULL -- 1: da thanh toan && 0 : chua thanh toans
)
GO
------ BillInfo
CREATE TABLE BillInfo(
	idBillInfo INT IDENTITY PRIMARY KEY,
	idBill INT NOT NULL,
	idFood int not null,
	count INT NOT NULL DEFAULT 0
)
GO
-- KHÓA NGOẠI
ALTER TABLE FOOD 
ADD CONSTRAINT FK_FODD_CAT
FOREIGN KEY(idCategory) REFERENCES FoodCategory(idCategory)
GO

ALTER TABLE BILL
ADD CONSTRAINT FK_BILL_TABLE
FOREIGN KEY(idTable) REFERENCES TableFood(idTable)
GO

ALTER TABLE BillInfo
ADD CONSTRAINT FK_BillInfo_BILL
FOREIGN KEY(idBill) REFERENCES BILL(idBill)
GO

ALTER TABLE BillInfo
ADD CONSTRAINT FK_BillInfo_food
FOREIGN KEY(idFood) REFERENCES FOOD(idFood)
GO


INSERT INTO ACCOUNT
VALUES
(N'LaHoanTuyen',N'Tuyendeptrai',N'123',1),
(N'staff',N'staff',N'123',0)
GO

-- Proc
CREATE PROC USP_GetAccountByUserName
@userName nvarchar(50)
AS
BEGIN
	SELECT *FROM ACCOUNT
	WHERE ACCOUNT.Username= @userName
END
GO

--EXEC USP_GetAccountByUserName @userName =  N'Tuyendeptrai'

--select *from ACCOUNT where Username = N'Tuyendeptrai' and ACCOUNT.PASSWORD = '123' 

CREATE PROC USP_Login
@userName nvarchar(100), @passWord nvarchar(100)
AS
BEGIN
	SELECT *FROM ACCOUNT
	WHERE ACCOUNT.Username= @userName
	AND ACCOUNT.PASSWORD = @passWord
END
GO
--EXEC USP_Login  N'Tuyendeptrai' , '123' 


DECLARE @i INT = 0

WHILE @i <= 10
BEGIN
	INSERT TableFood (name) values (N'Bàn '+ CAST(@i AS nvarchar(100)))
	SET @i = @i + 1
END

CREATE PROC USP_GetTableList
AS SELECT * FROM TableFood
GO




--THÊM BÀN
DECLARE @i INT = 0

WHILE @i <= 10
BEGIN
	INSERT TableFood (name) values (N'Bàn '+ CAST(@i AS nvarchar(100)))
	SET @i = @i + 1
END

--THÊM CATEGORY
INSERT FoodCategory
VALUES
(N'HẢI SẢN'),
(N'NÔNG SẢN'),
(N'CHIÊN'),
(N'NƯỚC')
GO

--THÊM MÓN ĂN
INSERT FOOD
VALUES
(N'MỰC 1 NẮNG',1,120000),
(N'NGHÊU HẤP',1,120000),
(N'DÚ DÊ NƯỚNG',2,120000),
(N'HEO RỪNG NƯỚNG XẢ',2,120000),
(N'KHOAI TÂY CHIÊN',2,15000),
(N'COCA COLA',4,12000),
(N'TRÀ ĐÁ',4,1200)
GO
--THÊM BILL
INSERT BILL
VALUES
(GETDATE(),NULL,1,0),
(GETDATE(),NULL,3,0),
(GETDATE(),GETDATE(),5,0)
GO
SELECT *FROM BILL
--THÊM BILL INFO
INSERT BillInfo(idBill,idFood,count)
VALUES
(1,1,2),
(1,2,2),
(1,4,5),
(2,2,2),
(2,3,2),
(2,4,1),
(3,2,2),
(3,4,2)
GO 
SELECT *FROM BILL
GO
SELECT * FROM BillInfo
GO
SELECT *FROM FOOD
SELECT *FROM FoodCategory


Select *from BILL where idTable = 3 and status = 0

SELECT *FROM BillInfo WHERE idBill = 3

SELECT F.NameFOOD, BI.count,F.price*BI.count AS TotalPrice
FROM BillInfo AS BI, BILL AS B, FOOD AS F
WHERE BI.idBill = B.idBILL AND BI.idFood = F.idFood AND B.idTable = 5 AND B.status=0

select *from FOOD where idCategory = 1

create  PROC USP_INSERTBill
@idTable INT
AS
BEGIN
	INSERT INTO BILL VALUES (GETDATE(),NULL, @idTable,0,0)
END
GO



EXEC USP_INSERTBill 1

CREATE PROC USP_InsertBillInfo
@idBill INT, @idFood INT, @count INT
AS
BEGIN
	INSERT INTO BillInfo(idBill,idFood,count) VALUES (@idBill,@idFood,@count)
END
GO

select MAX(idBILL) from BILL

ALTER PROC USP_InsertBillInfo
@idBill INT, @idFood INT, @count INT
AS
BEGIN

	DECLARE @isExitsBillInfo INT;
	DECLARE @FOODCOUNT INT = 1
	SELECT @isExitsBillInfo = BillInfo.idBillInfo,@FOODCOUNT = BillInfo.count 
	FROM BillInfo where idBILL = @idBill AND idFood = @idFood

	IF(@isExitsBillInfo > 0)
	BEGIN
	DECLARE @NEWCOUNT INT = @FOODCOUNT + @count	
	IF(@NEWCOUNT>0)
		UPDATE BillInfo SET count = @FOODCOUNT + @count WHERE idFood =@idFood
	ELSE
		DELETE BillInfo WHERE idBILL = @idBill AND idFood = @idFood
	END	
	ELSE
	BEGIN
			INSERT INTO BillInfo(idBill,idFood,count) VALUES (@idBill,@idFood,@count)
	END
END
GO

UPDATE BILL SET status = 1 WHERE idBILL = 5

SELECT * FROM BILL

CREATE TRIGGER UTG_UPDATE_BILLInfo
ON BillInfo FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @idBill INT
	SELECT @idBill = idBill FROM inserted

	DECLARE @idTable INT

	SELECT @idTable = idTable FROM BILL WHERE BILL.idBILL = @idBill AND status = 0

	UPDATE TableFood SET status = N'Có người' WHERE idTable = @idTable
END
GO

CREATE TRIGGER UTG_UPDATE_BILL
ON BILL FOR UPDATE
AS
BEGIN
	DECLARE @idBill INT
	SELECT @idBill = idBILL from inserted


	declare @idTable int

	select @idTable = idTable from BILL where idBILL = @idBill

	declare @count int = 0
	select count(*) from BILL where idTable = @idTable and status = 0

	if(@count = 0)
		update TableFood set status = N'Trống' WHERE idTable = @idTable
END
GO

ALTER TABLE BILL
ADD discount INT

UPDATE BILL set discount = 0

CREATE PROC USP_SwitchTable
@idTable1 int, @idTable2 int
AS BEGIN

	DECLARE @idFirstBill int
	DECLARE @idSecondBill int

	Select @idSecondBill = idBILL from BILL where idTable = @idTable2 and status = 0
	Select @idFirstBill =idBILL from BILL where idTable = @idTable1 and status = 0

	if(@idFirstBill is NULL)
	begin
		INSERT INTO BILL VALUES (GETDATE(),NULL, @idTable1,0,0)

		SELECT @idFirstBill = MAX(idBILL) from BILL
	end

	if(@idSecondBill = NULL)
	begin
		INSERT INTO BILL VALUES (GETDATE(),NULL, @idTable2,0,0)

		SELECT @idSecondBill = MAX(idBILL) from BILL
	end


	SELECT idBillInfo into IdBillInfoTable from BillInfo where idBill = @idFirstBill

	UPDATE BillInfo SET idBill = @idSecondBill where idBill = @idFirstBill

	UPDATE BillInfo SET idBill = @idFirstBill WHERE idBill in ( SELECT * FROM IdBillInfoTable)

	DROP TABLE IdBillInfoTable
END
GO
 





