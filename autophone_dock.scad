// AutoPhone 充电座外壳 — 参数化,前低后高的楔形,Bambu Lab A1(256 x 256 x 256)打印。
// 当前版本:170 x 127(≈4:3),顶面倾角 6°(前高 6.7、后高约 19.9);屏幕(2.8" CYD 板)在左,无线充电线圈 + MagSafe 磁环在右,
//   ESP32 开发板贴在线圈前方顶面内侧,USB-C 在背面居中;顶面和侧壁一体,唯一的接缝在底面(嵌入式底板)。
// 坐标(俯视):X = 左→右,Y = 前→后,Z = 上。下面的注释保留了每一版的修改原因(第 N 版 …),方便按实物再调。
//
// 渲染:  openscad -D 'part="shell"' -o shell.stl autophone_dock.scad
//        打印件:shell(外壳,顶面朝下)| plate2(底板)| cover(线圈压板)| clipsbrim(屏幕卡件 x14,带可撕裙边)| whites(白色 logo + 文字,双色共打)
//        预览:assembly(默认)| inside(内部器件)| exploded
part = "assembly";

$fn = 96;
use <logo/logo_mark.scad>
use <fonts/Exo2-W800.ttf>   // Exo 2 ExtraBold(SIL Open Font License,见 fonts/OFL-Exo2.txt)   // 产品标志(圆环 + 电话听筒 + 声波)
eps = 0.01;

// ---------------------------------------------------------------- 外形
// 第2版布局(第4次试装后设计者定):倾角 10°→6° 显薄;不再用铜箔触摸,ESP32 挪到屏幕前方(原触摸区),
// 屏幕往线圈靠 → 宽 200→170。6° 时前部净高变小,前高 6→8 才放得下 ESP32 和屏幕背面器件(后高 29→22)
// 第2版b(设计者审阅后):左右构图对称 —— 左边距 13 | 手机 74.7 | 间隔 13 | 窗 69.8 | 右边距 13.5;
// 线圈、手机、屏幕中心在同一条 y 线上;USB-C 口在背面正中;倒角加大到看得出来
// 第2版c(设计者定):170 x 127(≈4:3),前高 6。屏幕板长 86,右侧只能到内壁 → 左 7.5 | 手机 | 7.9 | 窗 | 右 10.1
// 前高 6 时前部净高不够把 ESP32 放在屏幕前 → ESP32 放左前(手机前半段下面),Qi 板放屏幕正前方
W = 170;          // 宽
D = 127;          // 深(俯视投影)
R = 12;           // 圆角
front_h = 6.7;    // 前沿外高(第6版:6.5→6.7,屏幕内缩 0.8 后屏幕板背面下方净空要补回)(第3版:6→6.5,ESP32 照原样贴顶面装、前移到线圈方台前面,不用叠放/翻面)(地面到顶面);设计者要求边缘轻薄。约束:屏幕前沿下方要留 ~10.5mm(见下文)
angle = 6;        // 顶面倾角(度):前低后高,手机和屏幕朝用户倾斜
slope = tan(angle);
function top_z(y) = front_h + slope * y;      // 顶面高度
back_h = top_z(D);

lid_t = 2.0;      // 顶面厚(垂直于面板)
lid_v = lid_t / cos(angle);                   // 上盖的竖直厚度
wall_t = 2.0;
lip_h = 3;        // 上盖内沿高(垂直于面板)
lip_t = 1.6;
fit_gap = 0.3;

// ---------------------------------------------------------------- 面板上的元素,位置都用俯视坐标 [x, y]
// 第4版(设计者):左右对调 —— 屏幕在左、MagSafe 在右(从正面/顶面看);所有 x 按 W - x 镜像,板子本身只平移不翻转
coil_c = [129.15, 83];      // 第3版(设计者,内侧视角 右4 下5.5):手机外沿离设备边 3.5 基本齐平;圆心与屏幕窗中心同一水平线
// 充电线圈(线圈面朝面板放入):从外表面起 —— 覆盖层 0.5 / 44mm 线圈坑 1.0(线径)/ 49.5mm 磁片坑 1.0
// 线圈区局部加厚到 2.5(面板其余 2.0);磁片外围四段 1.2mm 宽的圆弧把它包住;台阶上四条走线槽引出线圈线
coil_d = 49.5;     // 磁片外径(设计者实测 49,定 49.5)
coil_wire_d = 44;  // 线圈本体外径(设计者实测)
coil_skin = 1.0;   // 覆盖层(第4次:0.5→1.0,设计者提议加厚:磁环凹槽 0.5 下面留 0.5 整圈连着,中间圆盘不再悬空;打印正好 4 层 0.24+0.28×3)
coil_wire_h = 1.0; // 线圈坑深 = 线径
coil_ferrite_h = 1.0;   // 磁片坑深
coil_fit = 0.4;    // 直径方向余量
coil_local_t = coil_skin + coil_wire_h + coil_ferrite_h;   // 2.5:线圈区局部厚度
coil_arc_w = 1.2;  // 包裹圆弧宽(设计者:1mm 或略宽)
coil_arc_h = 0;    // 第2版d:包裹圆弧取消,改由线圈压板压住磁片(原 1.5)
coil_lead_w = 2.5; // 走线槽宽(上下左右四条)
lead_drop = 0.3;   // 走线槽比线圈坑再深 0.3,给上面的磁吸贴凹槽留料
// MagSafe 磁吸贴(设计者实测:外径 55、内径 45、厚 0.5):外表面挖环形凹槽,贴进去与面板齐平(替代原来 57.5~60 的对位刻线)
mag_od = 55;
mag_id = 45;
mag_t = 0.5;
mag_fit = 0.4;     // 直径方向余量
// 凹槽内径 44.6 与线圈坑 44.4 几乎重合 → 中间圆盘只靠 0.1mm 连着、凹槽上方一层悬空,第3次试装件中间掉了
// 凹槽里留一圈径向连接筋(与顶面齐平,首层就打在床上):托住中间圆盘、给上面那层当支撑;装磁环前用斜口钳剪掉
mag_tab_n = 0;       // 覆盖层加厚后筋只是给凹槽上方那层搭桥当支撑,减到 8 根,少剪几刀
mag_tab_w = 1.0;
// 第5版(设计者):凹槽上方那层整圈悬空,切片软件只选一个桥接方向,在圆环相切处拉出近 30mm 的长斜线。
// 在原 8 根筋的位置开 8 道径向细缝(只在凹槽底下 0.5~1.0 深、宽 0.4),把悬空环带切成 8 个独立扇形,
// 每块各自桥接(最短跨度≈径向 5.4mm)。缝被磁环盖住,顶面看不到;径向缝不切断中间圆盘与外圈的连接
mag_slit_n = 24;           // 第10版实测:8 道时 0.32 首层下桥接走成切向长线 → 24 道 + 首层 0.24,切片器全走径向(径向度 0.99)
mag_slit_w = 0.4;
engrave = 0.6;

