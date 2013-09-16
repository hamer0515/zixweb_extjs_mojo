-- ----------------------------
-- Table structure for tbl_user_inf
-- ----------------------------
drop table tbl_user_inf;
drop sequence seq_user_id;

create table tbl_user_inf (
  user_id integer primary key not null,
  username varchar(100) default null,
  user_pwd varchar(255) not null,
  #pwd_chg_date char(8) default null,
  pwd_chg_date date default null,
  eff_date char(8) default null,
  exp_date char(8) default null,
  oper_staff integer default null,
  #oper_date char(8) default null,
  oper_date date default null,
  status integer not null
) in tbs_dat index in tbs_idx;

create sequence seq_user_id as integer start with 1 increment by 1 no cache order; 
-- ----------------------------
-- Records of tbl_user_inf
-- ----------------------------
insert into tbl_user_inf(user_id, username, user_pwd, pwd_chg_date, eff_date, exp_date, oper_staff, oper_date, status) 
    values(nextval for seq_user_id, 'admin', '0192023a7bbd73250516f069df18b500', '2012-11-01', '20121101', '20500101',0 , '2012-11-01', 1 );
