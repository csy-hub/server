# MyYule Server 项目开发规范 Skill

## 一、项目概览

### 1.1 项目定位
- **项目名称**: myyule-server（星选/校园招聘平台）
- **架构**: Spring Cloud 微服务架构（Finchley.SR2）
- **JDK**: 1.8
- **Spring Boot**: 2.0.4.RELEASE
- **注册中心/配置中心**: Nacos (Alibaba)
- **父POM**: `com.myyule.server:myyule-parent:1.0-SNAPSHOT`

### 1.2 模块结构

```
myyule-parent (pom)
├── integration/          # 公共基础库（jar，不独立部署）
│   ├── api-common        # API公共库：缓存、Feign封装、Kafka、工具类
│   ├── db-common         # 数据库公共库：多数据源、分库分表、MyBatis
│   └── log-common        # 日志公共库：logback、调用链追踪
├── service/              # 服务聚合层（BFF）
│   └── SService-fstar    # fstar聚合服务（端口8669）
├── pass/                 # 能力服务层
│   ├── SPass-dynamics    # 动态能力（招聘动态、活动、视频、音乐）
│   ├── SPass-else        # 其他能力（应用管理、表情、定时任务、抽奖、权限）
│   ├── SPass-search      # 搜索能力（ES搜索聚合）
│   └── SPass-space       # 空间/简历能力
├── public/               # 公共服务层
│   ├── SPublic-account   # 账户服务（登录、注册、用户管理，端口8456）
│   └── external          # 外部对接服务（微信、易信、推送、IM、部落，端口8558）
├── config/               # 配置中心（未激活）
├── gateway/              # 网关（未激活）
└── shell/                # 部署脚本（dev/test/pro环境Git分支管理）
```

### 1.3 各模块端口

| 模块 | 端口 | 应用名 |
|------|------|--------|
| SService-fstar | 8669 | myyule-service-fstar |
| SPublic-account | 8456 | myyule-public-account |
| external | 8558 | myyule-external |
| SPass-else | 8452 | myyule-pass-else |
| SPass-dynamics | - | myyule-pass-dynamics |
| SPass-search | - | myyule-pass-search |
| SPass-space | - | myyule-pass-space |

### 1.4 调用链路

```
客户端 → Zuul网关(未启用) → service(BFF聚合层) → pass(能力层)/public(公共服务层)
                                                      ↘ integration(公共基础库,jar包引入)
```

### 1.5 完整模块清单（含shell中出现的未检出模块）

| 模块名 | Git仓库 | 说明 |
|--------|---------|------|
| `integration/api-common` | integration子模块 | API公共库 |
| `integration/db-common` | integration子模块 | DB公共库 |
| `integration/log-common` | integration子模块 | 日志公共库 |
| `service/SService-fstar` | service子模块 | fstar聚合服务 |
| `pass/SPass-dynamics` | pass子模块 | 动态能力 |
| `pass/SPass-else` | pass子模块 | 其他能力 |
| `pass/SPass-search` | pass子模块 | 搜索能力 |
| `pass/SPass-space` | pass子模块 | 空间简历 |
| `public/SPublic-account` | public子模块 | 账户服务 |
| `public/external` | public子模块 | 外部对接 |
| `SPublic-common` | 独立子模块（未检出） | 公共通用服务 |
| `SPublic-platform` | 独立子模块（未检出） | 平台服务 |
| `calculate` | 独立子模块（未检出） | 计算服务 |
| `mylai` | 独立子模块（未检出） | mylai服务 |
| `SPass-interplay` | pass子模块（未检出） | 互动能力 |
| `SPass-relation` | pass子模块（未检出） | 关系能力 |
| `SPass-resources` | pass子模块（未检出） | 资源能力 |
| `SPass-school` | pass子模块（未检出） | 学校能力 |
| `SPass-config` | pass子模块（未检出） | pass配置 |
| `SPass-channel` | pass子模块（未检出） | 频道能力 |
| `gateway` | 独立模块（未激活） | 网关 |
| `registry` | 独立模块（未激活） | 注册中心 |
| `config` | 独立模块（未激活） | 配置中心 |
| `monitor/admin-server` | monitor子模块（未检出） | 监控管理 |
| `monitor/zipkin-center` | monitor子模块（未检出） | 链路追踪 |

---

## 二、核心调用关系（服务间Feign依赖）

### 2.1 SService-fstar -> 其他服务

| 源模块 | FeignClient name | 目标服务 | 调用方 |
|--------|------------------|---------|--------|
| sservice.account | `myyule-public-account` | SPublic-account | `AccountFeignClient`, `UserFeignClient` |
| sservice.account | `myyule-public-common` | SPublic-common | - |
| sservice.browse | `myyule-public-account` | SPublic-account | `UserFeignClient` |
| sservice.browse | `myyule-public-common` | SPublic-common | `AddressFeignClient`, `DynamicFeignClient`, `InterplayFeignClient` |
| sservice.collection | `myyule-public-account` | SPublic-account | `UserFeignClient` |
| sservice.collection | `myyule-public-common` | SPublic-common | `AddressFeignClient`, `DynamicFeignClient`, `InterplayFeignClient`, `SearchFeignClient` |
| sservice.fstar | `myyule-public-account` | SPublic-account | `PUserFeignClient`, `PSchoolFeignClient`, `PElseFeignClient` |
| sservice.fstar | `myyule-public-common` | SPublic-common | `CommonFeignClient` |
| sservice.jobseek | `myyule-public-account` | SPublic-account | `AccountFeignClient`, `SchoolFeignClient` |
| sservice.jobseek | `myyule-public-common` | SPublic-common | `AddressFeignClient`, `InterplayFeignClient`, `SearchFeignClient`, `PublicCommonFeignClient`, `JobseekFeignClient`, `RecruitFeignClient`, `ResumeFeignClient` |
| sservice.jobseek | `myyule-external` | external | `ExternalFeignClient` |
| feign (顶层) | `myyule-public-account` | SPublic-account | `AccountFeignClient` |
| feign (顶层) | `myyule-public-common` | SPublic-common | `AddressFeignClient` |

### 2.2 SPass-dynamics -> 其他服务

| FeignClient name | 目标服务 |
|------------------|---------|
| `myyule-public-account` | SPublic-account (`UserFeginClient`) |
| `myyule-public-common` | SPublic-common (`CommonFeignClient`, `AddressFeignClient`) |
| `myyule-external` | external (`ExternalFeignClient`) |

### 2.3 SPass-else -> 其他服务

| FeignClient name | 目标服务 |
|------------------|---------|
| `myyule-public-account` | SPublic-account (`AccountUserFeignClient`, `AccountFeignClient`, `LotteryAccountFeignClient`, `EmojiAccountFeignClient`) |
| `myyule-public-common` | SPublic-common (`CommonFileFeignClient`, `PublicCommonFeignClient`, `CommonFeignClient`, `AddressFeignClient`) |
| `myyule-external` | external (`ExternalFeignClient`) |
| `myyule-pass-interplay` | SPass-interplay (`InterplayFeignClient`) |