cyd_c = [47.0, 83];         // 第3版:屏幕模块整体旋转 180°、往手机方向挪 2(窗与手机间隔 ≈9.9,右边距 ≈12.1)
glass = [69.0, 50.0];      // 屏幕玻璃 + 触摸层(设计者实测 69 x 50)
glass_clear = 0.4;
cyd_pcb = [86, 50];
// 安装孔:实测 78 x 40,第二轮试装后设计者按"圆盘在上竖看"给的修正:上两孔各 上+0.8、外+0.8,下两孔各 外+0.8
// → 长向 78.8、短向 41.6,孔组中心朝线圈方向(-x)偏 0.4;开窗位置不动
cyd_holes = [78.8, 41.6];
cyd_hole_shift = [-0.4, 0];  // 第4版:屏幕移到左侧后再转 180° 回原朝向,让 CYD 上的天线靠近外壳边缘(孔组偏移回到 -0.4)
// 第6版(设计者):屏幕玻璃不再与顶面齐平 —— 往里退 bezel_t,顶面留一圈 3 层厚的边框压住玻璃四周不发光的黑边;
// 开窗只露发光区:黑边 右(靠手机)8mm,其余三边 2mm;窗口外缘 0.5mm 45° 斜角
bezel_t = 0.8;             // 3 层(0.24 + 0.28 + 0.28)
bezel_side = [2, 8, 2, 2]; // 玻璃边到发光区:左 右 前 后(俯视)
bezel_chamfer = 0.5;
glass_stack = 4.2;         // PCB 顶面到玻璃顶面:测试件实测 5.2 时屏幕低于面板 1mm → 4.2(安装柱降低 1mm),玻璃顶与面板顶齐平
cyd_boss_d = 6.0;          // 屏幕板的支撑台(高 = glass_stack - lid_t)
// 第5版(设计者):屏幕以后要触摸点按,按压会把板子往里推 → 定位柱改 M3 自攻螺丝(从板背面拧进支撑台,底孔离顶面留 0.8)
cyd_screw = false;         // 第6版(设计者):改回定位柱 + 套筒卡件(开口筒,弹力抱紧柱子压住板子),不拧螺丝
// 第8版(设计者:装卡件时断了一根柱):根部(穿板的 1.6)加粗到 3.0、柱头改半球圆帽、卡件缩短到 3.0 减小力臂;
// 切片外墙 4 圈让细柱全实心(原 2 圈 + 稀疏填充 = 空心管,层缝处一掰就断)
cyd_pin_root_d = 3.0;      // 屏幕板孔 3.2
cyd_pin_h = 5.0;           // 从支撑台面算:穿过板 1.6 + 卡件 3.0 + 0.4
clip_od = 6.0;
clip_id = 2.95;            // 柱 2.8:开口筒靠缝隙弹力抱紧;2.85 实测偏紧
clip_len = 3.0;
clip_n = 14;               // 设计者:每个外壳 14 个
clip_cols = 7;             // 7×2 一排,放外壳前方的空地
clip_slit = 0.6;
win_relief = 0;            // 第3次试装:0.6 细缝反而让打印头在角上来回拐,取消;改用切片填充方向与窗边平行
// win_relief = 1.2;          // 开窗四角:四条边各自直着延长 1.2mm 交叉成直角(设计者:不要打印头转弯成圆角)
win_relief_w = 0.6;
win_rib_w = 1.6;           // 开窗四周加强围框(高度 = 支撑台高度)
win_rib_gap = 0;           // 短边围框不留空(设计者:模块设计已规避排线问题)
pilot_d = 2.6;             // M3 自攻底孔

// 顶面凹刻 Logo(设计者:屏幕下方原触摸区空着,刻 "AutoPhone",做法同 MagSafe 环形凹槽 —— 首层就是字的轮廓)
// 字体:Liberation Sans Bold(OpenSCAD 自带,SIL OFL 开源,无授权问题)
logo_text = "AUTOPHONE";   // 第5版(设计者):回到 AutoPhone,字可以大很多
logo_font = "Exo 2:style=ExtraBold";   // 第7版(设计者):大写 + Exo 2 字体;白色 TPU 嵌件压进凹槽   // 常规字重:字母内的小岛(P/o/e/A 中间)比粗体大很多,顶面朝下打时不容易被蹭掉
logo_w = 66;               // 字宽(开窗宽 69.8 的约 95%),字高约 9.8;最小的内岛(e)3.8 x 2.2
logo_c = [44, 29];          // 与发光区开窗左右居中(第6版开窗中心偏左 3)
logo_spacing = 1.10;
logo_depth = 0.84;         // 文字凹槽深(2026-11-14 设计者:白色只打 4 层 = 0.24 + 3×0.2;原 2.0 是 TPU 嵌件时代)
text_pad = [74, 20, logo_depth > lid_t / 2 ? 2.0 : 0];  // 加强垫:宽 高 厚 —— 只在文字槽深过顶面一半时才加;0.84 槽底仍剩 1.16,不加(设计者:文字后面不加厚)
mark_depth = 0.84;         // logo 凹槽:白色 4 层(2026-11-14 设计者;原 1.2);正下方贴着 ESP32 板,不能加垫
inlay_fit = 0.05;          // 嵌件每边比凹槽小 0.05:TPU 压进去靠弹力卡紧          // 凹深 0.5(约 2 层)
// 产品标志:MagSafe 线圈正下方、与文字同一水平线(放手机时被手机盖住,拿开手机可见)
mark_d = 18;
mark_c = [129.15, 29];
with_touch = false;        // 铜箔触摸已取消(改屏幕触摸,下一台 WiFi 设备做)
touch_c = [153, 26];
touch = [70, 34];
foil_pocket = 0.4;
touch_mark_d = 14;

// ---------------------------------------------------------------- 挂在顶面背面的器件(设计者 2026-11-08 定:所有器件都装在一体壳上)
// 内部净高(顶面背面到底板)约 = 5 + 0.176 * y:前沿 ~6mm,后沿 ~27mm → 高的放后面
devkit = [51.5, 28];       // ESP32 DevKit 30 针(设计者实测外形 51.5 x 28,已拆排针)
devkit_c = [130.25, 41.6];  // 第3版:右移 8 与线圈对中;前沿 y≈27.6(前高 6.5 时净高刚够),后沿 55.5 停在线圈方台前 0.6      // 屏幕前方(原铜箔触摸区),横放(长边沿左右);前沿 y≈26 处净高 ≈6.6,够板厚 1.6 + 模组 3.2
devkit_rot = 0;
devkit_holes = [46.5, 23.8]; // 孔距:实测 46.5 x 23;第2次试装 下方孔 +0.8、右侧孔 +0.5(当时按孔距 +0.5 对称加)
// 第3次试装:右侧两柱向左 0.5、左侧不动 → 长向孔距回到 46.5,孔组中心朝左挪 0.25
// "右/左":按设计者看板子那一面(顶面内侧朝自己、线圈在上)理解,右 = 俯视 -y;方向反了把下面改成 -0.25
devkit_shift = 0.25;          // 沿板子长边(板坐标 +x),随板子一起转
devkit_standoff = 0;       // 板子直接贴顶面背面(排针已拆、焊盘面朝顶面)
pin_d = 2.8;               // 屏幕板定位柱(设计者:Ø2.8 x 4,穿过板孔,省去拧螺丝)
devkit_pin_d = 2.5;        // 开发板定位柱:不同批次板子孔位有偏差,2.8 有的装不进,减到 2.5
pin_h = 4;
m25_pilot = 2.1;           // M2.5 自攻底孔
qi_board = [32, 30];       // Qi 控制板(设计者实测 32 x 30;micro USB 凸出板边 2mm,定位框四边中间开口让出)
// 第2版d(设计者:Qi 板必须紧挨线圈):层叠 —— 线圈区局部加厚做成方台,另打一块"线圈压板"用 4 颗 M2 拧在方台上压住磁片,
// 压板背面带 Qi 板定位框,Qi 板叠在线圈正后方;线圈引线从走线槽出来绕过压板边直接焊到板上
cover_size = 54;           // 压板(= 加厚方台)边长,盖住 49.5 的磁片坑
cover_r = 5;
cover_t = 1.5;             // 第5版(设计者):加厚一层打印(1.2→1.5),更结实
cover_hole = 23.5;         // 四角定位柱到中心(面板坐标)
// 设计者:不用螺丝 —— 方台四角出 Ø2.5 定位柱,穿过压板 Ø2.8 孔、多露 1.5,烙铁烫平或点胶锁住
cover_pin_d = 2.5;
cover_pin_hole = 2.8;
cover_pin_out = 1.5;
// 压板四边过线槽:每边 3 道(中间那道正对线圈走线槽),U 形
cover_notch_w = 3.0;
cover_notch_d = 2.5;
cover_notch_pos = [-15, 0, 15];
qi_rot = 90;               // micro USB 朝 +x(右侧壁,离侧壁约 24mm);板子 32 边沿前后
qi_board_c = coil_c;
usbc_board = [21.5, 12];   // USB-C 小板(设计者实测)
usbc_x = W / 2;             // 屏幕板后沿 y≈109 之后,与屏幕不在同一段
usbc_holes = 16;           // 两孔中心距(设计者实测),孔在远离插座的一侧
usbc_hole_edge = 2.5;      // 孔心到【靠外壳(插座)一侧】板边的距离(设计者:孔在靠外壳一侧,受力;具体距离待量)
usbc_recept_out = 1.5;     // 插座凸出板边(设计者实测)
usbc_mount_z = 13;         // 安装平台的水平底面高度(设计者定:接口平行于底板,插线水平,不随顶面倾斜)
usbc_recept = [9.0, 3.2, 7.4];   // Type-C 插座 宽 x 高 x 深
usbc_open = [9.6, 3.8];    // Type-C 开口:插座外壳 8.94 x 3.26,按规范留余量,两端全圆角(设计者:原 13 x 7.5 太大)
usbc_wall_left = 1.5;      // 板边贴着的那一块后墙从内侧挖薄 0.5 到 1.5:插座凸出板边 1.5 → 插座口与外表面齐平,插头能插到底
m2_pilot = 1.7;
fence_h = 3.5;             // 定位框高(垂直于顶面)
fence_w = 1.6;
// ---------------------------------------------------------------- 四角固定(竖直柱,螺丝从底部拧进上盖的柱子)
corner_in = 10.5;
corner_boss_d = 6;
// 底板螺丝统一 M2 x 6 沉头自攻(设计者 2026-11-08 指出原 M3 沉头孔太大:底板减到 1.6mm 后 2.2mm 深的沉头孔直接打穿成 6.2mm 大孔)
screw_clear = 2.4;         // M2 过孔
csk_d = 4.2;               // 90° 沉头孔表面直径(M2 平头 ~3.8):锥深 (4.2-2.4)/2 = 0.9 < 板厚 1.6
corner_pilot = 1.7;        // M2 自攻底孔
foot_d = 21;
foot_depth = 1.0;

