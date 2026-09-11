CREATE TABLE `user_jobseek_sms_record` (
  `id` varchar(50) NOT NULL COMMENT '主键ID',
  `jobseek_id` varchar(50) NOT NULL COMMENT '应聘数据ID',
  `user_name` varchar(100) NOT NULL COMMENT '用户姓名',
  `phone_number` varchar(20) NOT NULL COMMENT '手机号',
  `period` varchar(10) NOT NULL COMMENT '阶段:1=专业笔试提醒,2=能力测评提醒',
  `send_count` int(11) NOT NULL DEFAULT '1' COMMENT '已发送次数',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_jobseek_period` (`jobseek_id`,`period`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户应聘短信发送记录表';
