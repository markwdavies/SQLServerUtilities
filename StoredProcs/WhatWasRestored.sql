USE [master]
GO
/* ------ -- ------- -- ------ ------ ----
   script to install or update stored proc 
   ------ -- ------- -- ------ ------ ---- */
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhatWasRestored') DROP PROC [sp_WhatWasRestored]
GO
/* =====================================================================================
   https://github.com/markwdavies/SQLServerUtilities/StoredProcs
   
   Procedure :	sp_WhatWasRestored
   
   Version   :	2.1
   Last Amended : 11th April 2023 

   Description:	Display details of latest DB restore including file used

   Parameters :   @DBName (optional) 
				Database Name
   				NULL for all (default)
		      @FullBackupsOnly (optional) 
				0 for all latest backups (default)
				1 for details of Full Backup Restores only

   Usage :		EXEC sp_WhatWasRestored
				@DBName = 'MyDB' , @FullBackupsOnly = 1
   ===================================================================================== */
CREATE PROCEDURE [dbo].[sp_WhatWasRestored]
     (@DBName NVARCHAR(128) = NULL , @FullBackupsOnly bit = 0)
AS

BEGIN
SELECT top 1000 r1.destination_database_name AS [Restored Database]
      , r1.restore_date AS [Restore Date]
	  , bmf.physical_device_name AS [Backup File Restored]
	  , CASE bs.[type] WHEN 'D' THEN 'Full' WHEN 'I' THEN 'Differential' WHEN 'L' THEN 'Transaction Log' ELSE 'Not Known' END AS [Backup File Type]
      , r1.[stop_at] 
FROM msdb.dbo.restorehistory r1
INNER JOIN msdb.dbo.backupset bs ON BS.backup_set_id = r1.backup_set_id
INNER JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE ((bs.database_name like @DBName) or (@DBName is NULL))
AND ((bs.type = 'D') or  (@FullBackupsOnly = 0))
ORDER by r1.restore_date DESC;
END

GO