### 2.4 SPass-space -> 其他服务

| FeignClient name | 目标服务 |
|------------------|---------|
| `myyule-public-account` | SPublic-account (`AccountFeignClient`, `EnterpriseFeignClient`) |
| `myyule-pass-dynamics` | SPass-dynamics (`DynamicFeignClient`) |

### 2.5 SPass-search -> 其他服务

| FeignClient name | 目标服务 |
|------------------|---------|
| `myyule-public-account` | SPublic-account (`AccountFeignClient`, `UsersFeignClient`) |
| `myyule-public-common` | SPublic-common (`CommonFeignClient`) |

### 2.6 SPublic-account -> 其他服务

| FeignClient name | 目标服务 |
|------------------|---------|
| `myyule-external` | external (`ExternalFeignClient`) |
| `myyule-public-common` | SPublic-common (`CommonFeignClient`) |

### 2.7 external -> 其他服务

| FeignClient name | 目标服务 |
|------------------|---------|
| `myyule-public-account` | SPublic-account (`AccountFeignClient`, `PublicUserFeignClient`, `UserFeignClient`) |
| `myyule-public-common` | SPublic-common (`PublicExternalFeignClient`, `CommonFileFeignClient`) |
| `myyule-pass-dynamics` | SPass-dynamics (`DynamicsFeignClient`) |
| `myyule-msggroup` | msggroup (`MsgGroupFeignClient`) |

### 2.8 api-common 公共FeignClient

| FeignClient name | 目标服务 |
|------------------|---------|
| `myyule-public-common` | SPublic-common (`CommonFeignClient`) |
| `myyule-public-account` | SPublic-account (`UserFeignClient`) |
| `myyule-calculate` | calculate (`CalculateFeignClient`) |

---

## 三、API接口规范

### 3.1 URL命名模式

```
/{业务域}_{动作}_{资源}/v{版本号}.{子版本号}
```

**实际例子：**
- `/myyule_service_account_starAccountTable/v1.0` — 账户模块，星光账户表格
- `/myyule_service_jobseek_send/v2.0` — 求职模块，投递简历(v2)
- `/myyule_fstar_recommendList/v1.0` — fstar推荐列表
- `/myyule_service_browse_browseRecruitList/v2.0` — 浏览招聘列表
- `/myyule_service_collection_collectRecruitList/v2.0` — 收藏招聘列表

### 3.2 请求/响应模型

**通用协议格式（MSReqJson/MSResJson）：**
```json
// 请求
{
  "id": "唯一标识",
  "version": "接口版本号",
  "type": "请求类型(action)",
  "appId": "应用ID",
  "appVersion": "应用版本",
  "userId": "用户ID",
  "deviceId": "设备ID",
  "params": { /* 业务参数 */ }
}

// 响应
{
  "id": "对应请求id",
  "version": "版本号",
  "status": "0=成功, 1=失败, 2=登出, 3=无权限, 4=登录超时, 5=异地登录, -1=错误",
  "desc": "描述信息",
  "result": { /* 业务结果 */ }
}
```

### 3.3 状态码常量（MSStatusConstant）

| 值 | 含义 |
|----|------|
| `0` | SUCCESS 成功 |
| `1` | FAIL 失败 |
| `2` | OUT 登出 |
| `3` | PERMISSION_DENIED 无权限 |
| `4` | LOGIN_OUT 登录超时 |
| `5` | OTHER_LOGIN 异地登录 |
| `6` | FUTURESTAR_PERMISSION_DENIED 未来星无权限 |
| `7` | EDU_STATE 教育状态 |
| `-1` | ERROR 错误 |

### 3.4 外部接口注解（标记外部请求类型）

| 注解 | 用途 |
|------|------|
| `@MSExternalRequest` | 通用外部请求 |
| `@MSbeisenExternalRequest` | 北森测评外部请求 |
| `@MSElearnExternalRequest` | E-Learning外部请求 |
| `@MSWechatExternalRequest` | 微信外部请求 |
| `@MSyixinExternalRequest` | 易信外部请求 |

这些注解被AOP切面拦截，自动记录外部接口调用日志（`MSExternalRequestAOP`等）。

### 3.5 幂等/防重注解
- `@DuplicateRequest(param={...})` — 防止重复请求，AOP切面处理

---

## 四、各模块详细API接口清单

### 4.1 SService-fstar（BFF聚合层，~230+ endpoints）

#### 4.1.1 求职管理（sservice/jobseek）

| Controller | 端点 | 说明 |
|------------|------|------|
| JobseekAdminController | `/myyule_service_jobseek_userList/v3.0` | 用户列表 |
| | `/myyule_service_jobseek_userDetail/v1.0` | 用户详情 |
| | `/myyule_service_jobseek_userListByUserId/v2.0` | 按用户ID查询 |
| | `/myyule_service_jobseek_changePeriod/v1.0` | 变更招聘阶段 |
| | `/myyule_service_jobseek_changePeriod/v2.0` | 变更招聘阶段v2 |
| | `/myyule_service_jobseek_updatePeriod/v1.0` | 更新招聘阶段 |
| | `/myyule_service_jobseek_updatePeriod/v2.0` | 更新招聘阶段v2 |
| | `/myyule_fstar_jobseek_queryTestResult/v1.0` | 查询测试结果 |
| ExamSmsRemindController | `/myyule_service_jobseek_examSmsRemind/v1.0` | 考试短信提醒 |
| SearchController | `/myyule_service_jobseek_wxSearchRecruitList/v2.0` | 微信搜索招聘列表 |
| | `/myyule_service_jobseek_adminSearchRecruitList/v1.0` | 管理员搜索招聘 |
| | `/myyule_service_jobseek_searchUserList/v1.0` | 搜索用户列表 |
| | `/myyule_service_jobseek_searchUserListByUserId/v1.0` | 按用户ID搜索 |
| | `/myyule_fstar_jobseek_searchUserListByCampusAmbassador/v1.0` | 按校园大使搜索 |
| | `/myyule_fstar_jobseek_searchRecommendUserList/v1.0` | 搜索推荐用户 |
| JobseekWeChatController | `/myyule_service_jobseek_send/v2.0` | 投递简历 |
| | `/myyule_service_jobseek_inreferralSend/v1.0` | 内部推荐投递 |
| | `/myyule_service_jobseek_sendSocial/v1.0` | 社招投递 |
| | `/myyule_service_jobseek_processList/v1.0` | 流程进度列表 |
| | `/myyule_service_jobseek_processList/v2.0` | 流程进度列表v2 |
| CJobseekWechatController | `/myyule_service_jobseek_send_combine/v1.0` | 组合投递 |
| SyncEsController | `/myyule_service_jobseek_syncJobseekEs/v1.0` | 同步求职数据到ES |
| | `/myyule_service_jobseek_syncRecruitEs/v1.0` | 同步招聘数据到ES |
| ResumeExportController | `/myyule_service_pass_jobseek_downResumeList/v2.0` | 下载简历列表 |
| | `/myyule_fstar_jobseek_downResumeListByCAmbassador/v1.0` | 按校园大使下载 |
| | `/myyule_fstar_jobseek_downRecommendResumeList/v1.0` | 下载推荐简历 |
| ResumeController | `/myyule_service_jobseek_resumeDetail/v1.0` | 简历详情 |
| RecruitExportController | `/myyule_service_jobseek_exportRcruitList/v2.0` | 导出招聘列表 |
| | `/myyule_service_jobseek_exportUserList/v2.0` | 导出用户列表 |
| | `/myyule_service_jobseek_exportUserList/v3.0` | 导出用户列表v3 |
| | `/myyule_service_jobseek_dynamicsImport/v1.0` | 导入动态数据 |
| | `/myyule_service_jobseek_exportStudentList/v1.0` | 导出学生列表 |
| RecruitController | `/myyule_service_jobseek_queryRecruitList/v3.0` | 查询招聘列表 |
| | `/myyule_service_jobseek_getRecruitDetail/v1.0` | 招聘详情 |
| | `/myyule_service_addRecruit/v1.0` | 添加招聘 |
| JobseekRecommendController | `/myyule_fstar_jobseek_recommendUserList/v1.0` | 推荐用户列表 |
| JobseekAmbassadorController | `/myyule_fstar_jobseek_userListByCAmbassador/v1.0` | 校园大使用户列表 |

