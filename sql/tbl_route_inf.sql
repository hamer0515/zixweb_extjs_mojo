-- ----------------------------
-- Table structure for tbl_route_inf
-- ----------------------------
drop table tbl_route_inf;

create table tbl_route_inf (
  route_id integer primary key not null,
  parent_id integer default null,
  route_name varchar(100) not null,
  route_value varchar(500) default null,
  route_regex varchar(500) default null,
  view_order integer default null,
  oper_staff integer not null,
  oper_date char(8) not null,
  status integer not null,
  memo varchar(255) default null
) in tbs_dat index in tbs_idx;

-- ----------------------------
-- Records of tbl_route_inf
-- ----------------------------

insert into tbl_route_inf(route_id, parent_id, route_name, route_value, route_regex, view_order, oper_staff, oper_date, status, memo) 

values
    (1, 0, '系统管理' , '', '',  1, 0, '20121101', 1, '系统菜单'),
    (2, 1, '重新登录' , 'logout', '^/login/logout$', 1, 0, '20121101', 1, '重新登录菜单项'),
    (3, 1, '密码设置' ,'passwordreset' ,'^/login/passwordreset/$' , 2, 0, '20121101', 1, '密码设置菜单项'),
    (4, 1, '用户管理' , 'userlist', '^/user/.*$', 3, 0, '20121101', 1, '用户管理菜单项'),
    (5, 1, '角色管理' , 'rolelist', '^/role/.*$', 4, 0, '20121101', 1, '角色管理菜单项'),
    
    (20, 0, '账簿管理' , '', '', 2, 0, '20121101', 1, '管理菜单'),
    (21, 20, '科目余额表-总帐套' , 'bookall', '^/book$|^/book/.*$|^/hist/.*$', 1, 0, '20121101', 1, '科目余额表菜单项'),
    (22, 20, '科目余额表-备付金帐套' , 'bookbfj', '^/book$|^/book/.*$|^/hist/.*$', 1, 0, '20121101', 1, '科目余额表菜单项'),
    (23, 20, '科目余额表-自有资金帐套' , 'bookzyzj', '^/book$|^/book/.*$|^/hist/.*$', 1, 0, '20121101', 1, '科目余额表菜单项'),
    
    (30, 0, '凭证录入' , '', '', 1, 0, '20121101', 1, '凭证录入菜单项'),
    (31, 30, '0000特种调账单' , 'i0000', '^/i0000/.*$', 1, 0, '20121101', 1, '0000特种调账单录入菜单项'),
    (32, 30, '0001备付金内扣成本补充原始凭证录入' , 'i0001', '^/yspzgl/(i0001|add)$', 2, 0, '20121101', 1, '0001原始凭证录入菜单项'),
    (33, 30, '0006委托收款勾兑不成功（银有我无，补付客户备付金）原始凭证录入' , '/yspzgl/i0006', '^/yspzgl/(i0006|add)$', 3, 0, '20121101', 1, '0006原始凭证录入菜单项'),
    (34, 30, '0008赎回款汇入成功原始凭证录入' , '/yspzgl/i0008', '^/yspzgl/(i0008|add)$', 4, 0, '20121101', 1, '0008原始凭证录入菜单项'),
    (35, 30, '0009赎回款汇出成功原始凭证录入' , '/yspzgl/i0009', '^/yspzgl/(i0009|add)$', 5, 0, '20121101', 1, '0009原始凭证录入菜单项'),
    (36, 30, '0013账户管理费原始凭证录入' , '/yspzgl/i0013', '^/yspzgl/(i0013|add)$', 6, 0, '20121101', 1, '0013原始凭证录入菜单项'),
    (37, 30, '0014账户利息收入原始凭证录入' , '/yspzgl/i0014', '^/yspzgl/(i0014|add)$', 7, 0, '20121101', 1, '0014原始凭证录入菜单项'),
    (38, 30, '0015备付金账户间资金划拨原始凭证录入' , '/yspzgl/i0015', '^/yspzgl/(i0015|add)$', 8, 0, '20121101', 1, '0015原始凭证录入菜单项'),
    (39, 30, '0018客户备付金汇入' , '/yspzgl/i0018', '^/yspzgl/(i0018|add)$', 8, 0, '20121101', 1, '0018客户备付金汇入菜单项'),
    (40, 30, '凭证导入' , 'pzlrmission', '^/pzlr/(mission|job|action)$', 8, 0, '20121101', 1, '凭证导入'),
    
    (50, 0, '资金对账管理' , '', '', 1, 0, '20121101', 1, '资金对账管理菜单项'),
    (51, 50,'备付金银行账户资金对账' , 'zjdzbfj', '^/reconciliation/.*$', 1, 0, '20121101', 1, '备付金银行账户资金对账查询菜单项'),
    (52, 50,'银行账户挂账情况查询' , 'gzcx', '^/reconciliation/.*$', 2, 0, '20121101', 1, '银行账户挂账情况查询菜单项'),
    
    (60, 0, '任务管理' , '', '', 1, 0, '20121101', 1, '任务管理菜单项'),
    (61, 60, '审核任务' , 'taskshtask', '^/cocert/.*$', 1, 0, '20121101', 1, '审核任务菜单项'),
    (62, 60, '我的任务' , 'taskmytask', '^/cocert/.*$', 1, 0, '20121101', 1, '我的任务菜单项'),
    
    (70, 0, '原始凭证管理' , '', '', 4, 0, '20121101', 1, '原始凭证管理菜单'),
    (71,70, '0000特种调账单' , '/yspzgl/y0000?tag=1', '^/yspzgl/y0000$', 1, 0, '20121101', 1, '0000种调账单菜单项'),
    (72,70, '0001备付金内扣成本补充' , '/yspzgl/y0001?tag=1', '^/yspzgl/y0001$', 2, 0, '20121101', 1, '0001备付金内扣成本补充'),
    (73,70, '0002委托收款勾兑成功' , '/yspzgl/y0002?tag=1', '^/yspzgl/y0002$', 3, 0, '20121101', 1, '0002委托收款勾兑成功'),
    (74,70, '0003委托收款勾兑不成功（我有银无）' , '/yspzgl/y0003?tag=1', '^/yspzgl/y0003$', 4, 0, '20121101', 1, '0003委托收款勾兑不成功（我有银无）'),
    (75,70, '0004委托收款勾兑不成功（银有我无）' , '/yspzgl/y0004?tag=1', '^/yspzgl/y0004$', 5, 0, '20121101', 1, '0004委托收款勾兑不成功（银有我无）'),
    (76,70, '0005委托收款勾兑不成功（我有银无，追回，处理完成）' , '/yspzgl/y0005?tag=1', '^/yspzgl/y0005$', 6, 0, '20121101', 1, '0005委托收款勾兑不成功（我有银无，追回，处理完成）'),
    (77,70, '0006委托收款勾兑不成功（银有我无，补付客户备付金）' , '/yspzgl/y0006?tag=1', '^/yspzgl/y0006$', 7, 0, '20121101', 1, '0006委托收款勾兑不成功（银有我无，补付客户备付金）'),
    (78,70, '0007委托收款结算' , '/yspzgl/y0007?tag=1', '^/yspzgl/y0007$', 8, 0, '20121101', 1, '0007委托收款结算'),
    (79,70, '0008赎回款汇入成功' , '/yspzgl/y0008?tag=1', '^/yspzgl/y0008$', 9, 0, '20121101', 1, '0008赎回款汇入成功'),
    (80,70, '0009赎回款汇出成功' , '/yspzgl/y0009?tag=1', '^/yspzgl/y0009$', 10, 0, '20121101', 1, '0009赎回款汇出成功'),
    (81,70, '0010资金对账成功' , '/yspzgl/y0010?tag=1', '^/yspzgl/y0010$', 11, 0, '20121101', 1, '0010资金对账成功'),
    (82,70, '0011资金对账银行多付（银行长款）' , '/yspzgl/y0011?tag=1', '^/yspzgl/y0011$', 12, 0, '20121101', 1, '0011资金对账银行多付（银行长款）'),
    (83,70, '0012资金对账银行少付（银行短款）' , '/yspzgl/y0012?tag=1', '^/yspzgl/y0012$', 13, 0, '20121101', 1, '0012资金对账银行少付（银行短款）'),
    (84,70, '0013账户管理费' , '/yspzgl/y0013?tag=1', '^/yspzgl/y0013$', 14, 0, '20121101', 1, '0013账户管理费'),
    (85,70, '0014账户利息收入' , '/yspzgl/y0014?tag=1', '^/yspzgl/y0014$', 15, 0, '20121101', 1, '0014账户利息收入'),
    (86,70, '0015备付金账户间资金划拨' , '/yspzgl/y0015?tag=1', '^/yspzgl/y0015$', 16, 0, '20121101', 1, '0015备付金账户间资金划拨'),
    (87,70, '0016直联POS代清算收款勾兑成功' , '/yspzgl/y0016?tag=1', '^/yspzgl/y0016$', 17, 0, '20121101', 1, '0016直联POS代清算收款勾兑成功'),
    (88,70, '0017直联POS代清算收款反向交易勾兑成功' , '/yspzgl/y0017?tag=1', '^/yspzgl/y0017$', 18, 0, '20121101', 1, '0017直联POS代清算收款反向交易勾兑成功'),
    (89,70, '0018客户备付金汇入' , '/yspzgl/y0018?tag=1', '^/yspzgl/y0018$', 19, 0, '20121101', 1, '0018客户备付金汇入'),
    (90,70, '0019出款勾兑成功' , '/yspzgl/y0019?tag=1', '^/yspzgl/y0019$', 20, 0, '20121101', 1, '0019出款勾兑成功'),
    (91,70, '0020出款勾兑不成功(我有银无)' , '/yspzgl/y0020?tag=1', '^/yspzgl/y0020$', 21, 0, '20121101', 1, '0020出款勾兑不成功(我有银无)'),
    (92,70, '0021出款勾兑不成功(银有我无)' , '/yspzgl/y0021?tag=1', '^/yspzgl/y0021$', 22, 0, '20121101', 1, '0021出款勾兑不成功(银有我无)'),
    (93,70, '0022出款勾兑不成功(我有银无，银行继续出款)' , '/yspzgl/y0022?tag=1', '^/yspzgl/y0022$', 23, 0, '20121101', 1, '0022出款勾兑不成功(我有银无，银行继续出款)'),
    (94,70, '0023出款勾兑不成功(我有银无，撤单)' , '/yspzgl/y0023?tag=1', '^/yspzgl/y0023$', 24, 0, '20121101', 1, '0023出款勾兑不成功(我有银无，撤单)'),
    (95,70, '0024出款勾兑不成功(银有我无,客户补单)' , '/yspzgl/y0024?tag=1', '^/yspzgl/y0024$', 25, 0, '20121101', 1, '0024出款勾兑不成功(银有我无,客户补单)'),   
    (96,70, '0025出款勾兑不成功（银有我无，追回）' , '/yspzgl/y0025?tag=1', '^/yspzgl/y0025$', 25, 0, '20121101', 1, '0025出款勾兑不成功（银有我无，追回）'),
    (97,70, '0026出款勾兑不成功（银有我无，确认损失）' , '/yspzgl/y0026?tag=1', '^/yspzgl/y0026$', 25, 0, '20121101', 1, '0026出款勾兑不成功（银有我无，确认损失）'),
    (98,70, '0027出款退回' , '/yspzgl/y0027?tag=1', '^/yspzgl/y0027$', 25, 0, '20121101', 1, '0027出款退回'),   
    (99,70, '0028成功出款请求' , '/yspzgl/y0028?tag=1', '^/yspzgl/y0028$', 26, 0, '20121101', 1, '0028成功出款请求'),
    (100,70, '0029勾兑成功出款' , '/yspzgl/y0029?tag=1', '^/yspzgl/y0029$', 27, 0, '20121101', 1, '0029勾兑成功出款'),
    (101,70, '0030出款退回' , '/yspzgl/y0030?tag=1', '^/yspzgl/y0030$', 28, 0, '20121101', 1, '0030出款退回'),
    (102,70, '0031周期确认' , '/yspzgl/y0031?tag=1', '^/yspzgl/y0031$', 29, 0, '20121101', 1, '0032周期确认'),
    (103,70, '0032POS收款勾兑成功' , '/yspzgl/y0032?tag=1', '^/yspzgl/y0032$', 30, 0, '20121101', 1, '0032POS收款勾兑成功'),
    (104,70, '0033POS收款勾兑不成功（我有银无）' , '/yspzgl/y0033?tag=1', '^/yspzgl/y0033$', 31, 0, '20121101', 1, '0033POS收款勾兑不成功（我有银无）'),
    (105,70, '0034POS收款勾兑不成功（我有银无，追回）' , '/yspzgl/y0034?tag=1', '^/yspzgl/y0034$', 32, 0, '20121101', 1, '0034POS收款勾兑不成功（我有银无，追回）'),
    (106,70, '0035POS收款勾兑不成功（我有银无，撤单）' , '/yspzgl/y0035?tag=1', '^/yspzgl/y0035$', 33, 0, '20121101', 1, '0035POS收款勾兑不成功（我有银无，撤单）'),
    (107,70, '0036POS收款勾兑不成功（我有银无，确认损失）' , '/yspzgl/y0036?tag=6', '^/yspzgl/y0036$', 34, 0, '20121101', 1, '0036POS收款勾兑不成功（我有银无，确认损失）'),
    (108,70, '0037POS收款原接口反向交易勾兑成功' , '/yspzgl/y0037?tag=1', '^/yspzgl/y0037$', 35, 0, '20121101', 1, '0037POS收款原接口反向交易勾兑成功'),
    (109,70, '0038POS收款原接口反向交易勾兑-我有银无' , '/yspzgl/y0038?tag=1', '^/yspzgl/y0038$', 36, 0, '20121101', 1, '0038POS收款原接口反向交易勾兑-我有银无'),
    (110,70, '0039POS收款原接口反向交易勾兑-我有银无，继续出款' , '/yspzgl/y0039?tag=1', '^/yspzgl/y0039$', 37, 0, '20121101', 1, '0039POS收款原接口反向交易勾兑-我有银无，继续出款'),
    (111,70, '0040POS收款原接口反向交易勾兑-我有银无，撤单' , '/yspzgl/y0040?tag=1', '^/yspzgl/y0040$', 38, 0, '20121101', 1, '0040POS收款原接口反向交易勾兑-我有银无，撤单'),
    (112,70, '0041POS委托打款' , '/yspzgl/y0041?tag=1', '^/yspzgl/y0041$', 39, 0, '20121101', 1, '0041POS委托打款'),
    (113,70, '0042POS打款失败' , '/yspzgl/y0042?tag=1', '^/yspzgl/y0042$', 40, 0, '20121101', 1, '0042POS打款失败'),
    (114,70, '0043POS收款线下传真反向交易' , '/yspzgl/y0043?tag=1', '^/yspzgl/y0043$', 41, 0, '20121101', 1, '0043POS收款线下传真反向交易'),
    (115,70, '0044POS收款分账' , '/yspzgl/y0044?tag=1', '^/yspzgl/y0044$', 42, 0, '20121101', 1, '0044POS收款分账'),
    (116,70, '0045POS收款勾兑不成功（银有我无）' , '/yspzgl/y0045?tag=1', '^/yspzgl/y0045$', 43, 0, '20121101', 1, '0045POS收款勾兑不成功（银有我无）'),
    (117,70, '0046POS收款勾兑不成功（银有我无，客户补单）' , '/yspzgl/y0046?tag=1', '^/yspzgl/y0046$', 44, 0, '20121101', 1, '0046POS收款勾兑不成功（银有我无，客户补单）'),
    (118,70, '0047POS收款勾兑不成功（银有我无，退回）' , '/yspzgl/y0047?tag=1', '^/yspzgl/y0047$', 45, 0, '20121101', 1, '0047POS收款勾兑不成功（银有我无，退回）'),
    (119,70, '0048POS原接口反向交易勾兑不成功（银有我无）' , '/yspzgl/y0048?tag=1', '^/yspzgl/y0048$', 46, 0, '20121101', 1, '0048POS原接口反向交易勾兑不成功（银有我无）'),
    (120,70, '0049POS原接口反向交易勾兑不成功（银有我无，客户补单）' , '/yspzgl/y0049?tag=1', '^/yspzgl/y0049$', 47, 0, '20121101', 1, '0049POS原接口反向交易勾兑不成功（银有我无，客户补单）'),
    (121,70, '0050POS原接口反向交易勾兑不成功（银有我无，追回）' , '/yspzgl/y0050?tag=1', '^/yspzgl/y0050$', 48, 0, '20121101', 1, '0050POS原接口反向交易勾兑不成功（银有我无，追回）'),
    (122,70, '0051POS原接口反向交易勾兑不成功（银有我无，确认损失）' , '/yspzgl/y0051?tag=1', '^/yspzgl/y0051$', 49, 0, '20121101', 1, '0051POS原接口反向交易勾兑不成功（银有我无，确认损失）'),
    (123,70, '0052直联POS待清算暂扣款成功' , '/yspzgl/y0052?tag=1', '^/yspzgl/y0052$', 50, 0, '20121101', 1, '0052直联POS待清算暂扣款成功'),
    (124,70, '0053直联POS待清算释放款成功' , '/yspzgl/y0053?tag=1', '^/yspzgl/y0053$', 51, 0, '20121101', 1, '0053直联POS待清算释放款成功'),
    (125,70, '0054收到垫付品牌费' , '/yspzgl/y0054?tag=1', '^/yspzgl/y0054$', 52, 0, '20121101', 1, '0054收到垫付品牌费'),
 
 
    
    (250,70, '原始凭证详细' , '/yspzgl/detail','^/yspzgl/detail$', 1, 0, '20121101', 2, '原始凭证详细操作'),
    (251,70, '原始凭证撤销操作' , '/yspzgl/revoke','^/yspzgl/revoke$', 13, 0, '20121101', 2, '原始凭证撤销操作'),
       
    (340,  0, '周期确认' , '', '', 2, 0, '20121101', 1, '周期确认'),
    (341, 340, '确认提交' , '/ack/select', '^/ack/(select|submit)$', 1, 0, '20121101', 1, '确认提交'),
    (342, 340, '状态查询' , '/ack/index', '^/ack/index*$', 2, 0, '20121101', 1, '状态查询');
