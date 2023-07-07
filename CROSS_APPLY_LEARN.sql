use test

CREATE TABLE SV
(
    MASV [NVARCHAR](50) NOT NULL,
    MADT [NVARCHAR](50) NOT NULL,
);

CREATE TABLE SV_INFO
(
    MASV [NVARCHAR](50) NOT NULL PRIMARY KEY,
    FULL_NAME [NVARCHAR](50) NOT NULL,
);


INSERT INTO SV
( MASV, MADT )
VALUES
('SV01', 'DT0001'),('SV01', 'DT0002'),('SV01', 'MMT0001'),('SV01', 'MMT0002'),
('SV01', 'HTTT0002'),('SV01', 'MMT0001'),('SV01', 'MMT0002'),
('SV02', 'DT0001'),('SV02', 'DT0002'),('SV02', 'MMT0001'),
('SV03', 'DT0001'),('SV03', 'DT0002'),
('SV04', 'HTTT0001')


INSERT INTO SV_INFO
( MASV, FULL_NAME )
VALUES
('SV01', 'NGUYEN THI THUY DUYEN')
,('SV02', 'NGUYEN THI TUYET MAI HA')
,('SV03', 'HA TRAN ANH LINH')
,('SV04', 'TRAN VAN AN')


-- This is solutioon if you want change column to row in sql 
select SV_INFO.MASV, FULL_NAME, cross_table.MADT from SV_INFO 
cross apply (
        select(
            STUFF(
                (select ',' + MADT from SV
                where SV_INFO.MASV = SV.MASV
                for xml path(''))
                , 1
                , 1
                , ' '
            )
        ) MADT
    ) cross_table;