#### 4.1.2 fstar管理（sservice/fstar）

| Controller | 端点 | 说明 |
|------------|------|------|
| RecommendController | `/myyule_fstar_recommendList/v1.0` | 推荐列表 |
| | `/myyule_fstar_recommendPoster/v1.0` | 推荐海报 |
| | `/myyule_fstar_getRoleType/v1.0` | 获取角色类型 |
| PosterAdminController | `/myyule_fstar_addPoster/v1.0` | 添加海报 |
| | `/myyule_fstar_posterList/v1.0` | 海报列表 |
| InreferralUserController | `/myyule_fstar_jobseek_inreferralUserList/v1.0` | 内推用户列表 |
| ConfigController | `/myyule_fstar_recruitmentChannels/v1.0` | 招聘渠道 |
| CampusAmbassadorController | `/myyule_fstar_addCampusAmbassador/v1.0` | 添加校园大使 |
| | `/myyule_fstar_campusAmbassadorList/v1.0` | 校园大使列表 |

#### 4.1.3 其他BFF端点

| Controller | 端点 | 说明 |
|------------|------|------|
| UserBrowseController | `/myyule_service_browse_browseRecruitList/v2.0` | 浏览招聘列表 |
| UserCollection | `/myyule_service_collection_searchCollectRecruitList/v1.0` | 搜索收藏招聘 |
| StarAccountController | `/myyule_service_account_starAccountTable/v1.0` | 星光账户表格 |
| | `/myyule_service_account_starInformation/v1.0` | 星光信息 |
| EnterpriseInfoController | `/myyule_public_account_saveEnterpriseInfo/v1.0` | 保存企业信息 |
| | `/myyule_public_account_queryEnterpriseInfo/v1.0` | 查询企业信息 |
| ResumeController(pass_space) | `/myyule_pass_space_resume_addOrUpdate/v1.0` | 添加/更新简历 |
| | `/myyule_pass_space_resume_list/v2.0` | 简历列表 |
| | `/myyule_pass_space_resume_getDetail/v1.0` | 简历详情 |

### 4.2 SPass-else（其他能力，~250+ endpoints）

| 业务域 | Controller | 端点数 | 说明 |
|--------|------------|--------|------|
| 招聘管理 | JobseekAdminController | 15 | 用户列表、阶段管理、考试判断 |
| | JobseekWeChatController | 12 | 投递、流程、标志、提示 |
| 权限管理 | AdminController | 8 | 管理员列表、角色成员 |
| | RoleController | 9 | 角色CRUD |
| | PermissionController | 10 | 权限检查、菜单 |
| | DataPermissionController | 3 | 数据权限配置 |
| 表情系统 | EmojiController | 10 | 表情CRUD |
| | MemeController | 11 | 表情包CRUD |
| | EmojiMenuController | 6 | 表情菜单 |
| 抽奖系统 | LotteryController | 9 | 抽奖信息、记录 |
| | PrizeController | 25 | 奖品CRUD |
| 商城系统 | GoodsOrderController | 8 | 订单管理 |
| | AddressController | 6 | 地址管理 |
| | PaymentController | 3 | 支付 |
| 应用管理 | ApplicationController | 3 | 应用列表 |
| 广告管理 | AdManageController | 7 | 广告CRUD |
| 升级管理 | ClientUpgradeConfigController | 7 | 客户端升级 |
| 反馈管理 | FeedbackInfoController | 7 | 反馈CRUD |
| 举报管理 | ReportController | 4 | 举报处理 |
| 协议管理 | AgreementController | 1 | 协议内容 |

### 4.3 SPass-dynamics（动态能力，~120+ endpoints）

| 业务域 | Controller | 端点数 | 说明 |
|--------|------------|--------|------|
| 活动管理 | DynamicActivityController | 34 | 活动CRUD、报名、签到、票务 |
| 动态管理 | DynamicsInfoController | 9 | 动态CRUD、计数 |
| | DynamicAdminController | 16 | 管理员动态列表 |
| | DynamicsForwardController | 4 | 转发 |
| 招聘管理 | DynamicsRecruitAdminController | 11 | 招聘CRUD |
| | DynamicsRecruitWeChatController | 4 | 微信招聘列表 |
| 新闻管理 | DynamicNewsController | 10 | 新闻CRUD |
| 音乐管理 | DynamicMusicController | 5 | 音乐CRUD |
| 统计分析 | StatisticsController | 5 | 统计、导出 |

### 4.4 SPass-space（空间/简历，~110+ endpoints）

| 业务域 | Controller | 端点数 | 说明 |
|--------|------------|--------|------|
| 简历管理 | ResumeController | 8 | 简历CRUD |
| | UserResumeInfoController | 7 | 用户简历 |
| | ResumeWechatController | 8 | 微信简历 |
| 简历模块 | AwardExpController | 4 | 获奖经历 |
| | EducationExpController | 4 | 教育经历 |
| | InternshipExpController | 5 | 实习经历 |
| | ProjectExpController | 5 | 项目经历 |
| | CampusExpController | 4 | 校园经历 |
| | ContestExpController | 4 | 竞赛经历 |
| | LangSkillInfoController | 3 | 语言技能 |
| | SoftwareSkillInfoController | 3 | 软件技能 |
| | SelfEvaluationController | 2 | 自我评价 |
| | DesignWorkController | 3 | 设计作品 |
| 空间信息 | SpaceInfoController | 3 | 空间信息 |
| | SpaceDynamicController | 9 | 空间动态 |
| | SpaceAlbumController | 4 | 空间相册 |
| 新闻资讯 | SpaceNewsInfoController | 8 | 新闻CRUD |

