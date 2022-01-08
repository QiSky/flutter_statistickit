import 'dart:async';
import 'dart:convert';

import 'package:isolate/isolate_runner.dart';
import 'package:isolate/load_balancer.dart';
import 'package:statistic/manager/timer_manager.dart';

import 'http_manager.dart';

enum StatisticSendType {
  ///单次发送，发送时机：立刻
  SINGLE,

  /// 组合发送，发送时机：间隔性
  ARRAY
}

///单次发送选择的数据类型
enum StatisticSingleSendDataType {
  ///转换成json字符串
  STRING,

  ///普通对象类型
  BODY,

  ///数组型json字符串
  ARRAY_STRING
}

void _sendSingleEvent(Map<String, dynamic> argument) {
  var data = argument["data"];
  StatisticSingleSendDataType dataType = argument["dataType"];
  String url = argument["url"];
  switch (dataType) {
    case StatisticSingleSendDataType.ARRAY_STRING:
      HttpManager.instance.getRequest(url,
          method: HttpManager.METHOD_POST, data: jsonEncode([data]));
      break;
    case StatisticSingleSendDataType.BODY:
      HttpManager.instance
          .getRequest(url, method: HttpManager.METHOD_POST, data: data);
      break;
    case StatisticSingleSendDataType.STRING:
      HttpManager.instance.getRequest(url,
          method: HttpManager.METHOD_POST, data: jsonEncode(data));
      break;
  }
}

void _sendArrayEvent(Map<String, dynamic> argument) {
  List<dynamic> data = argument["data"];
  String url = argument["url"];
  if (data.isNotEmpty)
    HttpManager.instance.getRequest(url,
        method: HttpManager.METHOD_POST, data: jsonEncode(data));
}

class StatisticsManager {
  /// 单例
  static StatisticsManager? _instance;

  ///多线程isolate池
  late LoadBalancer _balance;

  ///发送地址的子Url
  late String _apiUrl;

  ///数组发送状态下存储的List
  late List<dynamic> _storeList = [];

  ///目前发送器状态
  bool _isActive = false;

  ///数组发送状态下发送延迟
  late int _sendDuration;

  static const STATISTIC_TIMER = "Statistic_Timer";

  static StatisticsManager getInstance() {
    _instance ??= StatisticsManager();
    return _instance!;
  }

  ///初始化
  ///@apiUrl 子地址
  ///@sendDuration 多项发送间隔
  Future<bool> init(String apiUrl, {int sendDuration = 5}) async {
    _balance = await LoadBalancer.create(3, IsolateRunner.spawn);

    _isActive = true;

    _apiUrl = apiUrl;
    _sendDuration = sendDuration;

    _start();
    return true;
  }

  void _start() {
    TimerManager.getInstance().startTimer((timer, tick) async {
      if (_storeList.isNotEmpty) {
        await _balance.run<void, Map<String, dynamic>>(
            _sendArrayEvent, {"data": _storeList, "url": _apiUrl});
        _storeList.clear();
      }
      TimerManager.getInstance().clearTimer(STATISTIC_TIMER);
      _start();
    }, duration: Duration(seconds: _sendDuration), key: STATISTIC_TIMER);
  }

  ///发送事件
  void sendEvent(dynamic event,
      {StatisticSendType sendType = StatisticSendType.SINGLE,
      StatisticSingleSendDataType dataType =
          StatisticSingleSendDataType.ARRAY_STRING}) {
    if (_isActive) {
      if (sendType == StatisticSendType.ARRAY)
        _storeList.add(event);
      else
        _balance.run<void, Map<String, dynamic>>(_sendSingleEvent,
            {"data": event, "dataType": dataType, "url": _apiUrl});
    }
  }

  ///暂停发送
  void pause() {
    assert(_isActive);
    _isActive = false;
    TimerManager.getInstance().clearTimer(STATISTIC_TIMER);
  }

  ///重启发送
  void restart() {
    _isActive = true;
    _start();
  }
}
