USE [master];


GO
/* ------ -- ------- ------ -----
   script to remove  stored procs 
   ------ -- ------- ------ ----- */
/* =====================================================================================
   https://github.com/markwdavies/SQLServerUtilities/StoredProcs

   Last Amended : October 2025

   Description:	This script will remove any of the stored procs installed from 
                  this repository

   ===================================================================================== */
IF EXISTS (SELECT 1
           FROM   sys.procedures
           WHERE  name = 'sp_WhatWasRestored')
    DROP PROCEDURE [sp_WhatWasRestored];

IF EXISTS (SELECT 1
           FROM   sys.procedures
           WHERE  name = 'sp_WhereAreTheBackups')
    DROP PROCEDURE [sp_WhereAreTheBackups];

IF EXISTS (SELECT 1
           FROM   sys.procedures
           WHERE  name = 'sp_WhereAreTheFiles')
    DROP PROCEDURE [sp_WhereAreTheFiles];

IF EXISTS (SELECT 1
           FROM   sys.procedures
           WHERE  name = 'sp_WhatIsRunning')
    DROP PROCEDURE [sp_WhatIsRunning];

IF EXISTS (SELECT 1
           FROM   sys.procedures
           WHERE  name = 'sp_WhatWasBackedUp')
    DROP PROCEDURE [sp_WhatWasBackedUp];

IF EXISTS (SELECT 1
           FROM   sys.procedures
           WHERE  name = 'WhatIsUsingTempDB')
    DROP PROCEDURE [WhatIsUsingTempDB];