### 4.5 SPass-search（搜索能力，~80+ endpoints）

| 业务域 | Controller | 端点数 | 说明 |
|--------|------------|--------|------|
| 搜索核心 | SearchController | 10 | 批量操作、分页查询 |
| | SearchAllController | 4 | 全局搜索 |
| | SearchHistoryController | 2 | 搜索历史 |
| | SearchConfigController | 2 | 搜索配置 |
| | SearchDiscoveryController | 6 | 搜索发现 |
| 用户搜索 | AccountIndexController | 5 | 用户索引 |
| 招聘搜索 | RecruitIndexController | 7 | 招聘索引 |
| 求职搜索 | JobseekIndexController | 6 | 求职索引 |
| | RecommendJobseekIndexController | 2 | 推荐求职 |
| | AmbassadorJobseekIndexController | 2 | 大使求职 |
| 收藏搜索 | CollectRecruitController | 4 | 收藏招聘 |
| 索引管理 | IndexManageController | 4 | 索引CRUD |
| | IndexConfigController | 7 | 索引配置 |
| | DatasourceManageController | 4 | 数据源管理 |
| | DataController | 4 | 数据同步 |
| 接口访问 | EsInterfaceAccessController | 7 | ES接口访问统计 |
| | NginxAccessController | 1 | Nginx访问 |

### 4.6 SPublic-account（账户服务，~220+ endpoints）

| 业务域 | Controller | 端点数 | 说明 |
|--------|------------|--------|------|
| 登录 | LoginController | 9 | 登录、注销、游客、注册 |
| | SSOLoginController | 4 | SSO登录 |
| | TokenController | 8 | Token管理 |
| 验证码 | PhoneCodeController | 6 | 短信验证码 |
| 用户信息 | UserInfoController | 14 | 用户查询 |
| | UserInfoManageController | 17 | 用户信息管理 |
| | UserManageController | 3 | 用户管理 |
| | UserBaseController | 11 | 基础信息 |
| 用户能力 | UserCapacityController | 12 | 能力CRUD |
| | UserEnterpriseController | 4 | 企业认证 |
| 用户设备 | DeviceInfoController | 15 | 设备管理 |
| | ThemController | 14 | 主题管理 |
| 联系人 | ContactsController | 8 | 联系人管理 |
| 身份认证 | IdentityController | 3 | 身份标识 |
| | NameAuthenticationController | 6 | 实名认证 |
| | UserAvatarManageController | 4 | 头像管理 |
| 星光 | EnterpriseInfoController | 11 | 企业信息 |
| | SchoolStarTypeController | 5 | 校园明星类型 |
| 推广 | ChannelInfoController | 6 | 渠道管理 |
| | PromotionEnterPriseController | 3 | 推广企业 |

### 4.7 external（外部对接，~110+ endpoints）

| 业务域 | Controller | 端点数 | 说明 |
|--------|------------|--------|------|
| 短信验证码 | PhoneCodeController | 3 | 发送验证码、语音验证码 |
| 微信 | WechatController | 5 | 用户信息、手机号、签名、发布 |
| 易信 | YixinController | 1 | 易信用户信息 |
| | IMUserController | 1 | 终端信息上报 |
| 北森测评 | EvaluationBeisenController | 5 | 活动列表、测试报告、批量URL |
| E-Learning | SitechElearningController | 3 | 考试列表、成绩、链接 |
| 推送消息 | PushMsgController | 1 | 用户浏览消息 |
| | PushMsgManageController | 8 | 推送消息CRUD |
| 消息 | MSGController | 8 | 发送消息、推送 |
| | NoteController | 3 | 系统通知 |
| 部落 | TribeController | 34 | 部落CRUD、成员、动态 |
| | TribeAdminController | 15 | 管理员部落管理 |
| | TribeSetController | 6 | 部落设置 |
| | TribeCategoryController | 5 | 部落分类 |
| | JoinTribeController | 3 | 加入部落 |
| | OtherTribeController | 10 | 其他部落查询 |
| 工商银行 | IcbcController | 2 | ICBC页面请求、Token |
| AI | ERNIEBotController | 1 | AI评论 |
| 智能体 | AgentAssistantController | 1 | 智能体会话(SSE) |

---

## 五、短信发送机制（详细）

### 5.1 短信服务商

项目使用**易信（Yixin/Oncon）**作为短信和IM服务商，平台地址：`teamshub.com`

### 5.2 短信发送完整调用链

#### 路径1：标准短信验证码
```
入口: POST /myyule_pass_external_yixin_code/v1.0
PhoneCodeController.myyule_service_account_code()
  → Redis缓存检查（phoneNumber去重）
  → PhoneCodeServiceImpl.checkSmsNum(request) -- IP限流（100次/天，白名单IP 1000次/天）
  → reqJson.isValid() -- 参数校验
  → IF appId == "com.myyule.web.front" (官网):
      IMInvokingUtil.sendFrontCode() → HttpClientUtil.sendGet()
        → http://test.myyule.com/ajax/space/send/sms/reg/
  → ELSE (标准路径):
      SmsSendUtil.randomCode(6) -- 生成6位验证码
      MSCache.addRedisCache(phoneNumber, code, 180sec) -- Redis存储，3分钟TTL
      CheckPhoneUtil.check() -- 测试手机号 bypass
      SmsSendUtil.renderTemplateContent(code) -- Velocity模板渲染消息内容
      IMInvokingUtil.sendCode() → SmsSendUtil.sendSMS()
        → HTTP GET http://172.18.0.65:30303/regSms
```

#### 路径2：易信短信验证码
```
入口: POST /myyule_pass_external_yixin_code_yx/v1.0
PhoneCodeController.myyule_service_account_code_yx()
  → 参数校验
  → 测试手机号检查
  → 中国手机号格式校验（^1[0-9]{10}$）
  → Redis重复检查（appId+phoneNumber，3分钟TTL）
  → 获取/刷新易信AccessToken（Redis缓存，1小时TTL）
  → 构建易信API请求:
      URL: http://jk.teamshub.com/oncon-service/gateway/m1_send_verify_code/v2.0
      参数: client_id, flow_id, ts, access_token, sign
      Body（RSA加密）: {
        id, version: "2.0", action: "request",
        type: "m1_send_verify_code",
        mobile, appid: "yx_zarg3gihebuguknu",
        business_type: "0", pushSms: "1"
      }
  → YiTokenUtil.sign() -- SHA1签名
  → IMInvokingUtil.pushYixinMsg() → HttpClientUtils.sendPost() + 解密响应
  → 检查响应status == "0"判断成功
```

#### 路径3：语音验证码
```
入口: POST /myyule_pass_external_yixin_audioCode/v1.0
PhoneCodeController.myyule_pass_external_yixin_audioCode()
  → URL: http://jk.teamshub.com/oncon-service/gateway/m1_send_verify_voicecode/v1.0
  → Body: { type: "m1_send_verify_voicecode", mobile, appid: "com.sitech.weilaizhixing" }
  → IMInvokingUtil.sendAudioCode() → POST + 解密
```

