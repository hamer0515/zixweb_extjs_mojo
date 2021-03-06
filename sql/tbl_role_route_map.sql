-- ----------------------------
-- Table structure for tbl_role_route_map
-- ----------------------------
drop table tbl_role_route_map;

create table tbl_role_route_map (
  role_id integer not null,
  route_id integer not null,
  primary key (role_id, route_id)
) in tbs_dat index in tbs_idx;

-- ----------------------------
-- Records of tbl_role_route_map
-- ----------------------------
insert into tbl_role_route_map(role_id, route_id) values
(1, 1),
(1, 2),
(1, 3), 
(1, 4), 
(1, 5), 
(1, 6), 
(1, 7), 
(1, 8), 
(1, 20),  
(1, 21),  
(1, 22),  
(1, 23),  
(1, 24),  
(1, 30),  
(1, 31), 
(1, 32),  
(1, 33),  
(1, 34),  
(1, 35),  
(1, 36),  
(1, 37),  
(1, 38),  
(1, 39),  
(1, 40),  
(1, 50),  
(1, 51), 
(1, 52),  
(1, 53),  
(1, 60),    
(1, 61),  
(1, 62),  
(1, 63),  
(1, 64), 
(1, 65),  
(1, 66),  
(1, 67),  
(1, 68),  
(1, 69),  
(1, 70),  
(1, 71),  
(1, 90),  
(1, 91),  
(1, 92),  
(1, 93),  
(1, 94),  
(1, 95),  
(1, 96), 
(1, 97), 
(1, 98), 
(1, 99), 
(1, 100), 
(1, 101), 
(1, 102), 
(1, 103), 
(1, 104), 
(1, 105), 
(1, 106), 
(1, 107), 
(1, 108), 
(1, 109), 
(1, 110), 
(1, 111), 
(1, 112), 
(1, 113), 
(1, 114), 
(1, 115), 
(1, 116), 
(1, 117), 
(1, 118), 
(1, 119), 
(1, 120), 
(1, 121),
(1, 122), 
(1, 123), 
(1, 124), 
(1, 125), 
(1, 126), 
(1, 127), 
(1, 128), 
(1, 129), 
(1, 130), 
(1, 131), 
(1, 132), 
(1, 133), 
(1, 134), 
(1, 135), 
(1, 136), 
(1, 137), 
(1, 138), 
(1, 139), 
(1, 140), 
(1, 141), 
(1, 142), 
(1, 143), 
(1, 144), 
(1, 145), 
(1, 146), 
(1, 147), 
(1, 148), 
(1, 149), 
(1, 150), 
(1, 151), 
(1, 152), 
(1, 153), 
(1, 154), 
(1, 155), 
(1, 156), 
(1, 157), 
(1, 158), 
(1, 159), 
(1, 160), 
(1, 161), 
(1, 162), 
(1, 163), 
(1, 164), 
(1, 165), 
(1, 166), 
(1, 167), 
(1, 168), 
(1, 169), 
(1, 170), 
(1, 171), 
(1, 172), 
(1, 173), 
(1, 174), 
(1, 175), 
(1, 176), 
(1, 177), 
(1, 178), 
(1, 179), 
(1, 180), 
(1, 181), 
(1, 182), 
(1, 183), 
(1, 184), 
(1, 185), 
(1, 186), 
(1, 187), 
(1, 188),
(1, 189),
(1, 190), 
(1, 191), 
(1, 192),
(1, 193), 
(1, 194), 
(1, 195), 
(1, 196), 
(1, 197), 
(1, 198), 
(1, 199), 
(1, 200), 
(1, 201), 
(1, 202), 
(1, 203), 
(1, 204), 
(1, 205), 
(1, 206), 
(1, 207),
(1, 208),
(1, 209),
(1, 210),
(1, 211),
(1, 212),
(1, 213),
(1, 214),
(1, 215),
(1, 216),
(1, 217),
(1, 218),
(1, 219),
(1, 300),
(1, 301),
(1, 302),
--(1, 500),
(1, 600),
(1, 601),
(1, 602),
(1, 603),
(1, 604),
(1, 605),
(1, 606),
(1, 607),
(1, 608),
(1, 609),
(1, 610),
(1, 611),
(1, 612),
(1, 613),
(1, 614),
(1, 615),
(1, 616),
(1, 617),
(1, 618),
(1, 619),
(1, 620),
(1, 621),
(1, 622),
(1, 623),
(1, 624),
(1, 625),
(1, 626),
(1, 627),
(1, 628),
(1, 629),
(1, 630),
(1, 631),
(1, 632),
(1, 633),
(1, 634),
(1, 635),
(1, 636),
(1, 637),
(1, 638),
(1, 639),
(1, 640),
(1, 641),
(1, 642),
(1, 643),
(1, 644),
(1, 645),
(1, 646),
(1, 647),
(1, 648),
(1, 649),
(1, 650),
(1, 651),
(1, 652),
(1, 653),
(1, 654),
(1, 655),
(1, 656),
(1, 657),
(1, 658),
(1, 659),
(1, 660),
(1, 661),
(1, 662),
(1, 663),
(1, 664),
(1, 665),
(1, 666),
(1, 667),
(1, 668),
(1, 669),
(1, 670),
(1, 671),
(1, 672),
(1, 673),
(1, 674),
(1, 675),
(1, 676),
(1, 677);
