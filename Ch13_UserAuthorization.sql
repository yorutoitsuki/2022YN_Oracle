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

create table sampletbl(no number); --테이블 생성 실패
--default tablespace는 'system' 이지만 영역을 할당받지 못했음
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
--1. 실패해결방법-1
SQL> conn system/1234
SQL> grant unlimited tablespace to user01;--권한 부여
--default tablespace인 'SYSTEM'영역을 무제한 사용
--그러나 권한 부여하면 문제 발생할 수 있다.
--('SYSTEM' 테이블스페이스의 중요한 데이터 보안 상)

--'user01'의 default_tablespace 확인
select username, default_tablespace
from dba_userS
where lower(username) IN ('user01');--default_tablespace : SYSTEM

select username, tablespace_name, max_bytes
from dba_ts_quotas--quota가 설정된 user만 표시
where username in ('USER01');
--결과가 없음:user01은 quota가 설정안됨
--그래서 'default_tablespace를 test_data(또는 users)로 변경' 후 'quota를 설정'

--2. ★★실패 해결방법-2 : SYSTEM 테이블스페이스의 중요한 데이터의 보안상 문제 발생할 수 있으므로 default_tablespace를 변경함
alter user user01
default tablespace users--users : 사용자 데이터가 들어갈 테이블스페이스
quota 5M ON users;

alter user user01
default tablespace test_data--위에서 직접 만든 테이블스페이스
quota 2M ON test_data; 

select username, tablespace_name, max_bytes
from dba_ts_quotaS--quota가 설정된 user만 표시
where username IN ('USER01');

alter user user01
default tablespace users--users : 사용자 데이터가 들어갈 테이블스페이스
quota unlimited ON users;--unlimited : 용량을 제한하지 않고 사용할 수 있다.(-1로 표시됨)

alter user user01
default tablespace test_data--위에서 직접 만든 테이블스페이스
quota unlimited ON test_data;

select username, tablespace_name, max_bytes
from dba_ts_quotaS--quota가 설정된 user만 표시
where username IN ('USER01'); 



----------------------------------------------------------------------------------------

--<안전한 user 생성 방법>
--보통 user를 생성하고
--grant connect, resource to 사용자명;
--를 습관적으로 권한을 주는데
--resource 롤을 주면 'unlimited tablespace'까지 주기에
--'SYSTEM' 테이블스페이스를 무제한으로 사용가능하게 되어
--'보안' 혹은 관리상에 문제가 될 소지를 가지고 있다.

--[1] user 생성
create user user02 identified by 1234;

--[2] 권한 부여
GRANT connect, resource to user02;

--[3] 'unlimited tablespace' 권한회수 : 반드시 권한을 준 DBA가 권한 회수를 할 수 있다
REVOKE unlimited tablespace from user02;

--[4] user02의 default tablespace를 변경하고 quota절로 영역 할당해줌
ALTER USER user02
default tablespace users --users : 사용자 데이터가 들어갈 테이블스페이스
quota 10M on users; --quota unlimited on users;

--[with admin option]-----------------------------------
/*
 * [with admin option]
 * 1. 권한을 받은자(=grantee)가 '시스템권한'을 '다른사용자'에게 부여 할 수 있도록 해준다.
 * 2. with ADMIN option으로 주어진 권한은 계층적이지 않다.(평등하다.)
 * 	  즉, b_user가 a_user의 권한을 revoke 할 수 있다.
 * 3. revoke 시에는 with ADMIN option 옵션을 명시할 필요가 없다.
 * 4. ** with ADMIN option으로 grant한 권한은 revoke 시 cascade 되지 않는다.
 * 	  즉, 부여자의 권한이 회수될때 권한을 받은자의 권한이 같이 회수되지 않는다.
 */

SQL> conn system/1234
SQL> create user a_user identified by 1234;
SQL> grant create session to a_user with ADMIN option;

--b_user 생성
SQL> create user b_user identified by 1234;

--a_user로 접속하여 b_user에게 DB접속 권한(with ADMIN option) 부여

SQL> conn a_user/1234
SQL> grant create session to b_user with admin option;

--b_user로 접속하여 a_user의 DB접속 권한 회수
SQL> conn b_user/1234
SQL> revoke create session from a_user;

--a_user로 wjqthrgkfuaus
SQL> conn a_user/1234 --실패

--<시스템 권한 회수>
--revoke '' from 사용자|롤(role)|public(=모든사용자)

-------------------------------------------------------------------
--2.롤(role) 321p : 다양한 권한을 효과적으로 관리할 수 있도록 관련된 권한까지 묶어 놓은것
--여러 사용자에게 보다 간편하게 권한을 부여할 수 있도록 함
--grant connect, resource, dba to system;
--*DBA 롤 : 시스템 자원을 무제한적으로 사용, 시스템 관리에 필요한 모든 권한
--*connect 롤 : Oracle 9i까지 - 8가지 권한,
--Oracle 10g 부터는 'create session'만 가지고 있다.
--*resource 롤 : 객체(테이블, 뷰 등)를 생성할 수 있도록 하기 위해서 '시스템 권한'을 그룹화 시킨것

---------------------------------------------------------------------

--[객체 권한]
--소유한 '객체'의 사용권한 관리를 위한 명령어 : DCL(grant,revoke)
--1.1 객체 권한 부여(교재 312P 표 참조) : DB관리자나 객체소유자가 다른 사용자에게 권한을 부여할 수 있다.