corners = [[corner_in, corner_in], [W - corner_in, corner_in],
           [corner_in, D - corner_in], [W - corner_in, D - corner_in]];
vent_slot = [2.4, 22];     // 底板散热长孔


module rr2d(size, r) { offset(r) offset(-r) square(size); }
module rr2d_c(size, r) { translate([-size[0] / 2, -size[1] / 2]) rr2d(size, r); }
module prism(size, r, h0, h1) { translate([0, 0, h0]) linear_extrude(h1 - h0) rr2d(size, r); }

// 面板坐标系:原点在前沿顶面 (0, 0, front_h),u 沿 X,v 沿斜面向后,w 为面板法线(向上)。
// 俯视 y 对应 v = y / cos(angle)。
module panel_frame() { translate([0, 0, front_h]) rotate([angle, 0, 0]) children(); }
function pv(y) = y / cos(angle);

// 在面板上、以面板法线方向切/长的特征:p = 俯视坐标,w0..w1 = 法线方向范围(顶面 w = 0)
module on_panel(p, w0 = 0) { panel_frame() translate([p[0], pv(p[1]), w0]) children(); }

// 顶面以下的竖直空间
module under_top(extra = 0) {
    // 竖直棱柱 ∩ 顶面以下:用一块很大的倾斜半空间
    panel_frame() translate([-50, -50, -200 - extra]) cube([W + 100, D + 200, 200]);
}

// ================================================================= 一体壳(顶面 + 四面侧壁)
// 设计者 2026-11-08 定:上盖和边框一体,底部用嵌入式底板 —— 顶面和侧面没有任何接缝,唯一的缝在底面(朝桌面)。
// 打印:顶面朝下贴热床(纹理 PEI 面),侧壁往上长;内部所有凸台/台阶都按 45° 处理,不需要支撑。
chamfer = 1.0;    // 第3版(设计者):3 → 1 —— 顶面朝下打,倒角每层都外悬,3mm 占约 11 层、个别层粘不牢;1mm 只剩约 4 层
inner_fillet = 2.0;
bottom_chamfer = 0.8;   // 底边小倒角,去掉锋利的直角边           // 顶面外缘 45° 倒角(顶面朝下打印,圆角的最下几层几乎水平悬空会毛糙,倒角干净)
plate_t = 1.6;           // 底板厚
plate_recess = 0.5;      // 底板比侧壁底缘缩进,侧面看不到底板的边
plate_gap = 0.25;        // 底板与侧壁内侧每边间隙
ledge_w = 1.8;           // 侧壁内侧托住底板的台阶(三角截面,45°)
floor_t = plate_recess + plate_t;   // 底板顶面高度(器件都从这里算)

cyd_hole_pts = [for (sx = [-1, 1], sy = [-1, 1]) [cyd_c[0] + cyd_hole_shift[0] + sx * cyd_holes[0] / 2, cyd_c[1] + cyd_hole_shift[1] + sy * cyd_holes[1] / 2]];
cyd_boss_len = bezel_t + glass_stack - lid_t;   // 玻璃退进 bezel_t → 支撑台加高同样多

module inner2d(extra = 0) { translate([wall_t + extra, wall_t + extra]) rr2d([W - 2 * (wall_t + extra), D - 2 * (wall_t + extra)], R - wall_t - extra); }

// ---- 挂在顶面背面的器件安装位(全部垂直于顶面:一体壳顶面朝下打印时都是竖直往上长,不要支撑)
function rot2(v, a) = [v[0] * cos(a) - v[1] * sin(a), v[0] * sin(a) + v[1] * cos(a)];
// 安装孔:俯视坐标(开发板竖放,先在板坐标里算再转 devkit_rot)
devkit_hole_pts = [for (sx = [-1, 1], sy = [-1, 1])
    let(r = rot2([sx * devkit_holes[0] / 2 + devkit_shift, sy * devkit_holes[1] / 2], devkit_rot))
    [devkit_c[0] + r[0], devkit_c[1] + r[1] * cos(angle)]];
// 板边顶在后墙挖薄后的内壁上,插座(凸出 1.5)穿过 1.5 厚的墙,口与外表面齐平
usbc_stop_gap = 0.8;          // 挡块与板边间隙(第4次试装:再往内 0.5,0.3→0.8)
usbc_inset = 1.0;             // 第3次试装:挡块离出口太近、板放不进,整块板(连挡块、螺丝孔)往内 1mm;插座口会比外表面缩进 1mm
usbc_c_y = D - usbc_wall_left - usbc_inset - usbc_board[1] / 2;
usbc_hole_pts = [for (sx = [-1, 1]) [usbc_x + sx * usbc_holes / 2, usbc_c_y + (usbc_board[1] / 2 - usbc_hole_edge)]];
usbc_axis_z = usbc_mount_z - 1.6 - usbc_recept[1] / 2;     // 板子挂在平台底面、插座朝下:插座中心高度

// 定位框:-y 那条 32mm 边(micro USB 一侧)中间 1/3 开口、整条边往内 qi_usb_in;
// 其余三边各开 qi_slot_n 个走线口(第3次试装设计者要求:四周断续,方便进出线)
qi_usb_in = 1.0;
qi_slot_n = 4;
qi_slot_w = 2.5;
module fence(c, size, h, w0 = -lid_t, rot = 0) {
    lo = -size[1] / 2 - 0.4 + qi_usb_in;          // -y 边内侧面
    on_panel(c, w0 - h) rotate([0, 0, rot]) difference() {
        linear_extrude(h + eps) rr2d_c([size[0] + 2 * (fence_w + 0.4), size[1] + 2 * (fence_w + 0.4)], 1);
        translate([-size[0] / 2 - 0.4, lo, -eps]) linear_extrude(h + 1) square([size[0] + 0.8, size[1] / 2 + 0.4 - lo]);
        translate([-size[0] / 2 - fence_w - 2, -size[1] / 2 - fence_w - 2, -1]) cube([size[0] + 2 * fence_w + 4, 2 + qi_usb_in - 0.4, h + 2]);   // -y 边往内挪:外侧多余部分切掉
        translate([-size[0] / 6, lo - fence_w - 2, -1]) cube([size[0] / 3, fence_w + 3, h + 2]);
        for (i = [0 : qi_slot_n - 1]) {
            u = (i + 0.5) / qi_slot_n - 0.5;
            translate([u * size[0] - qi_slot_w / 2, size[1] / 2 - 1, -1]) cube([qi_slot_w, fence_w + 3, h + 2]);              // +y 边
            for (sx = [-1, 1]) translate([sx * (size[0] / 2 + fence_w / 2 + 0.4), u * size[1], h / 2]) cube([fence_w + 3, qi_slot_w, h + 2], center = true);   // ±x 边
        }
    }
}

