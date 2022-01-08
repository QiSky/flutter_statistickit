import 'dart:async';

class TimerManager {
  Map<String, dynamic> _timerMap = Map();

  /// 单例
  static TimerManager? _instance;

  static TimerManager getInstance() {
    _instance ??= TimerManager();
    return _instance!;
  }

  ///启动单次定时器
  void startTimerOnce(Function timerCallBack) {
    Timer.run(() => timerCallBack.call());
  }

  ///启动有间隔时间的多次定时器
  void startTimer(Function timerCallBack,
      {required Duration duration, required String key}) {
    _timerMap[key] = Timer.periodic(duration, (timer) {
      timerCallBack(timer, timer.tick);
    });
  }

  void clearTimer(String timerName) {
    if (_timerMap.containsKey(timerName)) {
      var res = _timerMap[timerName];
      if (res == null) return;
      if (res is List<Timer>)
        autoRelease(timerName);
      else {
        Timer timer = res as Timer;
        _timerMap.remove(timerName);
        timer.cancel();
      }
    }
  }

  void getAllTimerName() async {
    _timerMap.forEach((key, value) {
      print("Timer name:$key");
    });
  }

  bool hasTimer(String timerName) {
    return _timerMap.containsKey(timerName);
  }

  ///根据widget名称自动释放定时器
  void autoRelease(String widget) async {
    _timerMap.containsKey(widget) as List<Timer>
      ..forEach((element) {
        if (element.isActive) element.cancel();
      });
    _timerMap.remove(widget);
  }
}
