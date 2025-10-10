USE [master]
GO
/* ------ -- ------- -- ------ ------ ----
   script to install or update stored proc 
   ------ -- ------- -- ------ ------ ---- */
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_WhatIsRunning') DROP PROC [sp_WhatIsRunning]
GO
/* =====================================================================================
   https://github.com/markwdavies/SQLServerUtilities/StoredProcs
   
   Procedure :	sp_WhatIsRunning
   
   Version   :	2.2
   Last Amended : 15th May 2025

   Description:	Display details of sessions
                optionally limit output to backups/restores and/or active sessions only

   Parameters : @ActiveOnly (optional) 
				  0 for all requests (default)
				  1 for details for active sessions only
				@BackupsOnly (optional) 
				  0 for all requests (default)
				  1 for details running Backups only
				
   Usage :		EXEC sp_WhatIsRunning
                   @ActiveOnly = 0 , @BackupsOnly = 0

   ===================================================================================== */
CREATE PROCEDURE [dbo].[sp_WhatIsRunning] (@ActiveOnly bit = 0 , @BackupsOnly bit = 0)

AS

BEGIN

SELECT  r.start_time [Start Time]
      , r.session_id [SPID]
      , DB_NAME(r.database_id) [Database]
	  ,COALESCE(s.login_name,s.nt_domain +''+s.nt_user_name) [User]
      , SUBSTRING(t.text , ( r.statement_start_offset / 2 ) + 1 ,
                  CASE WHEN ((statement_end_offset = -1)
                            OR (statement_end_offset = 0))
                       THEN ( DATALENGTH(t.text) - r.statement_start_offset
                              / 2 ) + 1
                       ELSE ( r.statement_end_offset
                              - r.statement_start_offset ) / 2 + 1
                  END) [Executing SQL]
      , coalesce(s.status , r.status) status
      , r.command
      , r.wait_type
      , r.wait_time
      , r.wait_resource
      , r.last_wait_type
	  , r.percent_complete
FROM    sys.dm_exec_requests r
LEFT JOIN sys.dm_exec_sessions AS s
        ON r.session_id = s.session_id
        OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE   r.session_id != @@SPID -- don't show this query
        AND r.session_id > 50 -- don't show system queries
		AND ((@BackupsOnly = 0) 
		OR (r.command IN ( 'RESTORE DATABASE' , 'RESTORE LOG' , 'BACKUP DATABASE' ,'BACKUP LOG' )))
		AND ((@ActiveOnly = 0) OR (coalesce(s.status , r.status) = 'Running'))
ORDER BY r.start_time DESC;

END