module ceiling_mounts() {
    // 开发板:4 根 M2.5 柱
    for (q = devkit_hole_pts) on_panel(q, -lid_t - pin_h) cylinder(d = devkit_pin_d, h = pin_h + eps);
    // USB-C 安装平台:从顶面背面长下来、贴着后墙,底面水平;小板挂在底面(插座朝下、口朝后墙)
    intersection() {
        translate([usbc_x - usbc_board[0] / 2 - 3, usbc_c_y - usbc_board[1] / 2 - 3, usbc_mount_z])
            cube([usbc_board[0] + 6, D, back_h]);
        under_top(lid_t - eps);
        translate([0, 0, -1]) linear_extrude(back_h + 10) inner2d(-eps);
    }
    // 板前挡块:承受插头往里推的力
    translate([usbc_x - usbc_board[0] / 2, usbc_c_y - usbc_board[1] / 2 - usbc_stop_gap - 2, usbc_mount_z - 1.6 - 0.8])
        cube([usbc_board[0], 2, 1.6 + 0.8 + eps]);
}

// 外形:竖直棱柱 ∩ 顶面以下 ∩ 顶缘倒角(在面板坐标里做一个"上小下大"的台体)
module body() {
    // 侧壁一律竖直(垂直于底板)。倒角只做在顶面边缘那一圈:
    // v3 曾用一个垂直于顶面的台体切外形,结果前壁被切成向里倾斜约 7°(设计者发现)。
    intersection() {
        hull() {    // 竖直侧壁 + 底边小倒角
            linear_extrude(eps) offset(-bottom_chamfer) rr2d([W, D], R);
            translate([0, 0, bottom_chamfer]) linear_extrude(back_h + 5) rr2d([W, D], R);
        }
        under_top();
        union() {
            panel_frame() hull() {
                translate([0, 0, -eps]) linear_extrude(eps) offset(-chamfer) scale([1, 1 / cos(angle)]) rr2d([W, D], R);
                // 第11版修正:原来是 offset(5) @ -chamfer → 坡度 1:6,倒角只有 1 宽 × 0.17 深(几乎平,首层 0.32 时完全被吞);改成真正 45°
                translate([0, 0, -chamfer - 5]) linear_extrude(eps) offset(5) scale([1, 1 / cos(angle)]) rr2d([W, D], R);
            }
            under_top(chamfer - eps);
        }
    }
}

// 第9版(设计者):左右两条短边取下后放凉略往里凹 → 两侧内部加"梯形"加强筋:
// 离内壁 rib_off 一条纵筋 + 每 rib_pitch 一道横筋连回侧壁,和侧壁组成盒形截面;筋垂直于顶面往下长 rib_h,不碰底板
rib_on = false;            // 第9版误判(设计者:翘的是前沿长边,不是两侧)→ 关掉,改用 front_ribs
rib_w = 1.6;
rib_h = 3.0;               // 顶面内侧往下(与屏幕支撑台同高,屏幕板正好在它下面)
rib_off = 5.0;             // 纵筋中心离侧壁内侧
rib_pitch = 12;
rib_y = [12, D - 12];      // 两端停在四角圆弧处
rib_skip = [[[56, 110]],   // 左:屏幕 PCB 边离侧壁只有 1.6,这段不放(开窗围框已经是一道筋)
            []];           // 右:整条贯通(设计者:Qi 板 micro USB 不用,线直接焊在板上)
function rib_free(side, y) = len([for (r = rib_skip[side]) if (y > r[0] - 0.01 && y < r[1] + 0.01) 1]) == 0;
module side_ribs2d(side) {
    xw = side == 0 ? wall_t : W - wall_t;           // 内壁
    sx = side == 0 ? 1 : -1;
    xr = xw + sx * rib_off;
    segs = [for (i = [0 : len(rib_skip[side])]) [i == 0 ? rib_y[0] : rib_skip[side][i - 1][1], i == len(rib_skip[side]) ? rib_y[1] : rib_skip[side][i][0]]];
    for (g = segs) if (g[1] - g[0] > rib_w) {
        translate([xr - rib_w / 2, g[0]]) square([rib_w, g[1] - g[0]]);
        n = max(1, round((g[1] - g[0]) / rib_pitch));
        for (k = [0 : n]) let(y = g[0] + (g[1] - g[0]) * k / n - rib_w / 2 + (k == 0 ? rib_w / 2 : k == n ? -rib_w / 2 : 0))
            translate([min(xw - sx * 0.5, xr), y]) square([abs(xr - xw) + 0.5, rib_w]);
    }
}
module side_ribs() {
    intersection() {
        panel_frame() translate([0, 0, -lid_t - rib_h]) linear_extrude(rib_h + eps) scale([1, 1 / cos(angle)])
            for (side = [0, 1]) side_ribs2d(side);
        translate([0, 0, floor_t + ledge_w + 0.3]) linear_extrude(back_h + 10) inner2d(-0.6);   // 不碰底板和托底板台阶
    }
}

// 第9版(设计者):前沿那条长边(高 6.7、长 170)取下放凉后,从正面看中间往里凹。
// 前墙只和顶面组成 L 形截面,太软 → 内侧加一条平行于前墙的纵筋(两端接到前面两个角柱),
// 每 front_rib_pitch 一道横筋连回前墙,组成盒形截面。筋竖直往下长到底板上方 0.3。
front_rib_on = true;
// 第9b版(设计者:再多加几道):两道纵筋 + 交错横筋(桁架),纵筋左右贯通接到两侧墙;后一道再用短筋接到文字加强垫
front_rib_ys = [wall_t + 6.5, wall_t + 14];   // y 8.5 / 16:文字加强垫从 y19、ESP32 从 y27.6 开始
front_rib_w = 1.6;
front_rib_pitch = 8;
front_rib_x = [wall_t - 0.5, W - wall_t + 0.5];
module front_ribs2d() {
    for (y = front_rib_ys) translate([front_rib_x[0], y - front_rib_w / 2]) square([front_rib_x[1] - front_rib_x[0], front_rib_w]);
    ys = concat([wall_t - 0.5], front_rib_ys);
    for (r = [0 : len(front_rib_ys) - 1]) {
        off = r % 2 == 0 ? 0 : front_rib_pitch / 2;       // 两排横筋错开半格
        for (x = [12 + off : front_rib_pitch : W - 12]) translate([x - front_rib_w / 2, ys[r]]) square([front_rib_w, ys[r + 1] - ys[r]]);
    }
    // 后一道纵筋 → 文字加强垫前沿
    pad_y0 = logo_c[1] - text_pad[1] / 2;
    for (x = [logo_c[0] - text_pad[0] / 2 + 4 : front_rib_pitch : logo_c[0] + text_pad[0] / 2 - 4])
        translate([x - front_rib_w / 2, front_rib_ys[1]]) square([front_rib_w, pad_y0 - front_rib_ys[1] + 1]);
}
module front_ribs() {
    intersection() {
        translate([0, 0, floor_t + 0.3]) linear_extrude(back_h) front_ribs2d();
        under_top(lid_t - eps);
        union() {    // 托底板台阶那一圈(离内壁 ledge_w 内)要让开台阶
            translate([0, 0, floor_t + 0.3]) linear_extrude(back_h) inner2d(ledge_w);
            translate([0, 0, floor_t + ledge_w]) linear_extrude(back_h) inner2d(-0.6);
        }
    }
}