#### 路径4：业务短信推送（异步Kafka）
```
业务代码（如JobseekAdminController）
  → 查询短信模板
  → 构建消息Map: {content, phone, type:"0", appType}
  → MSKafka.sendMessage("Topic_push_info", msgMap)
  → Kafka Consumer: YixinMessage.java
      @KafkaListener(topics = "Topic_push_info", groupId = "Group_push")
      → type == "0" → YixinMessageService.yxSendSMS()
          → URL: http://jk.teamshub.com/oncon-service/gateway/m1_sms_push/v1.0
          → Body: { mobile, content, appid: "yx_zarg3gihebuguknu", spid: "9811000046935171" }
          → RSA加密 + SHA1签名 → HTTP POST → 解密响应
      → type == "1" → YixinMessageService.pushMsgToYixin()
          → URL: http://jk.teamshub.com/oncon-service/gateway/ppf_custominterface_send/v3.0
          → 推送IM消息（支持futureStar/leader/默认账号）
```

### 5.3 短信发送关键工具类

| 工具类 | 路径 | 用途 |
|--------|------|------|
| `SmsSendUtil` | `public/external/.../yixin/im/common/util/SmsSendUtil.java` | 短信发送、验证码生成、模板渲染 |
| `YiTokenUtil` | `public/external/.../yixin/im/common/util/YiTokenUtil.java` | 易信Token/签名管理 |
| `IMInvokingUtil` | `public/external/.../yixin/im/common/util/IMInvokingUtil.java` | HTTP调用易信网关 |
| `CheckPhoneUtil` | `public/external/.../yixin/im/common/util/CheckPhoneUtil.java` | 测试手机号检查 |
| `PhoneCodeServiceImpl` | `public/external/.../yixin/im/service/impl/PhoneCodeServiceImpl.java` | 验证码次数检查 |

### 5.4 易信API端点汇总

| 常量 | 值 | 说明 |
|------|-----|------|
| `SENDCODE2` | `m1_send_verify_code/v2.0` | 短信验证码 |
| `VERIFYCODE` | `m1_check_verify_code/v1.0` | 验证短信码 |
| `SMSPUSH` | `m1_sms_push/v1.0` | 推送短信 |
| `VOICECODE` | `m1_send_verify_voicecode/v1.0` | 语音验证码 |
| `CUSTOMINTERFACESEND` | `ppf_custominterface_send/v3.0` | 推送IM消息 |
| `TOKEN2` | `token2` | 获取易信网关Token |
| `REGSMS` | `http://172.18.0.65:30303/regSms` | 老系统短信端点 |
| `FRONTSMS` | `http://test.myyule.com/ajax/space/send/sms/reg/` | 官网短信端点 |
| Base URL | `http://jk.teamshub.com/` | 生产环境易信网关 |

### 5.5 易信安全机制

- **clientId**: `yx_5ktxyzchxf4jjtzc`
- **clientSecret**: `a1smmd7najytp96huciaeta5c7b1z1yt`（RSA加密传输）
- **clientKey**: RSA公钥（1024-bit）
- **Token缓存**: Redis Key `YIXINACCESSTOKEN`，TTL 1小时
- **签名算法**: 参数按字母排序，拼接 `key=value` + body + clientSecret，SHA1哈希
- **FlowId**: 时间戳（`yyyyMMddHHmmssSSS`）+ 6位随机数

### 5.6 短信发送记录表

```sql
CREATE TABLE `user_jobseek_sms_record` (
  `id` varchar(50) NOT NULL COMMENT '主键ID',
  `jobseek_id` varchar(50) NOT NULL COMMENT '应聘数据ID',
  `user_name` varchar(100) NOT NULL COMMENT '用户姓名',
  `phone_number` varchar(20) NOT NULL COMMENT '手机号',
  `period` varchar(10) NOT NULL COMMENT '阶段:1=专业笔试提醒,2=能力测评提醒',
  `send_count` int(11) NOT NULL DEFAULT '1' COMMENT '已发送次数',
  `created_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_jobseek_period` (`jobseek_id`,`period`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户应聘短信发送记录表';
```

### 5.7 短信限流规则

- **IP限流**: 每IP每天100次（白名单IP `172.18.0.64`, `172.18.0.65` 为1000次/天）
- **手机号去重**: Redis缓存，Key为 `appId+phoneNumber`，TTL 3分钟
- **发送次数上限**: 每个应聘数据每阶段最多2次短信（通过 `user_jobseek_sms_record` 表控制）

---

## 六、外部服务集成（详细）

### 6.1 微信（WeChat）

**包路径**: `com.myyule.server.publics.external.wechat`

**功能**:
- OAuth2授权登录（code → openId + access_token）
- 用户信息获取
- 小程序手机号获取
- JS-SDK签名生成（SHA1）
- 模板消息发送
- 文章发布（草稿 → 群发 `https://api.weixin.qq.com/cgi-bin/message/mass/sendall`）
- 素材图片上传

**数据库**: `wechat_credentials` 表存储 `app_id`, `wechat_appid`, `wechat_appsecret`

**Kafka异步**: `Topic_push_WXinfo` → `PushWxMsg` Consumer → 微信模板消息

**外部URL**: `http://toouternet.teamshub.com/cgi-bin/message/template/send`

### 6.2 北森（BeiSen）— 人才测评平台

**包路径**: `com.myyule.server.publics.external.beisen`

**功能**:
- 测评活动列表查询
- 测试报告查询（按邮箱+活动）
- 测试结果查询
- 报告下载/预览
- 批量获取测评URL

**SDK凭证**:
- CONSUMER_KEY: `3880a8a23b4048daae9afd127bd7aca0`
- TENANT_ID: `107562`
- BEISEN_ACCOUNT: `jiekou@si-tech.com`

**注解**: `@MSbeisenExternalRequest` + `MSbeisenExternalRequestAOP`

### 6.3 E-Learning（思特奇大学）

**包路径**: `com.myyule.server.publics.external.elearning`

**功能**:
- 用户注册同步
- 考试类型查询
- 考试链接获取
- 成绩查询

**Base URL**: `http://elearning.teamshub.com/kmd_exam/star/`
**端点**: `syncInfo`, `getExamType`, `getExamLinked`, `queryExamInfo`

**注解**: `@MSElearnExternalRequest` + `MSEleranExternalRequestAOP`

### 6.4 工商银行（ICBC）

**包路径**: `com.myyule.server.publics.external.icbc`

**功能**: ICBC页面请求、Token获取

### 6.5 百度智能体（Baidu Agent）

**URL**: `https://agentapi.baidu.com/assistant/conversation?appId={appId}&secretKey={secretKey}`

**功能**: 智能体会话（SSE流式响应）

### 6.6 推送消息系统

