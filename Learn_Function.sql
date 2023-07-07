
/*
	CẤU TRÚC FUNCTION
	GO
	CREATE FUNCTION name_func()
	RETURNS type_of data_return
	AS 
	BEGIN 
	END
	GO

- Có thể xuất hiện gạch chân đỏ dưới tên hàm nếu không nằm trong cặp chữ GO, Hoặc trước nó có câu lệnh khác cũng sẽ báo lỗi
- Phải luôn có giá trị trả về
- Gọi function phải đưa vào trong câu try vấn hay đi kèm câu lệnh không thể đi khơi khơi

*/

GO
-- Dạng đơn giản có thể return trực tiếp luôn 
create function basic()
returns table 
as return select * from learn
GO

select * from basic()

GO
create function UF_GetSalaryOfTeacher(@MAGV int)
returns int
as 
begin
	declare @luong int
	select @luong = LUONG from learn where MAGV = @MAGV
	return @luong
end
GO

/*
	CÁCH THỰC THI FUNCTION
	Hai cách gọi hàm khi có truyền tham số nhưng phải kèm theo chữ dbo. 
	Nếu không sẽ gặp lỗi 'UF_GetSalaryOfTeacher' is not a recognized built-in function name.
*/
select * from basic()
select dbo.UF_GetSalaryOfTeacher(1) -- có thể sử dụng as select dbo.UF_GetSalaryOfTeacher(1) AS RESULT
print dbo.UF_GetSalaryOfTeacher(1)
-- select * from UF_ReturnTable(2200) khi cần return về một bảng rõ ràng phải thêm * vào

select dbo.UF_GetSalaryOfTeacher(MAGV) from dbo.learn -- Truyền vào cả cột

-------------------------------------------------------------------------------
-- Tạo function tính một số truyền vào có phải số chẵn hay không

GO
alter function UF_IsOdd(@number int)
returns char(20)
as 
begin
	IF (@number % 2 = 0) 
		RETURN ('So CHAN')
	ELSE
		RETURN ('So LE')
	RETURN ('So vua nhap la so khong xac dinh')
end
GO
select dbo.UF_IsOdd(MAGV) from dbo.learn;
print dbo.UF_IsOdd(2);


-----------------------------------------------
-- Trả về một bảng chứa theo biến truyền vào 
GO
create function UF_ReturnTable(@Luong1 int)
returns @T table (MonPhuTrach varchar(20), Luong int)
as 
begin
	insert into @T 
	select MABM, LUONG from learn where LUONG > @Luong1
	return
end
GO

select * from UF_ReturnTable(2200) -- EXECU

use learn_function


GO
create function UF_ReturnAddingSalary(@Luong int)
returns int
as 
begin
	return @Luong + 100
end
GO

select *, dbo.UF_ReturnAddingSalary(luong) as LUONG_ADDED from learn