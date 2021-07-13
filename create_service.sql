
-- ///////////////////////////////////////////////////////////////////
-- /
-- ///////////////////////////////////////////////////////////////////
-- /
-- /$Header: /opt/apps/oracle/local/omx/mon/RCS/ip.sql,v 1.1 2000/03/30 13:42:07 oracle Exp $
-- /
-- /   NAME
-- /     create_service.sql
-- /
-- /   REVISION
-- /     $Revision: 1.1 $
-- /
-- /   AUTHOR
-- /     Gert Jan Willems
-- /
-- /   DESCRIPTION
-- /     Instance parameter report
-- /
-- /   RETURNS
-- /
-- /   NOTES
-- /
-- /   MODIFIED   (MM/DD/YY)
-- /    gjwillems  29/06/2021 - Creation
-- /
-- /                Copyright (c) 1999-2024 by Orametrix
-- /
-- /******************************************************************/

-- :: argv: parameter_name (l) or all {sn: ip}

define omx_script = 'create_service';
define omx_prog   = '&omx_script..sql'
define omx_title  = 'CReate Service'

-- start omxtitle

set lines 250 recsep off verify off pagesize 70

prompt Enter the service name : 
set termout off
define service_name='&1'
set termout on

DECLARE
  v_ServiceName VARCHAR2(100) := '&service_name'; 
BEGIN
  DBMS_SERVICE.create_service(
    service_name => v_ServiceName,
    network_name => v_ServiceName
  );
END;
/


@services
