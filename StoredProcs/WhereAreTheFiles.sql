USE [master]
GO
/* ------ -- ------- -- ------ ------ ----
   script to install or update stored proc 
   ------ -- ------- -- ------ ------ ---- */
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhereAreTheFiles') DROP PROC [sp_WhereAreThefiles]
GO
/* =====================================================================================
   https://github.com/markwdavies/SQLServerUtilities/StoredProcs
   
   Procedure :	sp_WhereAreTheFiles
   
   Version   :	2.1
   Last Amended : 11th April 2023 

   Description: Display the location and size of Database Data and Log Files 

   Parameters : @DBName (optional) 
                    Database Name
                    NULL for all (default)

   Usage :	EXEC sp_WhereAreTheFiles
               @DBName = 'MyDB' 
   ===================================================================================== */
CREATE PROCEDURE [dbo].[sp_WhereAreTheFiles]
     (@DBName NVARCHAR(128) = NULL)
AS

BEGIN
     SELECT DB_NAME([database_id]) AS [Database Name]
      , smf.[file_id] AS [File ID]
      , smf.name AS [Logical Name]
      , smf.physical_name AS [Physical Location]
      , smf.type_desc AS [File Type]
      , smf.state_desc AS [State]
      , case when smf.[database_id] <> 2 THEN CONVERT(BIGINT , smf.size / 128.0) ELSE CONVERT(BIGINT , tdf.size / 128.0) END  AS [Total Size in MB]
     FROM sys.master_files smf WITH ( NOLOCK )
          LEFT JOIN tempdb.sys.database_files tdf
          ON tdf.file_id = smf.file_id AND smf.database_id = 2
     WHERE (DB_NAME(smf.[database_id]) like @DBName) or (@DBName is NULL)
     ORDER BY smf.physical_name , DB_NAME(smf.[database_id]);
END

GO