**架构**:
```
PushMsgController (用户浏览)
PushMsgManageController (管理员管理)
  → PushMsgService / PushMsgServiceImpl
    → PushMsgInfoDao (消息信息CRUD)
    → PushMsgRecordDao (推送记录CRUD)
    → PushMsgUserRecordDao (用户推送记录)
    → PushMsgBrowseRecordDao (浏览记录)
    → PublicExternalFeignClient (Feign到IM服务)
    → PublicUserFeignClient (Feign到用户服务)
```

**推送流程**:
1. 管理员创建推送消息（`createPushMsg` / `dynamicPushMsg` / `webPushMsg`）
2. 消息类型: `news`（动态/新闻）, `web`（外部链接）
3. 推送范围: `0`（全部用户）, `1`（指定用户）, `2`（指定部落/群组）
4. 全量推送: 分页查询用户列表 `PublicUserFeignClient.queryUserListByPage()`
5. 实际发送: `PublicExternalFeignClient.sendPushMessage()` 或 `sendImMessageDev()`
6. Intent类型: `1`（新闻推送）, `2`（网页链接）, `4`（动态推送）

---

## 七、Kafka主题详细清单

### 7.1 核心消息主题

| Topic | Consumer Group | 说明 |
|-------|---------------|------|
| `Topic_push_info` | `Group_push` | **短信/IM推送** → YixinMessage |
| `Topic_push_WXinfo` | `Group_wx_push` | **微信模板消息** → PushWxMsg |
| `Topic_activity_message` | - | 活动通知消息 |
| `Topic_leader_account_message` | - | 负责人账号消息 |
| `Topic_post_account_message` | - | 帖子账号消息 |

### 7.2 用户生命周期

| Topic | 说明 |
|-------|------|
| `Topic_account_register` | 用户注册同步 |
| `Topic_account_subRegister` | 子注册 |
| `Topic_official_register` | 官方注册 |
| `Topic_contact_register` | 联系人注册 |

### 7.3 动态/内容

| Topic | 说明 |
|-------|------|
| `Topic_publish_dynamic` | 发布动态 |
| `Topic_delete_dynamic` | 删除动态 |
| `Topic_shield_dynamic` | 屏蔽动态 |
| `Topic_publish_image_dynamic` | 图片动态 |
| `Topic_publish_music_dynamic` | 音乐动态 |
| `Topic_publish_news_dynamic` | 新闻动态 |
| `Topic_publish_activity_dynamic` | 活动动态 |

### 7.4 求职/招聘

| Topic | 说明 |
|-------|------|
| `Topic_jobseek_resume` | 求职简历 |
| `Topic_sitechRecruit_resume` | Sitech招聘简历推送 |
| `Topic_sitechRecruit_grade` | Sitech成绩推送 |
| `Topic_sitechRecruit_beisen` | 北森测评推送 |

### 7.5 数据同步

| Topic | 说明 |
|-------|------|
| `Topic_account_data_sync` | 账户数据ES同步 |
| `Topic_collect_data_sync` | 收藏数据ES同步 |
| `Topic_jobseek_data_sync` | 求职数据ES同步 |
| `Topic_jobseek_pdf_resume` | PDF简历生成 |
| `Topic_data_share_new` | 数据共享 |
| `Topic_sync_table_data_notice` | 表数据同步通知 |
| `Topic_redis_persistence` | Redis持久化 |

### 7.6 其他

| Topic | 说明 |
|-------|------|
| `Topic_ws_groupdb_queue` | 群组DB队列 |
| `Topic_ws_ptpdb_queue` | 点对点DB队列 |
| `Topic_live_waiting_sendmsg` | 直播待发消息 |
| `Topic_live_job` | 直播任务 |
| `Topic_transfer_club` | 俱乐部转移 |
| `Topic_tribe_updateStatus` | 部落状态更新 |
| `Topic_compet_vote` | 竞赛投票 |
| `Topic_maxwell` | Maxwell CDC数据库变更 |

### 7.7 Kafka生产者配置

```properties
acks=all
retries=3
batch.size=16384
linger.ms=100
buffer.memory=33554432
```

支持SASL认证，通过 `spring.kafka.enable=true` 开关控制。

---

## 八、编码规范与最佳实践

### 8.1 分层架构（每层职责明确）

```
Controller（@RestController） → 接收请求、参数校验、调用Service
    ↓
Service（interface + impl） → 业务逻辑编排、Feign调用、事务管理
    ↓
Dao（@Mapper + XML/注解） → MyBatis数据访问、SQL映射
    ↓
Entity（@Data POJO） → 数据实体，与数据表一一对应
    ↓
common.json/ → Req/Res JSON对象（DTO），与前端协议对应
```

### 8.2 包结构命名规范

```
com.myyule.server.{模块}.{子域}/
├── controller/          # REST控制器
├── service/             # 业务接口（interface）
│   └── impl/            # 业务实现
├── dao/                 # MyBatis Mapper接口（+ XML映射文件在同一目录或resource）
├── entity/              # 数据实体（Lombok @Data）
├── common/              # 公共模块
│   ├── json/            # 请求/响应JSON对象
│   ├── constant/        # 常量类
│   ├── util/            # 工具类
│   └── entity/          # 通用实体
├── feign/ 或 feignclient/  # Feign远程调用客户端
├── kafka/               # Kafka消费者/生产者
├── config/              # Spring配置类
└── task/                # 定时任务
```

### 8.3 数据库规范

- **ORM**: MyBatis + MyBatis-Plus（v3.0.6）
- **连接池**: Druid（1.1.10）
- **分页**: PageHelper（1.2.3）
- **分库分表**: Sharding-JDBC（3.0.0，可选启用）
- **多数据源**: 通过 `@MSDataSource` 注解 + AOP 切换数据源
- **数据源配置开关**:
  - `spring.datasource.single.enable=true` — 单数据源模式（`MSDataSourceSingleConfig`）
  - `spring.datasource.dynamic.enable=true` — 多数据源模式（`MSDataSourceAutoConfig`）
  - `spring.datasource.sharding.enable=true` — 分库分表模式（`MSShardingDataSourceConfig`）
- **DAO写法**: `@Mapper` 接口 + `@Select`/`@Insert` 注解（非XML）

### 8.4 Feign远程调用规范

#### FeignClient写法：
```java
@FeignClient(
    name = "myyule-public-account",
    fallbackFactory = MSDefaultHystrixFallbackFactory.class
)
public interface UserFeignClient {
    @RequestMapping("/myyule...")
    String queryUserInfo(String reqJson);
}
```

- 所有FeignClient都配置Hystrix熔断（`feign.hystrix.enabled=true`）
- 默认超时：connectTimeout=30000, readTimeout=30000
- 负载均衡：Ribbon RandomRule（随机策略）
- 编码器：支持Spring `HttpMessageConverter` + `FeignEncoder`
- 自定义Fallback：`MSDefaultHystrixFallbackFactory` -> `MSDefaultHystrixFallbackHandler`
- 自定义TraceId传递：`MSFeignInterceptorConfig` 通过 `RequestInterceptor` 在header中添加traceId

