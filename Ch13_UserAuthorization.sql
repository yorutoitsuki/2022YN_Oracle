--<북스 13장 - 사용자 권한과 테이블 스페이스>

--[테이블스페이스]------------------------------------------------
--오라클에서는 Data file이라는 물리적 파일 형태로 저장하고
--이러한  Data file이 하나 이상 모여서 Tablespace라는 논리적인 공간을 형성함

/* 물리적 단위       논리적 단위
 *           	  DATABASE
 *            	     |
 * datafile 	 TABLESPACE : 데이터 저장 단위 중 가장 상위에 있는 단위
 * (*.dbf)      	 |
 *            	  segment : 1개의 segment는 여러 개의 extent로 구성(예)table, 트리거 등
 *               	 |
 *          	  extent  : 1개의 extent는 여러 개의 DB block으로 구성
 *               	 |      extent는 반드시 메모리에 연속된 공간을 잡아야함(단편화가 많으면 디스크 조각모음으로 단편화 해결)
 * 
 *         		 DB block : 메모리나 디스크에서 I/O할 수 있는 최소 단위
 *         
 */

--※ 트리거 : 데이터의 입력, 추가, 삭제 등의 이벤트가 발생할 때마다 자동으로 수행되는 사용자 정의 프로시저

-- [ 테이블스페이스 관련 Dictionary(사전) ] 
/*
    .DBA_TABLESPACES : 모든 테이블스페이스의 저장정보 및 상태정보를 갖고 있는 Dictionary
    .DBA_DATA_FILES  : 테이블스페이스의 파일정보
    .DBA_FREE_SPACE  : 테이블스페이스의 사용공간에 관한 정보
    .DBA_FREE_SPACE_COALESCED : 테이블스페이스가 수용할 수 있는 extent의 정보 (COALESCED : 수집된)
*/


--[Tablespace의 종류]
--첫 째, contents로 구분하면 3가지 유형
select tablespace_name, contents
from dba_tablespaceS;--모든 테이블스페이스의 저장 정보 및 상태 정보
--1. Permanent Tablespace
--2. Undo Tablespace
--3. Temporary Tablespace 로 구성.

--둘 째, 크게 2가지 유형으로 구분하면
--즉, 오라클 DB는 크게 2가지 유형의 Tablespace로 구성
--1. 'SYSTEM' 테이블스페이스(필수, 기본) : 
--    DB설치시 자동으로 생성되는 테이블스페이스로,
--    별도로 테이블스페이스를 지정하지 않고 테이블, 트리거, 프로시저 등을 생성했다면
--    이 'SYSTEM' 테이블스페이스에 저장됨
--    (예) 모든 Data Dictionary 정보, 프로시저, 트리거, 패키지,
--    System Rollback segment 등을 저장함
--    
--    사용자 데이터도 저장 가능하나 관리 효율성 면에서 포함시키면 안됨.
--    (예)오라클 설치하면 기본으로 저장되어 있는 emp나 dept테이블(이 테이블들은 사용자들이 사용가능함) 
--    
--    
--    ※ rollback segment란? rollback시 commit하기 전 상태로 돌리는데 그 돌리기 위한 상태를 저장하고 있는 세그먼트
          
--    DB운영에 필요한 기본 정보를 담고 있는 Data Dictionary Table이 저장되는 공간으로
--    DB에서 가장 중요한 Tablespace
--    중요한 데이터가 담겨져 있는 만큼 문제가 생길 경우 자동으로 데이터베이스를 종료될 수 있으므로
--    일반 사용자들의 객체들을 저장하지 않는 것을 권장함.
--    (혹여나 사용자들의 객체에 문제가 생겨 데이터베이스가 종료되거나 
--     완벽한 복구가 불가능한 상황이 발생할 수 있기 때문에...)

--2. 'NON-SYSTEM' 테이블스페이스 : 사용자에게 할당되는 공간
--   보다 융통성있게 DB를 관리할 수 있다.
--   (예)rollback segment, 
--   Temporary Segment,
--   Application Data Segment,
--   Index Segment,
--   User Data Segment 포함