module shell(with_corner_bosses = true) {
    difference() {
        union() {
            difference() {
                body();
                // 内腔:侧壁内侧 ∩ 顶面往下一个壳厚
                intersection() { translate([0, 0, -1]) linear_extrude(back_h + 10) inner2d(); under_top(lid_t); }
            }
            // 托底板的台阶:三角截面,底面在 floor_t,往上 45° 收回侧壁
            difference() {
                translate([0, 0, floor_t]) linear_extrude(ledge_w) inner2d();
                hull() {
                    translate([0, 0, floor_t - eps]) linear_extrude(eps) inner2d(ledge_w);
                    translate([0, 0, floor_t + ledge_w]) linear_extrude(eps) inner2d(0);
                }
            }
            // 四角竖直柱:底面在底板顶面,螺丝从底板拧上来
            if (with_corner_bosses) for (p = corners) intersection() {
                translate([p[0], p[1], floor_t]) cylinder(d = corner_boss_d, h = back_h);
                under_top();
            }
            // 屏幕板:支撑台 + Ø2.8 x 4 定位柱(和开发板一样不拧螺丝)
            if (cyd_boss_len > 0.2)
                for (p = cyd_hole_pts) on_panel(p, -lid_t - cyd_boss_len) cylinder(d = cyd_boss_d, h = cyd_boss_len + eps);
            if (!cyd_screw) for (p = cyd_hole_pts) on_panel(p, -lid_t - cyd_boss_len - cyd_pin_h) {
                translate([0, 0, pin_d / 2]) cylinder(d = pin_d, h = cyd_pin_h - pin_d / 2 + eps);
                translate([0, 0, pin_d / 2]) sphere(d = pin_d, $fn = 48);              /* 半球圆帽:卡件一放就对正 */
                translate([0, 0, cyd_pin_h - 1.6]) cylinder(d = cyd_pin_root_d, h = 1.6 + eps);   /* 穿板段加粗 */
            }
            // 开窗四周加强围框(高度同支撑台):长边整条;短边中间留空给排线
            on_panel(cyd_c, -lid_t - cyd_boss_len) difference() {
                linear_extrude(cyd_boss_len + eps) square([glass[0] + 2 * glass_clear + 2 * win_rib_w, glass[1] + 2 * glass_clear + 2 * win_rib_w], center = true);
                translate([0, 0, -1]) linear_extrude(cyd_boss_len + 2) square([glass[0] + 2 * glass_clear, glass[1] + 2 * glass_clear], center = true);
                if (win_rib_gap > 0) translate([0, 0, -1]) linear_extrude(cyd_boss_len + 2) square([glass[0] + 20, win_rib_gap], center = true);
            }
            // 线圈区局部加厚到 coil_local_t + 四段包裹圆弧
            on_panel(coil_c, -coil_local_t) linear_extrude(coil_local_t - lid_t + eps) rr2d_c([cover_size, cover_size], cover_r);   // 方台,压板贴在它底面
            for (sx = [-1, 1], sy = [-1, 1]) on_panel(coil_c, -coil_local_t - cover_t - cover_pin_out) translate([sx * cover_hole, sy * cover_hole, 0]) cylinder(d = cover_pin_d, h = cover_t + cover_pin_out + eps);
            if (coil_arc_h > 0) on_panel(coil_c, -coil_local_t - coil_arc_h) difference() {
                cylinder(r = coil_d / 2 + coil_fit / 2 + coil_arc_w, h = coil_arc_h + eps);
                translate([0, 0, -1]) cylinder(r = coil_d / 2 + coil_fit / 2, h = coil_arc_h + 2);
                for (a = [0, 90]) rotate([0, 0, a]) translate([0, 0, coil_arc_h / 2]) cube([coil_d + 20, coil_lead_w + 2, coil_arc_h + 2], center = true);
            }
            ceiling_mounts();
            if (rib_on) side_ribs();
            if (front_rib_on) front_ribs();
            // 文字凹槽下方的加强垫(槽深 2.0 > 顶面厚的一半)
            if (text_pad[2] > 0) on_panel(logo_c, -lid_t - text_pad[2]) linear_extrude(text_pad[2] + eps) rr2d_c([text_pad[0], text_pad[1]], 2);
            // 顶面与侧壁内侧交角补 45° 加强角:外面倒角加大后,转角处仍留够壁厚
            intersection() {
                panel_frame() difference() {
                    hull() {
                        translate([0, 0, -lid_t]) linear_extrude(eps) scale([1, 1 / cos(angle)]) inner2d(-1);
                        translate([0, 0, -lid_t - inner_fillet]) linear_extrude(eps) scale([1, 1 / cos(angle)]) inner2d(-1);
                    }
                    hull() {
                        translate([0, 0, -lid_t + eps]) linear_extrude(eps) scale([1, 1 / cos(angle)]) inner2d(inner_fillet);
                        translate([0, 0, -lid_t - inner_fillet - eps]) linear_extrude(eps) scale([1, 1 / cos(angle)]) inner2d(0);
                    }
                }
                body();
            }
        }
        // 屏幕开窗:顶面 0~bezel_t 只开发光区(外缘斜角),bezel_t 以下是玻璃槽(玻璃顶住边框)
        on_panel(cyd_c, 0) {
            ax0 = -glass[0] / 2 + bezel_side[0]; ax1 = glass[0] / 2 - bezel_side[1];
            ay0 = -glass[1] / 2 + bezel_side[2]; ay1 = glass[1] / 2 - bezel_side[3];
            // 第11版修正:原来斜面建反了(表面 0.5 深是竖直扩大的口,斜面在内侧 0.5~0.8 深,看不见、打印时还是 >45° 的内悬)
            // 改为:表面开口每边大 bezel_chamfer,45° 收到 bezel_chamfer 深处回到发光区尺寸,以下竖直
            translate([ax0, ay0, -bezel_t - eps]) cube([ax1 - ax0, ay1 - ay0, bezel_t + 1]);
            hull() {
                translate([ax0, ay0, -bezel_chamfer]) cube([ax1 - ax0, ay1 - ay0, eps]);
                translate([ax0 - bezel_chamfer, ay0 - bezel_chamfer, 0]) cube([ax1 - ax0 + 2 * bezel_chamfer, ay1 - ay0 + 2 * bezel_chamfer, 1]);
            }
        }
        on_panel(cyd_c, -lid_t - 2) linear_extrude(lid_t + 2 - bezel_t) {
            square([glass[0] + 2 * glass_clear, glass[1] + 2 * glass_clear], center = true);   // 直角,不倒圆
            // 四角:四条边各自直着延长 win_relief,交叉成真正的直角(打印头不用在角上转弯)
            if (win_relief > 0) for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx * (glass[0] / 2 + glass_clear) - (sx > 0 ? 0 : win_relief), sy * (glass[1] / 2 + glass_clear) - win_relief_w / 2]) square([win_relief, win_relief_w]);
                translate([sx * (glass[0] / 2 + glass_clear) - win_relief_w / 2, sy * (glass[1] / 2 + glass_clear) - (sy > 0 ? 0 : win_relief)]) square([win_relief_w, win_relief]);
            }
        }
        // 线圈:磁片坑(49.5,深 1)→ 线圈坑(44,深 1)→ 覆盖层 0.5;台阶上四条走线槽(深同线圈坑),穿过包裹圆弧的缺口
        on_panel(coil_c, -coil_local_t - coil_arc_h - eps) cylinder(d = coil_d + coil_fit, h = coil_arc_h + coil_ferrite_h + eps);
        on_panel(coil_c, -coil_local_t + coil_ferrite_h - eps) cylinder(d = coil_wire_d + coil_fit, h = coil_wire_h + eps);
        // 走线槽比线圈坑深 0.3(距外表面 0.8~1.8):磁吸贴凹槽(0~0.5)从上面跨过,中间留 0.3,不会漏缝
        for (a = [0, 90]) on_panel(coil_c, -coil_local_t + coil_ferrite_h - lead_drop - eps) rotate([0, 0, a])
            translate([0, 0, coil_wire_h / 2]) cube([coil_d + 2 * coil_arc_w + 6, coil_lead_w, coil_wire_h + 2 * eps], center = true);
        // 铜箔凹位
        if (with_touch) on_panel(touch_c, -lid_t - eps) linear_extrude(foil_pocket + eps) rr2d_c(touch, 3);
        // 顶面刻线:磁吸贴对位圆槽 + 触摸点
        for (i = [0 : mag_slit_n - 1]) on_panel(coil_c, -coil_skin - eps) rotate([0, 0, (i + 0.5) * 360 / mag_slit_n])
            translate([(mag_id - mag_fit) / 2 - 0.2, -mag_slit_w / 2, 0]) cube([(mag_od - mag_id + 2 * mag_fit) / 2 + 0.4, mag_slit_w, coil_skin - mag_t + 2 * eps]);
        on_panel(coil_c, -mag_t) difference() {
            cylinder(d = mag_od + mag_fit, h = mag_t + 1);
            translate([0, 0, -1]) cylinder(d = mag_id - mag_fit, h = mag_t + 3);
            for (i = [0 : mag_tab_n - 1]) rotate([0, 0, (i + 0.5) * 360 / mag_tab_n]) translate([mag_od / 2, 0, 0]) cube([mag_od / 2, mag_tab_w, 2 * mag_t + 4], center = true);
        }
        on_panel(mark_c, -mark_depth) linear_extrude(mark_depth + 1) logo_mark(mark_d);
        on_panel(logo_c, -logo_depth) linear_extrude(logo_depth + 1) logo_text2d();
        if (with_touch) on_panel(touch_c, -engrave) difference() { cylinder(d = touch_mark_d, h = engrave + 1); translate([0, 0, -1]) cylinder(d = touch_mark_d - 3, h = engrave + 3); }
        // 后墙 USB-C 开口(水平)+ 开口周围从内侧挖薄
        translate([usbc_x, D - wall_t - 1, usbc_axis_z]) rotate([-90, 0, 0]) linear_extrude(wall_t + 2) rr2d_c(usbc_open, usbc_open[1] / 2 - 0.01);
        // 板子那一段后墙从内侧挖薄(板宽 + 1,板厚方向上下各留 1mm)
        translate([usbc_x - usbc_board[0] / 2 - 0.5, D - wall_t - 1, usbc_mount_z - 1.6 - usbc_recept[1] - 1])
            cube([usbc_board[0] + 1, 1 + wall_t - usbc_wall_left, 1.6 + usbc_recept[1] + 2]);
        // 屏幕板 M3 自攻底孔:穿过支撑台进顶面,离外表面留 0.8
        if (cyd_screw) for (p = cyd_hole_pts) on_panel(p, -lid_t - cyd_boss_len - eps) cylinder(d = pilot_d, h = lid_t + cyd_boss_len - 0.8);
        // 器件安装柱的底孔
        for (q = usbc_hole_pts) translate([q[0], q[1], usbc_mount_z - eps]) cylinder(d = m2_pilot, h = top_z(q[1]) - 0.8 / cos(angle) - usbc_mount_z);   // 离顶面留 0.8,不打穿
        // 螺丝底孔:四角竖直孔,离顶面留 0.8
        for (p = corners) translate([p[0], p[1], floor_t - eps]) cylinder(d = corner_pilot, h = top_z(p[1]) - floor_t - 0.8 / cos(angle));
    }
}

