USE [master]
GO

/* ------ -- ------- -- ------ ------ ----
   script to install or update stored proc 
   ------ -- ------- -- ------ ------ ---- */
IF EXISTS (
        SELECT 1
        FROM sys.procedures
        WHERE name = 'sp_WhatIsUsingTempDB'
        )
    DROP PROC [sp_WhatIsUsingTempDB]
GO

/* =====================================================================================
   https://github.com/markwdavies/SQLServerUtilities/StoredProcs
   
   Procedure :	sp_WhatIsUsingTempDB
   
   Version   :	1.0
   Last Amended : October 2025

   Description:	Display details of sessions
                limit output to user sessions , optionally include system sessions as well

   Parameters : @UserOnly
					1 (default) exclude system sessions
					0  everything
				
   Usage :		EXEC sp_WhatIsUsingTempDB 
					@UserOnly = 1

   ===================================================================================== */
CREATE PROCEDURE [dbo].[sp_WhatIsUsingTempDB] (@UserOnly BIT = 1)
AS
BEGIN
    SELECT t1.session_id
        ,t1.request_id
        ,task_alloc_GB = CAST((t1.task_alloc_pages * 8. / 1024. / 1024.) AS NUMERIC(10, 1))
        ,task_dealloc_GB = CAST((t1.task_dealloc_pages * 8. / 1024. / 1024.) AS NUMERIC(10, 1))
        ,host = CASE 
            WHEN t1.session_id <= 50
                THEN 'SYS'
            ELSE s1.host_name
            END
        ,s1.login_name
        ,s1.STATUS
        ,s1.last_request_start_time
        ,s1.last_request_end_time
        ,s1.row_count
        ,s1.transaction_isolation_level
        ,query_text = COALESCE((
                SELECT SUBSTRING(TEXT, t2.statement_start_offset / 2 + 1, (
                            CASE 
                                WHEN statement_end_offset = - 1
                                    THEN LEN(CONVERT(NVARCHAR(MAX), TEXT)) * 2
                                ELSE statement_end_offset
                                END - t2.statement_start_offset
                            ) / 2)
                FROM sys.dm_exec_sql_text(t2.sql_handle)
                ), 'Not currently executing')
        ,query_plan = (
            SELECT query_plan
            FROM sys.dm_exec_query_plan(t2.plan_handle)
            )
    FROM (
        SELECT session_id
            ,request_id
            ,task_alloc_pages = SUM(internal_objects_alloc_page_count + user_objects_alloc_page_count)
            ,task_dealloc_pages = SUM(internal_objects_dealloc_page_count + user_objects_dealloc_page_count)
        FROM sys.dm_db_task_space_usage
        GROUP BY session_id
            ,request_id
        ) AS t1
    LEFT JOIN sys.dm_exec_requests AS t2 ON t1.session_id = t2.session_id
        AND t1.request_id = t2.request_id
    LEFT JOIN sys.dm_exec_sessions AS s1 ON t1.session_id = s1.session_id
    WHERE (
            (t1.session_id > 50)
            OR (@UserOnly = 0)
            )
        AND t1.session_id != @@SPID -- ignore this request itself
    ORDER BY t1.task_alloc_pages DESC;
END