--   ※ Temporary세그먼트란?
--     :order by를 해서 데이터를 가져오기 위해선 임시로 정렬할 데이터를 가지고 있을 공간이 필요하고
--     그 곳에서 정렬한 뒤 데이터를 가져오는데 이 공간을 가리킨다.


select *--default_tablespace
from user_userS;

select username, default_tablespace --SYSTEM, SYSTEM
from user_userS;

--1. <테이블스페이스 생성>-----------------------------------------------------------
create tablespace [테이블스페이스명]
datafile '파일경로'
size --초기 데이터 파일 크기 설정 (M:메가)
AUTOextend ON next 1M -- size로 설정한 초기 크기 공간을 모두 사용한 경우 자동으로 파일의 크기를 늘려주는 기능)
						-- K(킬로바이트), M(메가바이트) 두 단위만 사용할 수 있다.
						--1024K = 1M
MAXSIZE 250M -- 데이터파일이 최대로 커질 수 있는 크기 지정(기본값:unlimited 무제한)
uniform size 1M; -- extent  1개의 크기를 1M로 지정한것

--(1) tablespace 생성
create tablespace test_data                   
datafile 'C:\oraclexe\app\oracle\oradata\XE\test\test_data01.dbf'
size 10M
default storage(initial 2M -- 최초 extent 크기
			next 1M -- 2M가 꽉 차면 1M 크기의 extent 생성(extent는 반드시 메모리에 연속된 공간을 잡아야한다.)
			minextents 1 --(※d아니고 t임) 생성할 extent 최소개수(최소1부터)
			maxextents 121 -- 생성할 extent의 최대 개수(최대 121회 발생가능, 122회 불가능(오류))
			pctincrease 50); -- 기본값 50, 다음에 할당할 extent의 수치를 %로 나타냄
-- pctincrease 50% 지정하면 처음은 1M = 1024K, 두번째부터는 1M의 반인 512K, 그 다음은 또 그 반인 256K, 그 다음 또 그 반인...
-- default storage 생략하면 그 안의 값들은 모두 '기본값으로 지정된 값'으로 실행됨

--(2) tablespace 조회
select tablespace_name, status, segment_space_management -- *로 가져옴
from dba_tablespaceS; -- 모든 테이블스페이스의 저장정보 및 상태정보를 가지고 있는 사전(Dictionary) 

--2.<tablespace 변경>-------------------------------------------------------------------------
--위에서 만든 test_data 테이블스페이스에 datafile을 1개 더 추가
alter tablespace test_data
add datafile 'C:\oraclexe\app\oracle\oradata\XE\test\test_data02.dbf'
size 10M;
-- 아까만든 10M+지금만든 10M = test폴더의 크기가 총 20M가 된다
-- 즉, 물리적으로 2개의 데이터 파일로 구성되어진 하나의 테이블스페이스가 만들어진다.

--3.<tablespace의 datefile의 크기 조절>-------------------------------------------------------------------------
--3-1.자동으로 크기 조절
alter tablespace test_data
add datafile 'C:\oraclexe\app\oracle\oradata\XE\test\test_data03.dbf'
size 10M
AUTOextend ON next 1M --1024K(K,M만 사용가능)
MAXSIZE 250M;
--test_data03.dbf의 크기인 10M를 초과하면 1M씩 늘어나 최대 250M까지 늘어날 수 있다.
--※주의 : MAXSIZE 250M -> 기본값인 unlimited(무제한)으로 변경하면 문제 발생 할 가능성이 있음
-- 		(예)리눅스에서는 파일 1개를 핸드링할 수 있는 사이즈가 2G로 한정되어 있으므로
--			따라서, datafile이 2G를 넘으면 그때부터 오류가 발생한다.
--			가급적이면 MAXSIZE를 지정하여 사용하는 것이 바람직 하다.