// ================================================================= 底板:带散热孔的平板(器件全在一体壳上)
module plate() {
    difference() {
        translate([0, 0, plate_recess]) linear_extrude(plate_t) inner2d(plate_gap);
        // 四角螺丝:M2 过孔 + 90° 锥形沉头(螺丝头与底面齐平,毛毡脚垫贴在上面)
        for (p = corners) translate([p[0], p[1], plate_recess - eps]) {
            cylinder(d = screw_clear, h = plate_t + 1);
            cylinder(d1 = csk_d, d2 = screw_clear, h = (csk_d - screw_clear) / 2);
        }
        // 散热长孔:中间大片区域,避开四角脚垫
        for (x = [40 : 6 : W - 40], y = [22, 52, 82, 108])
            translate([x, y, plate_recess - 1]) linear_extrude(plate_t + 2) rr2d_c(vent_slot, vent_slot[0] / 2 - 0.01);
    }
}

// ================================================================= 第2版底板(设计者 2026-11-11):散热孔看不进去 + 加强筋
// 斜孔百叶:每条孔 45° 斜穿板厚,下口与上口在 y 方向错开 plate_t(1.6) > 孔宽(1.0),正看看不到内部,空气照样通。
// 加强筋长在朝内一面,先画整齐网格,再自动扣掉上方被外壳/器件占用的区域(前沿那一条外壳筋离底板只有 0.3)。
pv_w = 1.0;             // 斜孔宽(水平方向)
pv_pitch = 4.0;         // 孔排距(y)
pv_len = 18;            // 每段孔长(x),段间留 4 连接
pv_gap = 4;
prib_h = 2.0;           // 筋高(底板顶面往上)
prib_w = 1.6;
prib_x = [34, 62, 90, 118, 146];   // 纵筋(沿 y)
prib_y = [26, 56, 86, 114];        // 横筋(沿 x)
prib_clear = 0.6;       // 筋顶到上方结构的最小间隙 / 水平避让
prib_front = 20;        // 前沿 y<20 不放筋
module plate_rib_grid2d() {
    for (x = prib_x) translate([x - prib_w / 2, 0]) square([prib_w, D]);
    for (y = prib_y) translate([0, y - prib_w / 2]) square([W, prib_w]);
    for (p = corners) translate(p) circle(d = corner_boss_d + 3);   // 脚柱周围加厚一圈
}
module plate_occupied2d() {   // 底板顶面以上 prib_h+间隙 内被占用的投影
    offset(r = prib_clear) projection() intersection() {
        union() { shell(); m_cyd_pcb(); m_cyd_back(); m_devkit(); m_qi(); m_usbc(); coil_cover(); }
        translate([-1, -1, floor_t + 0.01]) cube([W + 2, D + 2, prib_h + prib_clear]);
    }
}
module plate_vent_field2d() {
    difference() {
        inner2d(7);
        for (p = corners) translate(p) circle(r = 9);
        offset(r = 1.4) plate_rib_grid2d();
    }
}
module plate2() {
    difference() {
        union() {
            translate([0, 0, plate_recess]) linear_extrude(plate_t) inner2d(plate_gap);
            // 加强筋:网格 ∩ 板内(让开侧壁托底台阶) − 上方占用区
            translate([0, 0, floor_t - eps]) linear_extrude(prib_h + eps) difference() {
                intersection() {
                    plate_rib_grid2d(); inner2d(ledge_w + 0.6);
                    translate([0, prib_front]) square([W, D]);   // 前沿那一条上方是外壳前沿筋(离底板 0.3),不放
                }
                plate_occupied2d();
            }
        }
        for (p = corners) translate([p[0], p[1], plate_recess - eps]) {
            cylinder(d = screw_clear, h = plate_t + prib_h + 1);
            cylinder(d1 = csk_d, d2 = screw_clear, h = (csk_d - screw_clear) / 2);
        }
        // 斜孔百叶:沿 x 的长孔,截面是 45° 平行四边形(底口 y0~y0+w,顶口再往 +y 移 plate_t)
        intersection() {
            translate([0, 0, plate_recess - 0.5]) linear_extrude(plate_t + 1) plate_vent_field2d();
            for (y0 = [0 : pv_pitch : D], x0 = [0 : pv_len + pv_gap : W])
                translate([x0, y0, plate_recess])
                    multmatrix([[1, 0, 0, 0], [0, 1, 1, 0], [0, 0, 1, 0]])   // y += z:45° 斜穿
                        translate([0, -0.5, -0.5]) cube([pv_len, pv_w, plate_t + 1]);
        }
    }
}

// ================================================================= 装配测试件:屏幕开窗 + 安装柱,线圈凹位 + 对位圆槽
module logo_text2d() {
    resize([logo_w, 0], auto = true) text(logo_text, font = logo_font, halign = "center", valign = "center", spacing = logo_spacing);
}
// 白色 TPU 嵌件:外露面朝下打(贴纹理板,和外壳顶面同纹理)→ 左右镜像,翻过来正好塞进去
module inlays() {
    mirror([1, 0, 0]) {
        linear_extrude(logo_depth) offset(delta = -inlay_fit) logo_text2d();
        translate([-logo_w / 2 - mark_d / 2 - 6, 0, 0]) linear_extrude(mark_depth) offset(delta = -inlay_fit) logo_mark(mark_d);
    }
}

