USE [master]
GO
/* ------ -- ------- -- ------ ------ ----
   script to install or update stored proc 
   ------ -- ------- -- ------ ------ ---- */
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhereAreTheBackups') DROP PROC [sp_WhereAreTheBackups]
GO
/* =====================================================================================
   https://github.com/markwdavies/SQLServerUtilities/StoredProcs
   
   Procedure :	sp_WhereAreTheBackups
   
   Version   :	2.1
   Last Amended : 11th April 2023 

   Description:	Display the location and size of Database backups taken on the 
   				current instance

   Parameters : @DBName (optional) 
					Database Name
   					NULL for all (default)
				@FullBackupsOnly (optional) 
					0 for all Backups (defaullt)
					1 for Full Only

   Usage :		EXEC sp_WhereAreTheBackups
				@DBName = 'MyDB' , @FullBackupsOnly = 1
   ===================================================================================== */
CREATE PROCEDURE [dbo].[sp_WhereAreTheBackups]
     (@DBName NVARCHAR(128) = NULL , @FullBackupsOnly bit = 0)
AS

BEGIN
	SELECT top 1000
		bs.database_name AS [Database Name],
		bmf.physical_device_name AS [Backup File],
		CONVERT(decimal(18,2),(bs.backup_size)/1024/1024) AS [Size in MB],
		CONVERT(decimal(18,2),(bs.backup_size)/1024/1024/1024) AS [Size in GB],
		CONVERT(decimal(18,2),(bs.compressed_backup_size)/1024/1024) AS [Compressed Size in MB],
		CONVERT(decimal(18,2),(bs.compressed_backup_size)/1024/1024/1024) AS [Compressed Size in GB],
		CAST(DATEDIFF(second, bs.backup_start_date,bs.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' AS [Time Taken],
		bs.backup_start_date AS [Backup Started],
		CAST(bs.first_lsn AS VARCHAR(50)) AS [First LSN],
		CAST(bs.last_lsn AS VARCHAR(50)) AS [Last LSN],
		CASE bs.[type] WHEN 'D' THEN 'Full' WHEN 'I' THEN 'Differential' WHEN 'L' THEN 'Transaction Log' ELSE 'Not Known' END AS [Backup Type]
	FROM msdb.dbo.backupset bs
	INNER JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
	WHERE ((bs.database_name like @DBName) or (@DBName is NULL))
	AND ((bs.type = 'D') or  (@FullBackupsOnly = 0))
	ORDER BY backup_start_date DESC;
END

GO