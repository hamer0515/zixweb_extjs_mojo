-- ----------------------------
-- Table structure for tbl_role_inf
-- ----------------------------
drop table tbl_role_inf;
drop sequence seq_role_id;

create table tbl_role_inf (
  role_id integer primary key not null,
  role_name varchar(100) not null,
  role_type varchar(100) default null,
  eff_date char(8) default null,
  exp_date char(8) default null,
  oper_staff integer not null,
  oper_date char(8) not null,
  status integer not null,
  remark varchar(200) default null
) in tbs_dat index in tbs_idx;

create sequence seq_role_id as integer start with 1 increment by 1 no cache order; 

-- ----------------------------
-- Records of tbl_role_inf
-- ----------------------------
insert into tbl_role_inf(role_id, role_name, role_type, eff_date, exp_date, oper_staff, oper_date, status, remark)
    values (nextval for seq_role_id, '超级管理员', '超级管理员角色', '20110311', '20610311', 1, '20121031', 1, '超级管理员');