#### 自定义FeignClient接口（标记接口）：
```java
// 需要支持自定义Fallback的FeignClient实现此接口
public interface MSFallbackableFeignClient {}
```

### 8.5 缓存规范

**缓存层级**（双缓存：本地内存 + Redis）：
```
MSCache（门面）
  ├── MSMemoryCache（本地Caffeine/LRU缓存）
  └── MSRedisCache（Redis缓存，Redisson + Lettuce + Jedis）
```

**使用方式**：
```java
// 自动管理缓存（先查本地 -> 再查Redis -> 最后查DB）
msCache.fromMemoryCache(key, () -> queryFromDB());
msCache.fromRedisCache(key, () -> queryFromDB());
```

**缓存分类**：MSLabelCache, MSDynamicsConfCache, MSUserCache, MSEnterpriseCache, MSVideoCache, MSAccessTokenCache等

### 8.6 消息队列规范（Kafka）

- **生产者**: `MSKafka` 工具类封装（支持同步/异步发送）
- **消费者**: `@KafkaListener` 注解监听，通过 `KafkaConsumerConfig` 配置工厂
- **Kafka配置开关**: `spring.kafka.enable=true`
- **Topic常量**: 统一在 `MSKafkaConstant` 中定义（100+ topics）

### 8.7 搜索规范（Elasticsearch）

- **版本**: ES 7.2.0 + Spring Data Elasticsearch 3.2.1
- **客户端**: `elasticsearch-rest-high-level-client`
- **索引管理**: `pass-search` 模块中的 `index` 包管理索引CRUD
- **数据同步**: 通过Kafka消息驱动ES索引更新（各服务产出的Kafka Consumer写入ES）
- **搜索模块**: `SPass-search` 是整个项目的搜索能力中心

### 8.8 线程池与异步

- **自定义线程池**: `MSThreadManager`（`ThreadPoolUtils`），支持多种`ThreadPoolType`
- **MDC传递**: `ThreadPoolExecutorMdcWrapper` 确保日志追踪ID在线程间传递
- **Future异步**: `MSFuture` + `MSFutureCallBack` 自定义异步回调框架

### 8.9 日志规范

- **框架**: SLF4j + Logback（`logback-spring.xml`）
- **TraceId**: 通过 `MSTraceConstant.LOG_TRACE_ID` 传递（header: `app_trace_id`）
- **Hystrix MDC**: `MdcHystrixConcurrencyStrategy` 确保Hystrix线程池中的MDC上下文传递
- **切面日志**: 
  - `MSSingleInterfaceLogAspect` — 拦截所有 `*Controller.*()` 记录接口日志
  - `FeignClientAspect` — 拦截Feign调用记录
  - 外部请求AOP切面 — 分别记录BeiSen/ELearn/微信/易信等外部接口调用

### 8.10 异常处理

- **全局异常**: `MSGlobalExceptionHandler`（`@ControllerAdvice`）统一拦截 `Exception.class`
- **返回格式**: 返回原始字符串（`@ResponseBody String`），手动构建错误JSON

### 8.11 拦截器与AOP

#### 拦截器

| 拦截器 | 用途 |
|--------|------|
| `LogInterceptor` | 接口请求日志拦截（preHandle记录开始，afterCompletion记录耗时） |
| `IdempotentInterceptor` | 幂等请求检查（SPublic-account） |
| `FeignInterceptor` | Feign请求头注入（appId, deviceId, traceId等） |
| `InterceptorConfig` | 注册拦截器到 `WebMvcConfigurer` |

#### AOP切面

| 切面 | 用途 |
|------|------|
| `MSSingleInterfaceLogAspect` | 接口日志记录 |
| `FeignClientAspect` | Feign调用日志 |
| `MSExternalRequestAOP` | 通用外部请求日志 |
| `MSWechatExternalRequestAOP` | 微信外部请求日志 |
| `MSyixinExternalRequestAOP` | 易信外部请求日志 |
| `MSbeisenExternalRequestAOP` | 北森外部请求日志 |
| `MSEleranExternalRequestAOP` | E-Learn外部请求日志 |
| `DuplicateRequestAOP` | 防重提交 |
| `MSDataSourceAOP` | 动态数据源切换 |
| `MaxConcurrentAspect` | 最大并发控制 |
| `MSRedisAspect` | Redis缓存切面 |
| `KafkaConsumerLog` | Kafka消费者日志 |
| `SitechElearningAspect` | Sitech E-Learning AOP |
| `SearchAspect` | 搜索操作AOP |

### 8.12 工具类库

| 工具类 | 用途 |
|--------|------|
| `EmojiUtil` | Emoji处理（多个模块各自有实现） |
| `FormatTransUtil` | 日期格式化转换 |
| `HttpUtil` / `HttpClientUtil` / `HttpClientUtils` | HTTP请求工具 |
| `AESUtil` / `RSAUtil` | 加密解密 |
| `TokenUtil` | JWT Token生成/验证 |
| `IPUtil` | IP地址工具 |
| `IDUtil` | ID生成器（雪花算法） |
| `FileTool` | 文件操作 |
| `ZipFileUtils` | ZIP打包解压 |
| `SFTPUtil` | SFTP文件传输 |
| `SensitiveUtil` | 敏感信息脱敏 |
| `ExcelUtils` / `PoiUtil` / `PdfUtils` | Excel/PDF导出（Apache POI + Flying Saucer） |
| `SmsSendUtil` | 短信发送工具 |
| `YiTokenUtil` | 易信Token/签名工具 |
| `IMInvokingUtil` | 易信HTTP调用工具 |
| `CheckPhoneUtil` | 测试手机号检查 |

### 8.13 常量文件清单

| 常量类 | 位置 | 用途 |
|--------|------|------|
| `MSKafkaConstant` | integration/api-common | Kafka主题和消费者组（100+） |
| `MSGlobalConstant` | integration/api-common | 全局常量 |
| `MSStatusConstant` | integration/api-common | 状态码 |
| `MSTypeConstant` | integration/api-common | 类型常量 |
| `MSProtocolConstant` | integration/api-common | 协议常量 |
| `MSAppIdConstant` | integration/api-common | 应用ID |
| `MSInterfaceURLConstant` | integration/api-common | 接口URL |
| `MSFastdfsConstant` | integration/api-common | FastDFS常量 |
| `MSTraceConstant` | integration/api-common | 追踪常量 |
| `MSHttpClientConstant` | integration/api-common | HTTP客户端常量 |
| `MSDataSourceConstant` | integration/db-common | 数据源常量 |
| `MSShardingConstant` | integration/db-common | 分库分表常量 |
| `YinxinConstants` | public/external | 易信API端点 |
| `YixinConstants2` | public/external | 易信IM端点 |
| `ElearnConstants` | public/external | E-Learning端点 |
| `BeiSen Constants` | public/external | 北森SDK凭证 |
| `ExternalUrlConstant` | public/external | 外部URL |
| `KafkaConstant` | service/SService-fstar | Sitech Kafka主题 |
| `CommonConstant` | public/external | 通用常量 |
| `NoteConstant` | public/external | 消息常量 |
| `SPassRedisKeyConstant` | public/SPublic-account | Redis Key常量 |
| `SPassAccountConstant` | public/SPublic-account | 账户常量 |
| `HeatConstant` | pass/SPass-dynamics | 热度常量 |
| `ReportTypeConstant` | pass/SPass-else | 举报类型 |
| `PrizeTypeConstant` | pass/SPass-else | 奖品类型 |
| `ColumnTypeConstant` | pass/SPass-search | 列类型 |
| `BusinessIdentConstant` | integration/api-common | 业务标识 |
| `CacheHitConstant` | integration/api-common | 缓存命中 |
| `BusinessKeyConstant` | integration/api-common | 业务Key |
| `ShieldTypeConstant` | integration/api-common | 屏蔽类型 |
| `MSLogPrintConstant` | integration/log-common | 日志打印 |