--3-2.수동으로 크기 조절(★★주의 : ALTER database)
-- 기존 test_data02.dbf 파일의 크기 변경
ALTER database
datafile 'C:\oraclexe\app\oracle\oradata\XE\test\test_data02.dbf'
REsize 20M; -- 10M였던 파일의 크기를 20M로 변경
-- 하나의 테이블스페이스(test_data)=총 40M인 3개의 물리적 datafile로 구성됨

--4.<datafile의 용량 조회>
--file_name : datafile의 위치경로
select file_name, tablespace_name, bytes/1024/1024MB, autoextensible as "auto" --*
from dba_data_fileS; --테이블스페이스의 파일정보


--5. <테이블스페이스의 단편화된 공간수집 : 즉, 디스크 조각모음>
alter tablespace '테이블스페이스명' coalesce; --coalesce(수집된)
alter tablespace 'test_data' coalesce;
--dba_free_coalesced를 조회해보고 필요에 따라 여러 번 실행해야 한다.

--6.<테이블스페이스 제거하기>------------------------------------------------------------------
--형식
drop tablespace 테이블스페이스명; -- 이 때, 테이블스페이스 내에 객체가 존재하면 삭제안됨(테이블,시퀀스,인덱스 등)
[including contents];				--<옵션1>해결법 : 모든 내용(객체) 포함하여 삭제
									--그러나, 탐색기에서 확인해보면 물리적 datafile은 삭제안됨
[INCLUDING CONTENTS and datafileS];	--<옵션2> 해결법 : 물리적 datafile까지 함께 삭제
[CASCADE constraintS];				--<옵션3> 해결법 : 제약조건까지 함께 삭제



---먼저, 테스트용 테이블 생성(test_data테이블스페이스에)
-- drop table test3;
create table test3(
a char(1)
)tablespace test_data; --테이블 스페이스 지정안하면 SYSTEM테이블스페이스에 크기확장 기본값인 UNLIMITED로 만들어짐

drop tablespace test_data;
--ORA-01549: tablespace not empty, use INCLUDING CONTENTS option

--<옵션1>
drop tablespace test_data
INCLUDING CONTENTS; -- 테이블스페이스의 모든 내용(객체) 함께 삭제
--성공. 탐색기에서 확인해보면 물리적 datafile은 삭제 안되고 남아있음
--따라서 직접 삭제해줘야함

--해결법<옵션2>
drop tablespace test_data
INCLUDING CONTENTS and datafileS; -- 물리적 datafile까지 함께 삭제

--해결법<옵션3>
--그런데, 'A라는 테이블스페이스의 사원테이블(dno:FK)' 'B테이블스페이스의 부서테이블(dno:PK or UNIQUE)'를 참조하는 상황에서
--B테이블스페이스(부모테이블)를 위 방법(옵션2)로 삭제한다면 참조무결성 제약조건에 위배되므로 오류발생
drop tablespace B
INCLUDING CONTENTS and datafileS
CASCADE constraintS; -- 제약조건까지 삭제하여 해결가능함

--교재 308p--------------------------------------------------------------
--1. 사용권한
--오라클 보안 정책 : 2가지(시스템 보안->시스템 권한, 데이터 보안->객체 권한)
--[1] 시스템 보안 : DB에 접근 권한을 설정. 사용자 계정과 암호 입력해서 인증받아야 함 
--[2] 데이터 보안 : 사용자가 생성한 객체에 대한 소유권을 가지고 있기 때문에
--              데이터를 조회하거나 조작할 수 있지만
--              다른 사용자는 객체의 소유자로부터 접근 권한을 받아야 사용가능

--권한 : 시스템을 관리하는 '시스템 권한', 객체를 사용할 수 있도록 관리하는 '객체 권한'

--308p 표-시스템 권한 :'DBA 권한을 가진 사용자'가 시스템 권한을 부여함
--1. create session : DB 접속(=연결)할 수 있는 권한

