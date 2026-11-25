// AutoPhoneAgent 产品标志(凹刻用 2D):圆环外框(呼应上方 MagSafe 圆环)+ 倾斜的电话听筒 + 两道声波弧(AI 代接/通话)
$fn = 96;
module ring(r_out, w) difference() { circle(r_out); circle(r_out - w); }
module sector(r_out, r_in, a0, a1) intersection() {
    ring(r_out, r_out - r_in);
    polygon(concat([[0, 0]], [for (a = [a0 : (a1 - a0) / 24 : a1]) 3 * r_out * [cos(a), sin(a)]]));
}
module arc_stroke(r, w, a0, a1) {                       // 圆头弧线
    sector(r + w / 2, r - w / 2, a0, a1);
    for (a = [a0, a1]) translate(r * [cos(a), sin(a)]) circle(d = w);
}
module handset() {                                     // 听筒:上方弧形把手 + 两端听/话筒
    sector(5.0, 3.5, 25, 155);
    for (sx = [-1, 1]) hull() {
        translate([sx * 3.9, 1.6]) circle(d = 2.6);
        translate([sx * 4.9, -1.2]) circle(d = 3.4);
    }
}
// 实心听筒:沿圆弧连成一条粗带,两端加宽成圆头(听筒/话筒),中段稍细 —— 手机"电话"图标的风格,自行绘制
module handset_solid(R = 4.2, a0 = 138, a1 = 312, d_end = 3.6, d_mid = 2.3) {
    n = 24;
    function pt(i) = let(a = a0 + (a1 - a0) * i / n) R * [cos(a), sin(a)];
    function dd(i) = let(t = abs(2 * i / n - 1)) d_mid + (d_end - d_mid) * pow(t, 2.5);
    for (i = [0 : n - 1]) hull() {
        translate(pt(i)) circle(d = dd(i));
        translate(pt(i + 1)) circle(d = dd(i + 1));
    }
}
module logo_mark(d = 16) {
    s = d / 16;
    scale([s, s]) {
        ring(8, 1.1);
        translate([0.15, 0.15]) handset_solid();   // 听筒:弯背朝左下,两端朝右上(第5版往左下 45° 挪约 0.6,设计者:原来偏右上)
        translate([0.6, 0.6]) for (r = [1.9, 3.7]) arc_stroke(r, 1.15, 12, 78);   // 第5版:声波加粗加长(原 r 1.5/3.0、宽 0.9)   // 声波:从听筒怀里向右上发出
    }
}

// 多色版(P1S + AMS,2026-11-13 设计者):圆环 + 听筒白色;两道声波分色 —— 短的内弧橙(挂断/拒接),长的外弧绿(接通/AI 处理)。
// 各部分互不重叠(声波压在听筒上的一点归白色),拼起来就是 logo_mark
module logo_white_part(d = 16) {
    s = d / 16;
    scale([s, s]) { ring(8, 1.1); translate([0.15, 0.15]) handset_solid(); }
}
module logo_arc_part(d = 16, outer = false) {
    s = d / 16;
    difference() {
        scale([s, s]) translate([0.6, 0.6]) arc_stroke(outer ? 3.7 : 1.9, 1.15, 12, 78);
        logo_white_part(d);
    }
}
logo_mark();