---

## 九、核心业务流

### 9.1 招聘/求职核心流程

```
企业发布招聘岗位（RecruitController）
    → 用户浏览招聘列表（UserBrowseController）
    → 用户收藏岗位（UserCollection）
    → 用户投递简历（JobseekWeChatController.send/v2.0）
    → 异步处理：
        ├── Kafka → ES数据同步（EsDataSynchronization）
        ├── Kafka → PDF简历生成（PdfResume）
        ├── Kafka → 微信消息推送（PushWxMsg）
        ├── Kafka → 短信通知（YixinMessage, type=0）
        ├── 北森测评链接获取（beisenBatchQueryTestURL）
        └── Sitech第三方推送（SitechRecruit）
    → 查询流程进度（processList）
    → 管理员审核/导出（JobseekAdminController + RecruitExportController）
    → 考试短信提醒（ExamSmsRemindController，限2次/阶段）
```

### 9.2 用户注册/登录流程

```
用户请求
    → SPublic-account（LoginService）
        → 多种登录方式：手机号、微信、易信、SSO
        → 登录处理器链：LoginHandler → SafetyHandler → RegisterHandler → ...
        → Kafka消息异步：AccountRegisterSync, GatewayOnlineSync
    → 完善星光信息（StarAccountController)
        → 区分角色：求职者/校园大使/内部员工
    → 用户信息同步至ES（EsAccountDataSynchronization）
```

### 9.3 短信验证码流程

```
用户请求发送验证码
    → PhoneCodeController
        → Redis去重检查（3分钟TTL）
        → IP限流检查（100次/天）
        → 生成6位验证码
        → Redis存储验证码（3分钟TTL）
        → 调用易信API发送短信
        → 返回成功/失败

用户提交验证码
    → 验证接口
        → 从Redis获取存储的验证码
        → 比对用户输入
        → 返回验证结果
```

### 9.4 动态/活动/内容流

```
用户发布动态（DynamicsInfoController）
    → 图片/视频上传
    → Forward/点赞/评论
    → 活动发布/报名/签到
    → 热度计算（HeatComponent + CalculateFeignClient）
    → ES索引（通过interplay/search模块）
```

### 9.5 推送消息流程

```
管理员创建推送（PushMsgManageController）
    → 选择消息类型（news/web/dynamic）
    → 选择推送范围（全部/指定用户/指定部落）
    → 分页查询目标用户
    → 调用IM服务发送推送消息
    → 记录推送记录
```

---

## 十、Git分支管理规范（来自shell脚本）

### 10.1 分支策略

```
master (生产)
    ↑ merge
test (测试)
    ↑ merge
dev (开发)
```

### 10.2 提交流程

**开发合并到测试（`dev` -> `test`）**:
```bash
cd 模块目录
git checkout test
git pull
git merge dev
git push
git checkout dev
```

**测试合并到生产（`test` -> `master`）**:
```bash
cd 模块目录
git checkout master
git pull
git merge test
git push
cd ..
git checkout master
git pull
git add 模块目录名
git commit -m '版本信息上传'
git push
git submodule foreach --recursive git checkout dev
```

### 10.3 子模块管理
```bash
git submodule deinit -f <模块名>    # 本地删除不需要的模块代码
git submodule update --init        # 恢复子模块
git submodule                      # 查看子模块当前版本
```

---

## 十一、开发环境

### 11.1 关键配置

| 配置项 | 开发环境值 |
|--------|-----------|
| MySQL主库 | 172.18.192.172:8088 |
| MySQL账户库 | 172.18.231.245:3306 |
| Nacos | 127.0.0.1:8848 |
| Kafka | 172.18.231.107:9093 |
| Redis集群 | 172.18.231.245:7000-7005 |
| 文件服务 | https://testfile.myyule.com |
| 接口前缀 | https://testapi.myyule.com |
| 易信网关 | http://jk.teamshub.com/ |
| 老短信端点 | http://172.18.0.65:30303/regSms |
| E-Learning | http://elearning.teamshub.com/kmd_exam/star/ |
| 微信模板消息 | http://toouternet.teamshub.com/cgi-bin/message/template/send |

### 11.2 启动方式
```bash
# 构建公共库
cd integration
mvn clean install -DskipTests

# 启动各服务（按依赖顺序）
cd pass/SPass-else && mvn spring-boot:run
cd public/SPublic-account && mvn spring-boot:run
cd public/external && mvn spring-boot:run
cd service/SService-fstar && mvn spring-boot:run
```

---

## 十二、注意事项与约定

1. **所有FeignClient必须配置 `fallbackFactory = MSDefaultHystrixFallbackFactory.class`**
2. **JSON交互使用 `MSReqJson`/`MSResJson` 统一协议格式**，参数放在 `params` 字段中
3. **Controller方法返回String**，由业务代码手动构造MSResJson返回
4. **MyBatis Mapper默认使用 `@Mapper` + `@Select`/`@Insert` 注解**，通过 `@MapperScan` 配置
5. **数据源切换**通过 `@MSDataSource(name = "second")` 注解在Dao方法上切换
6. **Kafka Topic/Group常量集中在 `MSKafkaConstant`**，Consumer Group命名与业务对应
7. **外部接口（北森、ELearn、微信、易信）** 统一使用自定义注解 + AOP处理日志和异常
8. **防重提交**使用 `@DuplicateRequest` 注解（基于参数MD5 + Redis）
9. **PDF简历**使用Freemarker模板 + Flying Saucer引擎渲染
10. **项目使用Git子模块**管理，每个模块独立仓库，父仓库跟踪版本号（commit id）
11. **短信发送**统一通过易信平台，异步消息走Kafka `Topic_push_info`，限流规则：IP 100次/天，手机号3分钟去重
12. **微信消息**统一通过Kafka `Topic_push_WXinfo` 异步发送模板消息
13. **验证码**存储在Redis，TTL 3分钟，Key为手机号
14. **Token管理**使用JWT，Redis缓存，支持多端登录检测
