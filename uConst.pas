{*******************************************************
                                                       
       债券服务器                                       
                                                       
       版权所有 (C) 2017 精诚胜龙信息系统有限公司       
                                                       
作者：罗华春
日期：2017/7/22
说明： 存储系统中所有用到的常量。

	
*******************************************************} 
UNIT UCONST;

INTERFACE
uses Messages;

CONST
  WM_MyMessage = WM_User + 1;

  CONFIGFILE = 'CONFIG.INI'; //配置文件名称。
  SDBTIMEOUT = 'DBTIMEOUT'; //数据库超时时间。
  TABLELIST = 'TABLELIST.TXT'; //数据库中的表(加载的部分)
  CUSLIST = 'CUSTOMERLIST.TXT'; //数据库中的表(加载的部分)
  LASTUPDATEFILE = 'LASTUPDATE.INI'; //客户加载表最后更新时间

  SDBINFO='DBINFO';
  SDBINFOSERVERPORT='DBINFOSERVERPORT';
  SDBINFOADDR = 'DBINFOADDR';
  SDBINFONAME = 'DBINFONAME';
  SDBINFOPASSWORD = 'DBINFOPASSWORD';
  SDBINFOPORT = 'DBINFOPORT';
  SDBINFOUSER = 'DBINFOUSER';
  SDBINFOPROVIDER = 'DBINFOPROVIDER';

  SDBLOG='DBLOG';
  SLOGADDR = 'DBLOGADDR';
  SLOGNAME = 'DBLOGNAME';
  SLOGPASSWORD = 'DBLOGPASSWORD';
  SLOGPORT = 'DBLOGPORT';
  SLOGUSER = 'DBLOGUSER';
  SDBLOGPROVIDER = 'DBLOGPROVIDER';

  SCOMMON = 'COMMON';
  SAUTOSTART = 'AUTOSTART';

  S_MSSQL = 'SQL SERVER';
  S_ORACLE = 'ORACLE';
  SPORT='PORT';
  SLOGLEVEL = 'LOGLEVEL';
  SMAXSESSION = 'MAXSESSION';


IMPLEMENTATION

END.