--grant to 'select|inser|update|delte.....on 객체' to 사용자|role|public [with grant option]
--(ex) grant all on 객체 to 사용자;

--1. select on 테이블명
SQL> conn system/1234
SQL> create user user01 identified by 1234;
SQL> grant create session to user01;

SQL> conn user01/1234 --접속 성공
SQL> select * from employees; --실패 : user01은 employees 테이블이 없어서 오류
SQL> select * from hr.employees;--실패 : user01은 hr이 소유한 employees 테이블에 대한 조회 권한이 없어서

SQL> conn hr/1234; --접속해보니 lock되어 있으면

SQL> conn system/1234;
SQL> alter user hr account unlock; --잠김 해제
SQL> alter user hr identified by 1234; --비밀번호도 다시 1234로 변경

SQL> conn hr/1234;
--user01에게 employees 테이블 조회 권한 부여
SQL> grant select on employees to user01;

SQL> conn user01/1234
SQL> select * from hr.employees; --조회 성공

--2. insert on 테이블명
SQL> conn hr/1234;
--user01 에게 'employees 테이블 삽입 권한' 부여
SQL> grant insert on employees to user01;

SQL> conn user01/1234;
SQL> desc hr.employees;
SQL> insert into hr.employees(EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID)
				values(8010,'길동','혼','a@naver.com','2022-09-22','AC_ACCOUNT');
				
--3. update(특정컬럼) on 테이블명
SQL> conn hr/1234; --접속
--uesr01에게 'employee 테이블의 특정 컬럼 수정 권한' 부여
SQL> grant update(salary) on employees to user01;

SQL> coon user01/1234
SQL> update hr.employees set salary = 1000 where EMPLOYEE_ID = 8010; --성공
SQL> update hr.employees set commission_pct = 500 where  where EMPLOYEE_ID = 8010; --실패, 컬럼 수정 권한이 없음

--1.2 객체 권한 회수 = 제거 : DB 관리자나 권한을 부여한 사용자가 다른 사용자에게 부여한 객체 권한을 박탈
--revoke 객체 권한 from 사용자
--* to public으로 권한을 부여하면 회수할 떄도 from public으로 해야 한다.

--1.revoke select on 객체
SQL> conn hr/1234; --권한을 부여한 사용자로 접속
SQL> revoke select on employees from user01;

SQL> conn user01/1234;
SQL> select * from hr.employees;
SQL> update hr.employees set salary = 2000 where employee_ID = 8010;

--2. revoke ALL on 객체 : 객체에 대한 모든 권한 회수
SQL> conn hr/1234; --권한을 부여한 사용자로 접속
SQL> revoke ALL on employees from user01;
SQL> revoke ALL on employees from public --모든 사용자의 employees 대한 모든 권한 회수

SQL> conn user01/1234
SQL> update hr.employees set salary = 3000 where employee_id = 8010;
--실패 메세지 : 내부적으로 select 먼저 실행되고 그 다음 update가 실행됨
--select 권한이 없으므로 절차적으로 실행이 불가능함


--[with admin option]-----------------------------------
/*
 * [with admin option]
 * 1. 권한을 받은자(=grantee)가 '객체권한'을 '다른 사용자'에게 부여 할 수 있도록 해준다.
 * 2. with ADMIN option으로 주어진 권한은 계층적이다(=평등하지 않다)
 * 	  즉, b_user가 a_user의 권한을 revoke 할 수 있다.
 * 3. revoke 시에는 with ADMIN option 옵션을 명시할 필요가 없다.
 * 4. ** with ADMIN option으로 grant한 권한은 revoke 시 cascade 된다.
 * 	  즉, 부여자의 권한이 회수될때 권한을 받은자의 권한이 같이 회수된다.
 * 
 * * with grant option 옵션은 role에 권한을 부여할 때는 사용할 수 없다.
 */

SQL> conn system/1234;
SQL> create user usertest01 identified by 1234;
SQL> create user usertest02 identified by 1234;

--위에서 생성한 사용자들에게 DB접속권한, 테이블생성권한, 뷰생성권한 부여
SQL> grant create session, create table, create view to usertest01;
SQL> grant create session, create table, create view to usertest02;

SQL> conn hr/1234 --hr(객체 소유자)접속, conn system/1234 (DB관리자)
--usertest01에게 employees 테이블 조회권한 부여 + with GRANT option 옵션
--usertest01은 소유자 hr로부터 다른 사용자에게 해당 권한(=employees 테이블 조회권한)을 부여할 수 있는 권한 부여받음
SQL> grant select on employees to usertest01 with grant option;

SQL> conn usertest01/1234
SQL> grant select on hr.employees to usertest02;

SQL> conn usertest02/1234
SQL> select * from hr.employees;

--권한 회수 : 객체의 소유자 계정
SQL> conn hr/1234
SQL> revoke select on employees from usertest01; --권한회수하면 cascade로 권환 회수됨

SQL> conn usertest02/1234
SQL> select * from hr.employees;--실패
----------------------------------------------------------------------------
----1.4 public : 모든 사용자에게 해당 권한 부여
--권한 부여 : 객체의 소유자 계정
SQL> conn hr/1234
SQL> grant select on employees to public;

SQL> conn usertest02/1234
SQL> select * from hr.employees;
















