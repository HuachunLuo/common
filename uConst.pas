{*******************************************************
                                                       
       ծȯ������                                       
                                                       
       ��Ȩ���� (C) 2017 ����ʤ����Ϣϵͳ���޹�˾       
                                                       
���ߣ��޻���
���ڣ�2017/7/22
˵���� �洢ϵͳ�������õ��ĳ�����

	
*******************************************************} 
UNIT UCONST;

INTERFACE
uses Messages;

CONST
  WM_MyMessage = WM_User + 1;

  CONFIGFILE = 'CONFIG.INI'; //�����ļ����ơ�
  SDBTIMEOUT = 'DBTIMEOUT'; //���ݿⳬʱʱ�䡣
  TABLELIST = 'TABLELIST.TXT'; //���ݿ��еı�(���صĲ���)
  CUSLIST = 'CUSTOMERLIST.TXT'; //���ݿ��еı�(���صĲ���)
  LASTUPDATEFILE = 'LASTUPDATE.INI'; //�ͻ����ر�������ʱ��

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

