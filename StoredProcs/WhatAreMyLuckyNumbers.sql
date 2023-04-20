USE [master]
GO
/* ------ -- ------- -- ------ ------ ----
   script to install or update stored proc 
   ------ -- ------- -- ------ ------ ---- */
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhatAreMyLuckyNumbers') DROP PROC [sp_WhatAreMyLuckyNumbers]
GO
/* =====================================================================================
   https://github.com/markwdavies/SQLServerUtilities/StoredProcs
   
   Procedure :	sp_WhatAreMyLuckyNumbers
   
   Version   :	2.1
   Last Amended : 11th April 2023 

   Description:	Select Unique Random Small Numbers - Maximum value 255

   Parameters : @MaxNumber (optional) Default 49
				Highest Number
		        @HowMany (optional) Default 6

   Usage :		EXEC sp_WhatAreMyLuckyNumbers
				@MaxNumber = 10 , @HowMany = 5
   ===================================================================================== */
CREATE PROCEDURE [dbo].[sp_WhatAreMyLuckyNumbers]
     (@MaxNumber tinyint = 49 , @HowMany tinyint = 6 )
AS

BEGIN
DECLARE @count smallint = 1
DECLARE @rowcount smallint = 0
DECLARE @output varchar(255) = ''
DECLARE @table table (id smallint identity(1,1) , guid uniqueidentifier )
IF @HowMany > @MaxNumber set @HowMany = @MaxNumber
WHILE @count <= @MaxNumber
BEGIN
   INSERT INTO @table (guid) SELECT newid()
   set @count = @count+1
END
SELECT @rowcount =  count(*) FROM @table
WHILE @rowcount <> @HowMany
BEGIN
   DELETE FROM @table WHERE id = checksum(newid()) %(@MaxNumber + 1)
   SELECT @rowcount =  count(*) FROM @table
END
SET @output = 'Your Lucky Numbers Are : ' + (SELECT rtrim(cast(id as char(3)))  + ',' FROM @table FOR XML PATH('') )
SELECT substring(@output , 1 , len(@output) - 1) AS [Result]
END
GO