// 预览用:嵌件装在凹槽里的样子
module inlays_in_place() {
    on_panel(logo_c, -logo_depth) linear_extrude(logo_depth) offset(delta = -inlay_fit) logo_text2d();
    on_panel(mark_c, -mark_depth) linear_extrude(mark_depth) offset(delta = -inlay_fit) logo_mark(mark_d);
}

// 字厚试样:四套 AUTOPHONE(①1.0 沉 1.0 / ②1.6 沉 0.4 / ③2.0 齐平 / ④2.6 凸 0.6)+ 一套 logo(1.2 齐平),
// 设计者在实物上比较效果;镜像、外露面朝下打
inlay_heights = [1.0, 1.6, 2.0, 2.6];
module inlays_test() {
    mirror([1, 0, 0]) {
        for (i = [0 : 3]) translate([0, -i * 13, 0])
            linear_extrude(inlay_heights[i]) offset(delta = -inlay_fit) logo_text2d();
        translate([-logo_w / 2 - mark_d / 2 - 6, -20, 0]) linear_extrude(mark_depth) offset(delta = -inlay_fit) logo_mark(mark_d);
    }
}

// 第二轮嵌件(设计者:只有最薄的字能用;logo 太厚要减半;声波小圆弧装不进;TPU 拉丝严重):
// 文字 1.0 一套 + logo 0.6 两套(每边 -0.12 / -0.2,挑装得进又不松的)
module inlays_v2() {
    mirror([1, 0, 0]) {
        linear_extrude(1.0) offset(delta = -inlay_fit) logo_text2d();
        for (j = [0 : 1]) translate([-logo_w / 2 - mark_d / 2 - 6 - j * (mark_d + 6), -14, 0])
            linear_extrude(0.6) offset(delta = -[0.12, 0.2][j]) logo_mark(mark_d);
    }
}

// logo 共打(设计者提议):先在床上打一层白色 logo、不取下,换黑料再打外壳,白 logo 熔进顶面(免胶免公差)。
// 外壳的 logo 凹槽 = 正好一层(-D mark_depth=0.24);试样 = logo 那一小块顶面 + 同位置的一层白 logo
module logo_fit() {
    intersection() {
        shell(with_corner_bosses = false);
        on_panel(mark_c, -6) translate([-mark_d / 2 - 6, -mark_d / 2 - 6, 0]) cube([mark_d + 12, mark_d + 12, 7]);
    }
}
tile_a = 26; tile_t = 2.4;      // 试片边长 / 厚
module logo_tile_2d(k) {            // k: 1 白(圆环+听筒) 2 橙(内弧) 3 绿(外弧)
    mirror([1, 0]) if (k == 1) logo_white_part(mark_d); else logo_arc_part(mark_d, outer = k == 3);
}
module logo_tile(k) {
    if (k == 0) difference() {
        translate([-tile_a / 2, -tile_a / 2, 0]) cube([tile_a, tile_a, tile_t]);
        translate([0, 0, -0.01]) linear_extrude(mark_depth + 0.01) mirror([1, 0]) logo_mark(mark_d);
    } else linear_extrude(mark_depth) logo_tile_2d(k);
}
module logo_white() { on_panel(mark_c, -mark_depth) linear_extrude(mark_depth) logo_mark(mark_d); }
// 第10版(设计者):文字也用白色共打,和 logo 一样 —— 打印时 -D mark_depth=0.32 -D logo_depth=0.32,黑壳第一层也是 0.32,喷嘴齐平走过
white_shrink = 0.05;        // 第10版实测:A 的三角孔(1.45×2.5)被首层糊住 → 白字每边收 0.05,缝由黑色首层压扁填满
module text_white() { on_panel(logo_c, -logo_depth) linear_extrude(logo_depth) offset(delta = -white_shrink) logo_text2d(); }

// 屏幕板卡件:开口筒,套到定位柱上压住屏幕板(6 个,多 2 个备用);打印时竖放
module cyd_clip() {
    difference() {
        cylinder(d = clip_od, h = clip_len);
        translate([0, 0, -1]) cylinder(d = clip_id, h = clip_len + 2);
        translate([0, 0, clip_len - 0.8]) cylinder(d1 = clip_id, d2 = clip_id + 1.6, h = 0.8 + eps);   /* 入口倒角 */
        translate([0, -clip_slit / 2, -1]) cube([clip_od, clip_slit, clip_len + 2]);
    }
}
module clips() { for (i = [0 : clip_n - 1]) translate([(i % clip_cols) * 10, floor(i / clip_cols) * 10, 0]) cyd_clip(); }
// 第8版实测:卡件放在床角、单个太小粘不牢飞了 → 首层连体裙边:每个卡件外圈一层 4mm 宽的环,环之间 2mm 细条连成一片
// (只贴卡件外壁,不在卡件底下,像普通裙边一样撕掉)
module clips_brim() {
    clips();
    linear_extrude(0.24) difference() {
        for (i = [0 : clip_n - 1]) translate([(i % clip_cols) * 10, floor(i / clip_cols) * 10]) circle(d = clip_od + 8);   // 环直径 14 > 间距 10,相邻自然连成一片
        for (i = [0 : clip_n - 1]) translate([(i % clip_cols) * 10, floor(i / clip_cols) * 10]) circle(d = clip_od - 0.01);
    }
}

// 屏幕区试装件:开窗边框 + 玻璃槽 + 支撑台 + 定位柱
module screen_fit() {
    intersection() {
        shell(with_corner_bosses = false);
        on_panel(cyd_c, -14) translate([-50, -32, 0]) cube([100, 64, 15]);
    }
}

// 文字 + logo 嵌件试装件:两块顶面(含加强垫),用来试白色 TPU 嵌件的松紧
module text_fit() {
    intersection() {
        shell(with_corner_bosses = false);
        union() {
            on_panel(logo_c, -6) translate([-logo_w / 2 - 6, -text_pad[1] / 2 - 3, 0]) cube([logo_w + 12, text_pad[1] + 6, 7]);
            on_panel(mark_c, -6) translate([-mark_d / 2 - 5, -mark_d / 2 - 5, 0]) cube([mark_d + 10, mark_d + 10, 7]);
        }
    }
}

module fit() {
    intersection() {
        shell(with_corner_bosses = false);
        union() {
            // 屏幕:开窗外一圈 8mm 边框 + 4 根安装柱;线圈:直径 64 的圆片(含凹位与对位圆槽)。
            // 只截面板、内沿和安装柱(法线方向 9mm):截太深会把斜穿过来的竖直角柱截成悬空碎块
            on_panel(cyd_c, -9) translate([-48, -30, 0]) cube([96, 60, 10]);
            on_panel(coil_c, -9) translate([-cover_size / 2 - 4, -cover_size / 2 - 4, 0]) cube([cover_size + 8, cover_size + 8, 10]);
            on_panel(devkit_c, -9) rotate([0, 0, devkit_rot]) translate([-devkit[0] / 2 - 4, -devkit[1] / 2 - 4, 0]) cube([devkit[0] + 8, devkit[1] + 8, 10]);
            // USB-C 安装平台 + 那一段后墙(含水平开口)
            translate([usbc_x - usbc_board[0] / 2 - 5, usbc_c_y - usbc_board[1] / 2 - 6, -1]) cube([usbc_board[0] + 10, D, back_h + 5]);
        }
    }
}


// ================================================================= 器件示意(只用于 3D 预览,不打印)
phone = [74.7, 156.2, 5.64];   // iPhone Air
glass_t = 1.6;                 // 玻璃 + 触摸层(示意)
coil_t = 3.0;