--2. create table   : 테이블 생성할 수 있는 권한
--3. unlimited tablespace : 테이블스페이스에 블록을 할당할 수 있도록 해주는 권한
--그러나 unlimited tablespace하면 문제 발생할 수 있다.(default tablespace인 'SYSTEM'의  중요데이터 보안상)
--그래서 default tablespace를 다른 테이블스페이스(USERS)로 변경하고
--quota절로 사용할 용량을 할당해준다.(이 때, unlimited로 할당해줘도 무방하다.)
/** 디폴트 테이블 스페이스 변경하는 방법?-찾아보기*/
--4. create sequence : 시퀀스 생성 권한
--5. create view     : 뷰 생성 권한
--6. select any table: 권한을 받은 자가 어느 테이블, 뷰라도 검색 가능
--이 외에도 100여 개 이상의 시스템 권한이 있다.
--DBA는 사용자를 생성할 때마다 적절한 시스템 권한을 부여해야 한다.

--<시스템 권한>-------------------------------------------
--소유한 객체의 사용권한 관리를 위한 명령어 : DCL(GRANT, REVOKE)
/*
 * 시스템 권한 부여 : 반드시 'DBA 권한' 가진 사용자만 권한 부여할 수 있다.
 * GRANT '시스템권한|role' TO 사용자|롤(role)|public(=모든 사용자) [with ADMIN option]
 */

--'DBA 권한'을 가진 SYSTEM으로 접속하여 사용자의 이름과 암호 지정하여 사용자 생성
-- 아래는 Run SQL Command Line에서 실행
SQL> conn system/1234;
Connected.
SQL> create user user01 identified by 1234;

User created.

SQL> conn user01/1324;
ERROR:
ORA-01017: invalid username/password; logon denied


Warning: You are no longer connected to ORACLE.

SQL> conn system/1234;
Connected.
SQL> grant create session, create table  to user01;

Grant succeeded.

SQL> conn user01/1234;
Connected.
SQL> create table sampletbl(no number);
create table sampletbl(no number)
*
ERROR at line 1:
ORA-01950: no privileges on tablespace 'SYSTEM'
--실행불가 : SYSTEM테이블스페이스의 영역을 할당받지 못해서

SQL> conn system/1234;
Connected.
SQL> grant unlimited tablespace to user01;

Grant succeeded.
--SYSTEM테이블스페이스의 영역을 무제한 사용
-- 그러나 권한 부여하면 문제발생할 수 있다.(SYSTEM테이블스페이스의 중요한 데이터 보안상)



-- 여기까지


SELECT username, default_tablespace --  USER01   SYSTEM
from dba_userS
WHERE username IN ('USER01');

SELECT username, tablespace_name, MAX_BYTES
from dba_ts_quotaS
WHERE username IN ('USER01');
--결과 없음 : user01에게 quota가 설정 안됨
--그래서 'default_tablespace를 test_data(또는 userS)로 변경' 후 'quota를 설정'

alter user user01
default tablespace users -- 사용자 데이터가 들어갈 테이블스페이스
quota 5M ON users;

SELECT username, tablespace_name, MAX_BYTES -- USER01   USERS   5242880=5(MAX_BYTES/1024/1024MB)
from dba_ts_quotaS
WHERE username IN ('USER01');

alter user user01
default tablespace test_data -- 위에서 직접 생성한 테이블스페이스
quota 2M ON users;

SELECT username, tablespace_name, MAX_BYTES/1024/1024MB -- USER01   USERS   2
from dba_ts_quotaS
WHERE username IN ('USER01');


alter user user01
default tablespace users -- 사용자 데이터가 들어갈 테이블스페이스
quota unlimited ON users;

alter user user01
default tablespace test_data -- 위에서 직접 생성한 테이블스페이스
quota unlimited ON users;


SELECT username, tablespace_name, MAX_BYTES -- USER01   USERS   -1(UNLIMITED : 무제한)
from dba_ts_quotaS
WHERE username IN ('USER01');
----------------------------------------------------------------------------------------

--<안전한 user 생성 방법>



