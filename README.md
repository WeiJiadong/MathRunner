# 数学小勇士 · MathRunner

6 岁孩子练 20 以内加减法的 Mac 小游戏。跑酷冒险包装：答题斩怪闯关集星，星星解锁装扮图鉴。

- SwiftUI + SwiftPM，复用 Xiangqi 脚手架
- 三档难度：10 以内 / 20 以内不进退位 / 进位加 + 退位减
- 每关 5 题 + 1 道 Boss，3 颗心，无倒计时
- 答对即时反馈，集星自动解锁装扮
- 存档用 UserDefaults，无第三方依赖

## 开发

```
swift build                 # 编译
swift run MathRunnerTests   # 跑逻辑测试（4024 项）
./.build/debug/MathRunner   # 启动
make_app.sh                 # 打 .app / DMG
```