module m_phone()  { on_panel(coil_c, 0.4) linear_extrude(phone[2]) rr2d_c([phone[0], phone[1]], 10); }
module m_glass()  { on_panel(cyd_c, -bezel_t - glass_t) linear_extrude(glass_t) rr2d_c(glass, 0.5); }
module m_display(){ on_panel(cyd_c, -bezel_t - glass_stack) linear_extrude(glass_stack - glass_t) rr2d_c([glass[0] - 1, glass[1] - 1], 0.5); }
module m_cyd_pcb(){ on_panel([cyd_c[0] + cyd_hole_shift[0], cyd_c[1] + cyd_hole_shift[1]], -bezel_t - glass_stack - 1.6) difference() {
                        linear_extrude(1.6) rr2d_c(cyd_pcb, 1);
                        for (sx = [-1, 1], sy = [-1, 1]) translate([sx * cyd_holes[0] / 2, sy * cyd_holes[1] / 2, -1]) cylinder(d = 3.2, h = 4);
                    } }
module m_cyd_back(){ on_panel([cyd_c[0] + cyd_hole_shift[0], cyd_c[1] + cyd_hole_shift[1]], -bezel_t - glass_stack - 1.6 - 3.5) linear_extrude(3.5) rr2d_c([cyd_pcb[0] - 8, cyd_pcb[1] - 4], 1); }
module m_coil()   { on_panel(coil_c, -coil_local_t) {                       // 磁片在下(朝内),线圈朝面板
                        cylinder(d = coil_d - 0.2, h = coil_ferrite_h);
                        translate([0, 0, coil_ferrite_h]) difference() { cylinder(d = coil_wire_d - 0.2, h = coil_wire_h - 0.05); translate([0, 0, -1]) cylinder(d = 10, h = 3); }
                    } }
module m_devkit() { on_panel(devkit_c, -lid_t - 1.6) rotate([0, 0, devkit_rot]) {   // 拆掉排针的平板,模组朝下
                        difference() {
                            translate([-devkit[0] / 2, -devkit[1] / 2, 0]) cube([devkit[0], devkit[1], 1.6]);
                            for (sx = [-1, 1], sy = [-1, 1]) translate([sx * devkit_holes[0] / 2, sy * devkit_holes[1] / 2, -1]) cylinder(d = 3.0, h = 4);
                        }
                        translate([devkit[0] / 2 - 18 - 4, -9, -3.2]) cube([18, 18, 3.2]);      // ESP32 模组
                        translate([-devkit[0] / 2 - 1, -4, -3]) cube([6, 8, 3]);                // USB 座
                    } }
// 线圈压板(单独打印,平面朝下):上面贴住磁片,背面是 Qi 板定位框
module coil_cover() {
    difference() {
        on_panel(coil_c, -coil_local_t - cover_t) linear_extrude(cover_t) rr2d_c([cover_size, cover_size], cover_r);
        for (sx = [-1, 1], sy = [-1, 1]) on_panel(coil_c, -coil_local_t - cover_t - 1) translate([sx * cover_hole, sy * cover_hole, 0]) cylinder(d = cover_pin_hole, h = cover_t + 2);
        for (a = [0 : 90 : 270], u = cover_notch_pos) on_panel(coil_c, -coil_local_t - cover_t - 1) rotate([0, 0, a])
            translate([cover_size / 2, u, 0]) linear_extrude(cover_t + 2) hull() {
                translate([-cover_notch_d + cover_notch_w / 2, 0]) circle(d = cover_notch_w);
                translate([1, -cover_notch_w / 2]) square([1, cover_notch_w]);
            }
    }
    fence(qi_board_c, qi_board, fence_h, -coil_local_t - cover_t, qi_rot);
}
module m_qi()     { on_panel(qi_board_c, -coil_local_t - cover_t - 1.6) rotate([0, 0, qi_rot]) {
                        translate([-qi_board[0] / 2, -qi_board[1] / 2, 0]) cube([qi_board[0], qi_board[1], 1.6]);
                        translate([-8, -10, -2.5]) cube([16, 20, 2.5]);
                    } }
module m_usbc()   { translate([usbc_x, usbc_c_y, usbc_mount_z - 1.6]) {           // 挂在平台底面,插座朝下、口朝后墙
                        translate([-usbc_board[0] / 2, -usbc_board[1] / 2, 0]) cube([usbc_board[0], usbc_board[1], 1.6]);
                        translate([-usbc_recept[0] / 2, usbc_board[1] / 2 - usbc_recept[2] + usbc_recept_out, -usbc_recept[1]]) cube([usbc_recept[0], usbc_recept[2], usbc_recept[1]]);
                    } }

// 打印姿态:把上盖转回面板坐标,翻过来顶面贴床
module to_print() { rotate([180, 0, 0]) rotate([-angle, 0, 0]) translate([0, 0, -front_h]) children(); }

if (part == "shell") to_print() shell();
else if (part == "shell_world") shell();
else if (part == "plate") plate();
else if (part == "plate2") plate2();
else if (part == "cover") rotate([180, 0, 0]) rotate([-angle, 0, 0]) translate([0, 0, -front_h]) coil_cover();   // 打印:贴磁片的平面朝下
else if (part == "cover_world") coil_cover();
else if (part == "fit") to_print() fit();
else if (part == "screenfit") to_print() screen_fit();
else if (part == "clips") clips();
else if (part == "clipsbrim") clips_brim();
else if (part == "ribs") side_ribs();
else if (part == "frontribs") front_ribs();
else if (part == "inlays") inlays();
else if (part == "inlaytest") inlays_test();
else if (part == "inlays2") inlays_v2();
else if (part == "logofit") to_print() logo_fit();
else if (part == "logowhite") to_print() logo_white();
else if (part == "whites") to_print() { logo_white(); text_white(); }
// 多色 logo 试片(P1S + AMS):黑底方片,logo 齐平嵌在表面;表面朝下打(镜像,从正面看是正的)。四个零件同一坐标,切片时合成一个物体按料分色
// 整壳四色(P1S + AMS):外壳黑 + 文字白 + logo 白/橙/绿,同一坐标(to_print),切片合成一个物体。白字用 -D white_shrink=0
// (AMS 同一次打印,不需要 A1 两遍共打时留的 0.05 缝)
else if (part == "logo3_w") to_print() on_panel(mark_c, -mark_depth) linear_extrude(mark_depth) logo_white_part(mark_d);
else if (part == "logo3_o") to_print() on_panel(mark_c, -mark_depth) linear_extrude(mark_depth) logo_arc_part(mark_d, false);
else if (part == "logo3_g") to_print() on_panel(mark_c, -mark_depth) linear_extrude(mark_depth) logo_arc_part(mark_d, true);
else if (part == "text3") to_print() text_white();
else if (part == "logotile_k") logo_tile(0);
else if (part == "logotile_w") logo_tile(1);
else if (part == "logotile_o") logo_tile(2);
else if (part == "logotile_g") logo_tile(3);
else if (part == "textfit") to_print() text_fit();
else if (part == "m_phone") m_phone();
else if (part == "m_glass") m_glass();
else if (part == "m_display") m_display();
else if (part == "m_cyd_pcb") m_cyd_pcb();
else if (part == "m_coil") m_coil();
else if (part == "m_devkit") m_devkit();
else if (part == "m_qi") m_qi();
else if (part == "m_usbc") m_usbc();
else if (part == "m_cyd_back") m_cyd_back();
else if (part == "exploded") { color("#333") plate(); color("#555", 0.9) translate([0, 0, 25]) shell(); }
else if (part == "section_coil") intersection() {      // 沿线圈中心(前后方向)剖开,翻成内侧朝上看
    union() { color("#555") shell(); color("#c8743a") m_coil(); }
    translate([coil_c[0] - 40, coil_c[1], -1]) cube([80, 60, back_h + 5]);
}
else if (part == "detail_inside") shell();
else if (part == "section_usbc") intersection() {
    union() { color("#555") shell(); color("#999") plate(); color("#d22") m_usbc(); }
    translate([0, 0, -1]) cube([usbc_x, D + 1, back_h + 5]);   // 沿 USB-C 中心线剖开,看左半边截面
}
else if (part == "inside") { color("#555") shell(); color("#777") coil_cover(); color("#c80") { m_devkit(); m_qi(); m_usbc(); m_cyd_pcb(); m_coil(); } }
else { color("#333") plate(); color("#555") shell(); }
